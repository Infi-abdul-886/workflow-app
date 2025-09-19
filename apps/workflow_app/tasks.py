"""
Celery tasks for workflow execution
"""
from celery import shared_task
from django.utils import timezone
import logging

logger = logging.getLogger(__name__)

@shared_task(bind=True, max_retries=3)
def execute_workflow_task(self, execution_id: str):
    """
    Celery task to execute a workflow asynchronously
    
    Args:
        execution_id: UUID of the WorkflowExecution to run
    """
    try:
        from .engine import WorkflowEngine
        
        logger.info(f"Starting workflow execution task for execution {execution_id}")
        
        engine = WorkflowEngine()
        success = engine.execute_workflow(execution_id)
        
        if success:
            logger.info(f"Workflow execution {execution_id} completed successfully")
        else:
            logger.error(f"Workflow execution {execution_id} failed")
        
        return {
            'execution_id': execution_id,
            'success': success,
            'completed_at': timezone.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Workflow execution task failed: {str(e)}")
        
        # Retry the task if it hasn't exceeded max retries
        if self.request.retries < self.max_retries:
            logger.info(f"Retrying workflow execution {execution_id} (attempt {self.request.retries + 1})")
            raise self.retry(countdown=60 * (self.request.retries + 1))  # Exponential backoff
        
        # Mark execution as failed if max retries exceeded
        try:
            from .models import WorkflowExecution
            execution = WorkflowExecution.objects.get(id=execution_id)
            execution.status = 'failed'
            execution.finished_at = timezone.now()
            execution.error_message = f"Task failed after {self.max_retries} retries: {str(e)}"
            execution.save()
        except:
            pass  # Don't fail if we can't update the execution
        
        raise

@shared_task
def cleanup_old_executions():
    """
    Clean up old workflow executions to prevent database bloat
    """
    from datetime import timedelta
    from .models import WorkflowExecution
    
    # Delete executions older than 30 days
    cutoff_date = timezone.now() - timedelta(days=30)
    
    deleted_count = WorkflowExecution.objects.filter(
        finished_at__lt=cutoff_date
    ).delete()[0]
    
    logger.info(f"Cleaned up {deleted_count} old workflow executions")
    
    return {'deleted_count': deleted_count}

@shared_task
def process_scheduled_workflows():
    """
    Process workflows that are scheduled to run
    """
    from .models import Workflow, WorkflowExecution
    from django.db.models import Q
    
    # Find workflows that should be executed
    now = timezone.now()
    
    scheduled_workflows = Workflow.objects.filter(
        status='active',
        is_scheduled=True,
        schedule__is_active=True,
        schedule__next_execution_at__lte=now
    ).select_related('schedule')
    
    executed_count = 0
    
    for workflow in scheduled_workflows:
        try:
            # Create execution
            execution = WorkflowExecution.objects.create(
                workflow=workflow,
                triggered_by='scheduled',
                input_data={},
                execution_context={'scheduled': True}
            )
            
            # Execute asynchronously
            execute_workflow_task.delay(str(execution.id))
            
            # Update next execution time
            schedule = workflow.schedule
            # This would calculate next execution time based on cron expression
            # For now, just increment by 1 hour as placeholder
            schedule.next_execution_at = now + timedelta(hours=1)
            schedule.last_executed_at = now
            schedule.execution_count += 1
            schedule.save()
            
            executed_count += 1
            
        except Exception as e:
            logger.error(f"Failed to schedule workflow {workflow.id}: {str(e)}")
    
    logger.info(f"Scheduled {executed_count} workflows for execution")
    
    return {'scheduled_count': executed_count}

@shared_task
def execute_scheduled_workflow(workflow_id: str):
    """
    Execute a scheduled workflow
    
    Args:
        workflow_id: UUID of the workflow to execute
    """
    try:
        from .models import Workflow, WorkflowExecution
        
        workflow = Workflow.objects.get(id=workflow_id, status='active')
        
        # Create execution
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by='scheduled',
            input_data={},
            execution_context={'scheduled': True}
        )
        
        # Execute the workflow
        execute_workflow_task.delay(str(execution.id))
        
        logger.info(f"Scheduled execution created for workflow {workflow.name}")
        
        return {
            'workflow_id': workflow_id,
            'execution_id': str(execution.id),
            'status': 'scheduled'
        }
        
    except Exception as e:
        logger.error(f"Failed to execute scheduled workflow {workflow_id}: {str(e)}")
        raise

@shared_task
def cleanup_webhook_logs():
    """
    Clean up old webhook trigger logs
    """
    from datetime import timedelta
    from .models import WorkflowWebhook
    
    # Reset trigger counts for webhooks not used in 30 days
    cutoff_date = timezone.now() - timedelta(days=30)
    
    updated_count = WorkflowWebhook.objects.filter(
        last_triggered_at__lt=cutoff_date,
        trigger_count__gt=0
    ).update(trigger_count=0)
    
    logger.info(f"Reset trigger counts for {updated_count} inactive webhooks")
    
    return {'reset_count': updated_count}

@shared_task
def update_schedule_next_executions():
    """
    Update next execution times for all active schedules
    """
    from .models import WorkflowSchedule
    from .scheduler import WorkflowScheduler
    
    scheduler = WorkflowScheduler()
    updated_count = 0
    
    active_schedules = WorkflowSchedule.objects.filter(
        is_active=True,
        workflow__status='active'
    )
    
    for schedule in active_schedules:
        try:
            next_execution = scheduler._calculate_next_execution(
                schedule.cron_expression,
                schedule.timezone
            )
            
            if next_execution != schedule.next_execution_at:
                schedule.next_execution_at = next_execution
                schedule.save()
                updated_count += 1
                
        except Exception as e:
            logger.error(f"Failed to update schedule {schedule.id}: {str(e)}")
    
    logger.info(f"Updated next execution times for {updated_count} schedules")
    
    return {'updated_count': updated_count}
