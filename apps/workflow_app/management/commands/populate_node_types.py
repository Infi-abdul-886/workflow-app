from django.core.management.base import BaseCommand
from apps.workflow_app.models import NodeType

class Command(BaseCommand):
    help = 'Populate database with default node types'

    def handle(self, *args, **options):
        node_types = [
            # Trigger nodes
            {
                'name': 'manual_trigger',
                'display_name': 'Manual Trigger',
                'category': 'trigger',
                'description': 'Manually triggered workflow start',
                'icon': 'fa-play',
                'color': '#10b981',
                'config_schema': {
                    'fields': [
                        {'name': 'name', 'type': 'string', 'required': True, 'label': 'Trigger Name'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.command_handlers.ManualTriggerHandler'
            },
            {
                'name': 'webhook_trigger',
                'display_name': 'Webhook Trigger',
                'category': 'trigger',
                'description': 'Triggered by HTTP webhook',
                'icon': 'fa-globe',
                'color': '#3b82f6',
                'config_schema': {
                    'fields': [
                        {'name': 'method', 'type': 'select', 'options': ['GET', 'POST', 'PUT'], 'default': 'POST'},
                        {'name': 'path', 'type': 'string', 'required': True, 'label': 'Webhook Path'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.trigger_handlers.WebhookTriggerHandler'
            },
            {
                'name': 'schedule_trigger',
                'display_name': 'Schedule Trigger',
                'category': 'trigger',
                'description': 'Triggered by cron schedule',
                'icon': 'fa-clock',
                'color': '#f59e0b',
                'config_schema': {
                    'fields': [
                        {'name': 'cron', 'type': 'string', 'required': True, 'label': 'Cron Expression'},
                        {'name': 'timezone', 'type': 'string', 'default': 'UTC', 'label': 'Timezone'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.trigger_handlers.ScheduleTriggerHandler'
            },
            
            # Data nodes
            {
                'name': 'database_query',
                'display_name': 'Database Query',
                'category': 'data',
                'description': 'Query database for data',
                'icon': 'fa-database',
                'color': '#8b5cf6',
                'config_schema': {
                    'fields': [
                        {'name': 'query', 'type': 'textarea', 'required': True, 'label': 'SQL Query'},
                        {'name': 'connection', 'type': 'string', 'default': 'default', 'label': 'Database Connection'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.data_handlers.DatabaseQueryHandler'
            },
            {
                'name': 'http_request',
                'display_name': 'HTTP Request',
                'category': 'data',
                'description': 'Make HTTP request to external API',
                'icon': 'fa-link',
                'color': '#06b6d4',
                'config_schema': {
                    'fields': [
                        {'name': 'url', 'type': 'string', 'required': True, 'label': 'URL'},
                        {'name': 'method', 'type': 'select', 'options': ['GET', 'POST', 'PUT', 'DELETE'], 'default': 'GET'},
                        {'name': 'headers', 'type': 'json', 'label': 'Headers'},
                        {'name': 'body', 'type': 'textarea', 'label': 'Request Body'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.data_handlers.HttpRequestHandler'
            },
            
            # Transform nodes
            {
                'name': 'data_transform',
                'display_name': 'Data Transform',
                'category': 'transform',
                'description': 'Transform and manipulate data',
                'icon': 'fa-exchange-alt',
                'color': '#ef4444',
                'config_schema': {
                    'fields': [
                        {'name': 'operation', 'type': 'select', 'options': ['map', 'filter', 'reduce', 'sort'], 'required': True},
                        {'name': 'expression', 'type': 'textarea', 'required': True, 'label': 'Transform Expression'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.transform_handlers.DataTransformHandler'
            },
            {
                'name': 'json_parser',
                'display_name': 'JSON Parser',
                'category': 'transform',
                'description': 'Parse and extract data from JSON',
                'icon': 'fa-code',
                'color': '#f97316',
                'config_schema': {
                    'fields': [
                        {'name': 'path', 'type': 'string', 'label': 'JSON Path'},
                        {'name': 'operation', 'type': 'select', 'options': ['extract', 'validate', 'transform'], 'default': 'extract'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.transform_handlers.JsonParserHandler'
            },
            
            # Condition nodes
            {
                'name': 'condition',
                'display_name': 'Condition',
                'category': 'condition',
                'description': 'Conditional branching based on data',
                'icon': 'fa-question-circle',
                'color': '#84cc16',
                'config_schema': {
                    'fields': [
                        {'name': 'condition', 'type': 'textarea', 'required': True, 'label': 'Condition Expression'},
                        {'name': 'operator', 'type': 'select', 'options': ['==', '!=', '>', '<', '>=', '<=', 'contains'], 'default': '=='}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.condition_handlers.ConditionHandler'
            },
            {
                'name': 'switch',
                'display_name': 'Switch',
                'category': 'condition',
                'description': 'Multi-way branching',
                'icon': 'fa-code-branch',
                'color': '#22c55e',
                'config_schema': {
                    'fields': [
                        {'name': 'value', 'type': 'string', 'required': True, 'label': 'Switch Value'},
                        {'name': 'cases', 'type': 'json', 'required': True, 'label': 'Cases'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.condition_handlers.SwitchHandler'
            },
            
            # Action nodes
            {
                'name': 'email_send',
                'display_name': 'Send Email',
                'category': 'action',
                'description': 'Send email notification',
                'icon': 'fa-envelope',
                'color': '#dc2626',
                'config_schema': {
                    'fields': [
                        {'name': 'to', 'type': 'string', 'required': True, 'label': 'To Email'},
                        {'name': 'subject', 'type': 'string', 'required': True, 'label': 'Subject'},
                        {'name': 'body', 'type': 'textarea', 'required': True, 'label': 'Email Body'},
                        {'name': 'from_email', 'type': 'string', 'label': 'From Email'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.EmailSendHandler'
            },
            {
                'name': 'delay',
                'display_name': 'Delay',
                'category': 'action',
                'description': 'Add delay to workflow execution',
                'icon': 'fa-pause',
                'color': '#6b7280',
                'config_schema': {
                    'fields': [
                        {'name': 'duration', 'type': 'number', 'required': True, 'label': 'Duration (seconds)'},
                        {'name': 'unit', 'type': 'select', 'options': ['seconds', 'minutes', 'hours'], 'default': 'seconds'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.DelayHandler'
            },
            {
                'name': 'log',
                'display_name': 'Log Message',
                'category': 'action',
                'description': 'Log message for debugging',
                'icon': 'fa-file-text',
                'color': '#64748b',
                'config_schema': {
                    'fields': [
                        {'name': 'message', 'type': 'textarea', 'required': True, 'label': 'Log Message'},
                        {'name': 'level', 'type': 'select', 'options': ['info', 'warning', 'error'], 'default': 'info'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.LogHandler'
            },
            
            # Output nodes
            {
                'name': 'database_save',
                'display_name': 'Save to Database',
                'category': 'output',
                'description': 'Save data to database',
                'icon': 'fa-save',
                'color': '#7c3aed',
                'config_schema': {
                    'fields': [
                        {'name': 'table', 'type': 'string', 'required': True, 'label': 'Table Name'},
                        {'name': 'operation', 'type': 'select', 'options': ['insert', 'update', 'upsert'], 'default': 'insert'},
                        {'name': 'mapping', 'type': 'json', 'required': True, 'label': 'Field Mapping'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.output_handlers.DatabaseSaveHandler'
            },
            {
                'name': 'file_export',
                'display_name': 'Export to File',
                'category': 'output',
                'description': 'Export data to file',
                'icon': 'fa-download',
                'color': '#059669',
                'config_schema': {
                    'fields': [
                        {'name': 'filename', 'type': 'string', 'required': True, 'label': 'File Name'},
                        {'name': 'format', 'type': 'select', 'options': ['json', 'csv', 'xml'], 'default': 'json'},
                        {'name': 'path', 'type': 'string', 'label': 'File Path'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.output_handlers.FileExportHandler'
            },
            {
                'name': 'response',
                'display_name': 'Response',
                'category': 'output',
                'description': 'Return response data',
                'icon': 'fa-reply',
                'color': '#0891b2',
                'config_schema': {
                    'fields': [
                        {'name': 'status_code', 'type': 'number', 'default': 200, 'label': 'Status Code'},
                        {'name': 'content_type', 'type': 'string', 'default': 'application/json', 'label': 'Content Type'},
                        {'name': 'body', 'type': 'textarea', 'label': 'Response Body'}
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.output_handlers.ResponseHandler'
            }
        ]

        created_count = 0
        updated_count = 0

        for node_data in node_types:
            node_type, created = NodeType.objects.get_or_create(
                name=node_data['name'],
                defaults=node_data
            )
            
            if created:
                created_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f'Created node type: {node_data["display_name"]}')
                )
            else:
                # Update existing node type
                for key, value in node_data.items():
                    if key != 'name':
                        setattr(node_type, key, value)
                node_type.save()
                updated_count += 1
                self.stdout.write(
                    self.style.WARNING(f'Updated node type: {node_data["display_name"]}')
                )

        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully processed {created_count} new and {updated_count} existing node types'
            )
        )
