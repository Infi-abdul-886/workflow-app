"""
Management command to import existing cron jobs into workflows
"""
import os
import re
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

from apps.workflow_app.models import Workflow, NodeType
from apps.workflow_app.scheduler import schedule_workflow, CronConverter

User = get_user_model()

class Command(BaseCommand):
    help = 'Import existing cron jobs and convert them to workflows'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--crontab-file',
            type=str,
            help='Path to crontab file to import',
        )
        parser.add_argument(
            '--user',
            type=str,
            required=True,
            help='Username to assign workflows to',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be imported without actually importing',
        )
    
    def handle(self, *args, **options):
        crontab_file = options.get('crontab_file')
        username = options['user']
        dry_run = options['dry_run']
        
        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'User "{username}" not found')
            )
            return
        
        # Read crontab file or current user's crontab
        if crontab_file:
            if not os.path.exists(crontab_file):
                self.stdout.write(
                    self.style.ERROR(f'Crontab file "{crontab_file}" not found')
                )
                return
            
            with open(crontab_file, 'r') as f:
                crontab_content = f.read()
        else:
            # Read current user's crontab
            import subprocess
            try:
                result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
                if result.returncode != 0:
                    self.stdout.write(
                        self.style.ERROR('No crontab found for current user')
                    )
                    return
                crontab_content = result.stdout
            except FileNotFoundError:
                self.stdout.write(
                    self.style.ERROR('crontab command not found')
                )
                return
        
        # Parse crontab entries
        cron_jobs = self._parse_crontab(crontab_content)
        
        if not cron_jobs:
            self.stdout.write('No cron jobs found to import')
            return
        
        self.stdout.write(f'Found {len(cron_jobs)} cron jobs to import')
        
        imported_count = 0
        
        for job in cron_jobs:
            try:
                if dry_run:
                    self.stdout.write(
                        f'Would import: {job["name"]} - {job["schedule"]} - {job["command"]}'
                    )
                else:
                    workflow = self._create_workflow_from_cron_job(job, user)
                    self.stdout.write(
                        self.style.SUCCESS(
                            f'Imported: {workflow.name} (ID: {workflow.id})'
                        )
                    )
                
                imported_count += 1
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(
                        f'Failed to import job "{job["name"]}": {str(e)}'
                    )
                )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully imported {imported_count} cron jobs'
            )
        )
    
    def _parse_crontab(self, content: str) -> list:
        """Parse crontab content and extract cron jobs"""
        jobs = []
        lines = content.strip().split('\n')
        
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
            
            # Skip environment variable assignments
            if '=' in line and not line.startswith('*') and not line[0].isdigit():
                continue
            
            # Parse cron job line
            parts = line.split(None, 5)
            if len(parts) >= 6:
                minute, hour, day, month, weekday, command = parts
                schedule = f"{minute} {hour} {day} {month} {weekday}"
                
                # Validate cron expression
                if CronConverter.validate_cron(schedule):
                    # Generate a name from the command
                    name = self._generate_job_name(command, line_num)
                    
                    jobs.append({
                        'name': name,
                        'schedule': schedule,
                        'command': command,
                        'line_number': line_num
                    })
        
        return jobs
    
    def _generate_job_name(self, command: str, line_num: int) -> str:
        """Generate a readable name from cron command"""
        # Extract script name or main command
        command_parts = command.split()
        if command_parts:
            main_command = command_parts[0]
            
            # Get basename if it's a path
            if '/' in main_command:
                main_command = os.path.basename(main_command)
            
            # Remove file extension
            if '.' in main_command:
                main_command = main_command.split('.')[0]
            
            return f"Imported Cron Job - {main_command}"
        
        return f"Imported Cron Job - Line {line_num}"
    
    def _create_workflow_from_cron_job(self, job: dict, user: User) -> Workflow:
        """Create a workflow from a cron job definition"""
        
        # Create workflow definition with a command execution node
        workflow_definition = {
            'nodes': [
                {
                    'id': 'trigger_1',
                    'type': 'schedule_trigger',
                    'name': 'Schedule Trigger',
                    'position': {'x': 100, 'y': 100},
                    'config': {
                        'cron_expression': job['schedule'],
                        'timezone': 'UTC'
                    }
                },
                {
                    'id': 'command_1',
                    'type': 'command_execution',
                    'name': 'Execute Command',
                    'position': {'x': 400, 'y': 100},
                    'config': {
                        'command': job['command'],
                        'working_directory': '/tmp',
                        'timeout': 300
                    }
                }
            ],
            'connections': [
                {
                    'source': 'trigger_1',
                    'target': 'command_1',
                    'source_output': 'main',
                    'target_input': 'main'
                }
            ]
        }
        
        # Create workflow
        workflow = Workflow.objects.create(
            name=job['name'],
            description=f"Imported from cron job: {job['command']}",
            definition=workflow_definition,
            created_by=user,
            status='draft',  # Start as draft for review
            tags=['imported', 'cron']
        )
        
        # Schedule the workflow
        schedule_workflow(workflow, job['schedule'])
        
        return workflow
