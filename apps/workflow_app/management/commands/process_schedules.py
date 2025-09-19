"""
Management command to process scheduled workflows
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
import logging

from apps.workflow_app.models import Workflow, WorkflowSchedule, WorkflowExecution
from apps.workflow_app.tasks import execute_workflow_task
from apps.workflow_app.scheduler import WorkflowScheduler

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = 'Process scheduled workflows that are due for execution'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be executed without actually executing',
        )
        parser.add_argument(
            '--limit',
            type=int,
            default=100,
            help='Maximum number of workflows to process',
        )
    
    def handle(self, *args, **options):
        dry_run = options['dry_run']
        limit = options['limit']
        
        self.stdout.write(
            self.style.SUCCESS(f'Processing scheduled workflows (dry_run={dry_run}, limit={limit})')
        )
        
        # Find workflows that should be executed
        now = timezone.now()
        
        due_schedules = WorkflowSchedule.objects.filter(
            is_active=True,
            workflow__status='active',
            next_execution_at__lte=now
        ).select_related('workflow')[:limit]
        
        if not due_schedules:
            self.stdout.write('No workflows are due for execution')
            return
        
        scheduler = WorkflowScheduler()
        executed_count = 0
        
        for schedule in due_schedules:
            workflow = schedule.workflow
            
            try:
                if dry_run:
                    self.stdout.write(
                        f'Would execute: {workflow.name} (next: {schedule.next_execution_at})'
                    )
                else:
                    # Create execution
                    execution = WorkflowExecution.objects.create(
                        workflow=workflow,
                        triggered_by='scheduled',
                        input_data={},
                        execution_context={
                            'scheduled': True,
                            'schedule_id': str(schedule.id)
                        }
                    )
                    
                    # Execute asynchronously
                    execute_workflow_task.delay(str(execution.id))
                    
                    # Update schedule
                    schedule.last_executed_at = now
                    schedule.execution_count += 1
                    schedule.next_execution_at = scheduler._calculate_next_execution(
                        schedule.cron_expression,
                        schedule.timezone
                    )
                    schedule.save()
                    
                    self.stdout.write(
                        self.style.SUCCESS(
                            f'Executed: {workflow.name} (execution: {execution.id})'
                        )
                    )
                
                executed_count += 1
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(
                        f'Failed to execute {workflow.name}: {str(e)}'
                    )
                )
                logger.error(f'Failed to execute scheduled workflow {workflow.id}: {str(e)}')
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Processed {executed_count} scheduled workflows'
            )
        )
