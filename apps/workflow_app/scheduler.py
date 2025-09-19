"""
Workflow Scheduler - Handles cron-based scheduling and trigger management
"""
import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from croniter import croniter
from django.utils import timezone
from django.conf import settings
from django_celery_beat.models import PeriodicTask, CrontabSchedule
import json

from .models import Workflow, WorkflowSchedule, WorkflowExecution
from .tasks import execute_workflow_task

logger = logging.getLogger(__name__)

class WorkflowScheduler:
    """
    Manages workflow scheduling using django-celery-beat
    """
    
    def __init__(self):
        self.logger = logger
    
    def schedule_workflow(self, workflow: Workflow, cron_expression: str, timezone_str: str = 'UTC') -> WorkflowSchedule:
        """
        Schedule a workflow to run on a cron schedule
        
        Args:
            workflow: Workflow to schedule
            cron_expression: Cron expression (e.g., "0 9 * * *")
            timezone_str: Timezone for the schedule
            
        Returns:
            WorkflowSchedule instance
        """
        try:
            # Validate cron expression
            if not self._validate_cron_expression(cron_expression):
                raise ValueError(f"Invalid cron expression: {cron_expression}")
            
            # Parse cron expression
            cron_parts = cron_expression.split()
            if len(cron_parts) != 5:
                raise ValueError("Cron expression must have 5 parts: minute hour day month weekday")
            
            minute, hour, day, month, day_of_week = cron_parts
            
            # Create or get crontab schedule
            crontab, created = CrontabSchedule.objects.get_or_create(
                minute=minute,
                hour=hour,
                day_of_month=day,
                month_of_year=month,
                day_of_week=day_of_week,
                timezone=timezone_str
            )
            
            # Create periodic task
            task_name = f"workflow_{workflow.id}_{workflow.name}"
            periodic_task, created = PeriodicTask.objects.get_or_create(
                name=task_name,
                defaults={
                    'crontab': crontab,
                    'task': 'apps.workflow_app.tasks.execute_scheduled_workflow',
                    'args': json.dumps([str(workflow.id)]),
                    'enabled': True,
                }
            )
            
            if not created:
                # Update existing task
                periodic_task.crontab = crontab
                periodic_task.enabled = True
                periodic_task.save()
            
            # Create or update workflow schedule
            schedule, created = WorkflowSchedule.objects.get_or_create(
                workflow=workflow,
                defaults={
                    'cron_expression': cron_expression,
                    'timezone': timezone_str,
                    'is_active': True,
                    'next_execution_at': self._calculate_next_execution(cron_expression, timezone_str)
                }
            )
            
            if not created:
                schedule.cron_expression = cron_expression
                schedule.timezone = timezone_str
                schedule.is_active = True
                schedule.next_execution_at = self._calculate_next_execution(cron_expression, timezone_str)
                schedule.save()
            
            # Update workflow
            workflow.is_scheduled = True
            workflow.cron_expression = cron_expression
            workflow.timezone = timezone_str
            workflow.save()
            
            self.logger.info(f"Scheduled workflow '{workflow.name}' with cron '{cron_expression}'")
            
            return schedule
            
        except Exception as e:
            self.logger.error(f"Failed to schedule workflow {workflow.id}: {str(e)}")
            raise
    
    def unschedule_workflow(self, workflow: Workflow) -> bool:
        """
        Remove workflow from schedule
        
        Args:
            workflow: Workflow to unschedule
            
        Returns:
            True if successful
        """
        try:
            # Remove periodic task
            task_name = f"workflow_{workflow.id}_{workflow.name}"
            PeriodicTask.objects.filter(name=task_name).delete()
            
            # Deactivate schedule
            WorkflowSchedule.objects.filter(workflow=workflow).update(is_active=False)
            
            # Update workflow
            workflow.is_scheduled = False
            workflow.save()
            
            self.logger.info(f"Unscheduled workflow '{workflow.name}'")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to unschedule workflow {workflow.id}: {str(e)}")
            return False
    
    def update_schedule(self, workflow: Workflow, cron_expression: str, timezone_str: str = 'UTC') -> WorkflowSchedule:
        """
        Update existing workflow schedule
        
        Args:
            workflow: Workflow to update
            cron_expression: New cron expression
            timezone_str: New timezone
            
        Returns:
            Updated WorkflowSchedule instance
        """
        # Remove existing schedule
        self.unschedule_workflow(workflow)
        
        # Create new schedule
        return self.schedule_workflow(workflow, cron_expression, timezone_str)
    
    def get_scheduled_workflows(self) -> List[Workflow]:
        """
        Get all currently scheduled workflows
        
        Returns:
            List of scheduled workflows
        """
        return Workflow.objects.filter(
            is_scheduled=True,
            status='active',
            schedule__is_active=True
        ).select_related('schedule')
    
    def get_next_executions(self, hours: int = 24) -> List[Dict[str, Any]]:
        """
        Get upcoming workflow executions within specified hours
        
        Args:
            hours: Number of hours to look ahead
            
        Returns:
            List of upcoming executions
        """
        end_time = timezone.now() + timedelta(hours=hours)
        
        schedules = WorkflowSchedule.objects.filter(
            is_active=True,
            workflow__status='active',
            next_execution_at__lte=end_time
        ).select_related('workflow').order_by('next_execution_at')
        
        executions = []
        for schedule in schedules:
            executions.append({
                'workflow_id': schedule.workflow.id,
                'workflow_name': schedule.workflow.name,
                'next_execution': schedule.next_execution_at,
                'cron_expression': schedule.cron_expression,
                'timezone': schedule.timezone
            })
        
        return executions
    
    def _validate_cron_expression(self, cron_expression: str) -> bool:
        """
        Validate cron expression format
        
        Args:
            cron_expression: Cron expression to validate
            
        Returns:
            True if valid
        """
        try:
            croniter(cron_expression)
            return True
        except:
            return False
    
    def _calculate_next_execution(self, cron_expression: str, timezone_str: str = 'UTC') -> datetime:
        """
        Calculate next execution time for cron expression
        
        Args:
            cron_expression: Cron expression
            timezone_str: Timezone string
            
        Returns:
            Next execution datetime
        """
        try:
            import pytz
            tz = pytz.timezone(timezone_str)
            now = timezone.now().astimezone(tz)
            
            cron = croniter(cron_expression, now)
            next_time = cron.get_next(datetime)
            
            # Convert back to UTC
            return next_time.astimezone(pytz.UTC)
            
        except Exception as e:
            self.logger.error(f"Failed to calculate next execution: {str(e)}")
            # Fallback to 1 hour from now
            return timezone.now() + timedelta(hours=1)

class TriggerManager:
    """
    Manages workflow triggers (webhooks, file watchers, etc.)
    """
    
    def __init__(self):
        self.logger = logger
    
    def create_webhook_trigger(
        self, 
        workflow: Workflow, 
        endpoint_path: str = None,
        http_method: str = 'POST',
        require_auth: bool = True
    ) -> 'WorkflowWebhook':
        """
        Create a webhook trigger for a workflow
        
        Args:
            workflow: Workflow to create trigger for
            endpoint_path: Custom endpoint path
            http_method: HTTP method
            require_auth: Whether to require authentication
            
        Returns:
            WorkflowWebhook instance
        """
        from .models import WorkflowWebhook
        import uuid
        
        if not endpoint_path:
            endpoint_path = f"/webhook/{uuid.uuid4().hex[:8]}"
        
        # Generate API key if auth required
        api_key = f"wh_{uuid.uuid4().hex}" if require_auth else None
        
        webhook = WorkflowWebhook.objects.create(
            workflow=workflow,
            name=f"{workflow.name} Webhook",
            endpoint_path=endpoint_path,
            http_method=http_method,
            is_active=True,
            require_auth=require_auth,
            api_key=api_key
        )
        
        self.logger.info(f"Created webhook trigger for workflow '{workflow.name}' at {endpoint_path}")
        
        return webhook
    
    def trigger_workflow_by_webhook(
        self, 
        webhook: 'WorkflowWebhook', 
        request_data: Dict[str, Any],
        request_headers: Dict[str, str] = None
    ) -> WorkflowExecution:
        """
        Trigger a workflow via webhook
        
        Args:
            webhook: WorkflowWebhook instance
            request_data: Data from webhook request
            request_headers: Request headers
            
        Returns:
            WorkflowExecution instance
        """
        if not webhook.is_active:
            raise ValueError("Webhook is not active")
        
        if webhook.workflow.status != 'active':
            raise ValueError("Workflow is not active")
        
        # Create execution
        execution = WorkflowExecution.objects.create(
            workflow=webhook.workflow,
            triggered_by='webhook',
            input_data=request_data,
            execution_context={
                'webhook_id': str(webhook.id),
                'webhook_path': webhook.endpoint_path,
                'request_headers': request_headers or {}
            }
        )
        
        # Update webhook stats
        webhook.last_triggered_at = timezone.now()
        webhook.trigger_count += 1
        webhook.save()
        
        # Execute workflow asynchronously
        execute_workflow_task.delay(str(execution.id))
        
        self.logger.info(f"Triggered workflow '{webhook.workflow.name}' via webhook {webhook.endpoint_path}")
        
        return execution
    
    def create_manual_trigger(self, workflow: Workflow, user, input_data: Dict[str, Any] = None) -> WorkflowExecution:
        """
        Manually trigger a workflow
        
        Args:
            workflow: Workflow to trigger
            user: User triggering the workflow
            input_data: Optional input data
            
        Returns:
            WorkflowExecution instance
        """
        if workflow.status != 'active':
            raise ValueError("Workflow is not active")
        
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by='manual',
            triggered_by_user=user,
            input_data=input_data or {},
            execution_context={'manual_trigger': True}
        )
        
        # Execute workflow asynchronously
        execute_workflow_task.delay(str(execution.id))
        
        self.logger.info(f"Manually triggered workflow '{workflow.name}' by user {user.username}")
        
        return execution

class CronConverter:
    """
    Converts various cron formats and provides cron utilities
    """
    
    @staticmethod
    def parse_human_readable(description: str) -> str:
        """
        Convert human-readable schedule to cron expression
        
        Args:
            description: Human-readable description
            
        Returns:
            Cron expression
        """
        description = description.lower().strip()
        
        # Common patterns
        patterns = {
            'every minute': '* * * * *',
            'every 5 minutes': '*/5 * * * *',
            'every 10 minutes': '*/10 * * * *',
            'every 15 minutes': '*/15 * * * *',
            'every 30 minutes': '*/30 * * * *',
            'every hour': '0 * * * *',
            'every 2 hours': '0 */2 * * *',
            'every 6 hours': '0 */6 * * *',
            'every 12 hours': '0 */12 * * *',
            'daily': '0 0 * * *',
            'every day': '0 0 * * *',
            'weekly': '0 0 * * 0',
            'every week': '0 0 * * 0',
            'monthly': '0 0 1 * *',
            'every month': '0 0 1 * *',
            'yearly': '0 0 1 1 *',
            'every year': '0 0 1 1 *',
        }
        
        # Check for exact matches
        if description in patterns:
            return patterns[description]
        
        # Check for time-specific patterns
        import re
        
        # "at 9am daily" -> "0 9 * * *"
        time_daily = re.match(r'at (\d{1,2})(am|pm) daily', description)
        if time_daily:
            hour = int(time_daily.group(1))
            if time_daily.group(2) == 'pm' and hour != 12:
                hour += 12
            elif time_daily.group(2) == 'am' and hour == 12:
                hour = 0
            return f"0 {hour} * * *"
        
        # "every weekday at 9am" -> "0 9 * * 1-5"
        weekday_time = re.match(r'every weekday at (\d{1,2})(am|pm)', description)
        if weekday_time:
            hour = int(weekday_time.group(1))
            if weekday_time.group(2) == 'pm' and hour != 12:
                hour += 12
            elif weekday_time.group(2) == 'am' and hour == 12:
                hour = 0
            return f"0 {hour} * * 1-5"
        
        # Default fallback
        raise ValueError(f"Could not parse schedule description: {description}")
    
    @staticmethod
    def validate_cron(cron_expression: str) -> bool:
        """
        Validate cron expression
        
        Args:
            cron_expression: Cron expression to validate
            
        Returns:
            True if valid
        """
        try:
            croniter(cron_expression)
            return True
        except:
            return False
    
    @staticmethod
    def get_next_runs(cron_expression: str, count: int = 5) -> List[datetime]:
        """
        Get next N execution times for cron expression
        
        Args:
            cron_expression: Cron expression
            count: Number of next runs to get
            
        Returns:
            List of next execution times
        """
        try:
            cron = croniter(cron_expression, timezone.now())
            return [cron.get_next(datetime) for _ in range(count)]
        except:
            return []
    
    @staticmethod
    def describe_cron(cron_expression: str) -> str:
        """
        Convert cron expression to human-readable description
        
        Args:
            cron_expression: Cron expression
            
        Returns:
            Human-readable description
        """
        try:
            from cron_descriptor import get_description
            return get_description(cron_expression)
        except:
            # Fallback to basic description
            parts = cron_expression.split()
            if len(parts) == 5:
                minute, hour, day, month, weekday = parts
                
                if all(p == '*' for p in [minute, hour, day, month, weekday]):
                    return "Every minute"
                elif minute == '0' and all(p == '*' for p in [hour, day, month, weekday]):
                    return "Every hour"
                elif minute == '0' and hour == '0' and all(p == '*' for p in [day, month, weekday]):
                    return "Daily at midnight"
                elif minute == '0' and hour == '0' and day == '*' and month == '*' and weekday == '0':
                    return "Weekly on Sunday at midnight"
                elif minute == '0' and hour == '0' and day == '1' and month == '*' and weekday == '*':
                    return "Monthly on the 1st at midnight"
            
            return f"Custom schedule: {cron_expression}"

# Utility functions for easy access
def schedule_workflow(workflow: Workflow, cron_expression: str, timezone_str: str = 'UTC') -> WorkflowSchedule:
    """Convenience function to schedule a workflow"""
    scheduler = WorkflowScheduler()
    return scheduler.schedule_workflow(workflow, cron_expression, timezone_str)

def unschedule_workflow(workflow: Workflow) -> bool:
    """Convenience function to unschedule a workflow"""
    scheduler = WorkflowScheduler()
    return scheduler.unschedule_workflow(workflow)

def create_webhook_trigger(workflow: Workflow, **kwargs) -> 'WorkflowWebhook':
    """Convenience function to create webhook trigger"""
    trigger_manager = TriggerManager()
    return trigger_manager.create_webhook_trigger(workflow, **kwargs)

def trigger_workflow_manually(workflow: Workflow, user, input_data: Dict[str, Any] = None) -> WorkflowExecution:
    """Convenience function to manually trigger workflow"""
    trigger_manager = TriggerManager()
    return trigger_manager.create_manual_trigger(workflow, user, input_data)
