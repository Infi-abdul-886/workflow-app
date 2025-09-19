"""
Management command to set up default node types
"""
from django.core.management.base import BaseCommand
from apps.workflow_app.models import NodeType

class Command(BaseCommand):
    help = 'Set up default node types for the workflow system'
    
    def handle(self, *args, **options):
        node_types = [
            # Triggers
            {
                'name': 'webhook_trigger',
                'display_name': 'Webhook',
                'category': 'trigger',
                'description': 'Trigger workflow via HTTP webhook',
                'icon': 'fa-globe',
                'color': '#10b981',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'method',
                            'type': 'select',
                            'options': ['GET', 'POST', 'PUT', 'DELETE'],
                            'default': 'POST',
                            'label': 'HTTP Method',
                            'required': True
                        },
                        {
                            'name': 'path',
                            'type': 'text',
                            'placeholder': '/webhook/my-endpoint',
                            'label': 'Endpoint Path',
                            'required': True
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.trigger_handlers.WebhookTriggerHandler'
            },
            {
                'name': 'schedule_trigger',
                'display_name': 'Schedule',
                'category': 'trigger',
                'description': 'Trigger workflow on schedule',
                'icon': 'fa-clock',
                'color': '#f59e0b',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'cron',
                            'type': 'text',
                            'placeholder': '0 9 * * *',
                            'label': 'Cron Expression',
                            'required': True
                        },
                        {
                            'name': 'timezone',
                            'type': 'select',
                            'options': ['UTC', 'America/New_York', 'Europe/London'],
                            'default': 'UTC',
                            'label': 'Timezone'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.trigger_handlers.ScheduleTriggerHandler'
            },
            {
                'name': 'manual_trigger',
                'display_name': 'Manual',
                'category': 'trigger',
                'description': 'Manually trigger workflow',
                'icon': 'fa-hand-pointer',
                'color': '#6366f1',
                'config_schema': {'fields': []},
                'handler_class': 'apps.workflow_app.handlers.trigger_handlers.ManualTriggerHandler'
            },
            
            # Data Sources
            {
                'name': 'http_request',
                'display_name': 'HTTP Request',
                'category': 'data',
                'description': 'Make HTTP requests to APIs',
                'icon': 'fa-exchange-alt',
                'color': '#3b82f6',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'method',
                            'type': 'select',
                            'options': ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
                            'default': 'GET',
                            'label': 'Method'
                        },
                        {
                            'name': 'url',
                            'type': 'text',
                            'placeholder': 'https://api.example.com/data',
                            'label': 'URL',
                            'required': True
                        },
                        {
                            'name': 'headers',
                            'type': 'textarea',
                            'placeholder': '{"Content-Type": "application/json"}',
                            'label': 'Headers'
                        },
                        {
                            'name': 'body',
                            'type': 'textarea',
                            'placeholder': 'Request body',
                            'label': 'Body'
                        },
                        {
                            'name': 'timeout',
                            'type': 'number',
                            'default': 30,
                            'label': 'Timeout (seconds)'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.data_handlers.HttpRequestHandler'
            },
            {
                'name': 'database_query',
                'display_name': 'Database Query',
                'category': 'data',
                'description': 'Query database for data',
                'icon': 'fa-database',
                'color': '#8b5cf6',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'query_type',
                            'type': 'select',
                            'options': ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
                            'default': 'SELECT',
                            'label': 'Query Type'
                        },
                        {
                            'name': 'table_name',
                            'type': 'text',
                            'placeholder': 'users',
                            'label': 'Table Name',
                            'required': True
                        },
                        {
                            'name': 'conditions',
                            'type': 'text',
                            'placeholder': 'active = true',
                            'label': 'WHERE Conditions'
                        },
                        {
                            'name': 'fields',
                            'type': 'text',
                            'placeholder': '*',
                            'default': '*',
                            'label': 'Fields'
                        },
                        {
                            'name': 'limit',
                            'type': 'number',
                            'default': 100,
                            'label': 'Limit'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.data_handlers.DatabaseQueryHandler'
            },
            {
                'name': 'query_builder',
                'display_name': 'Advanced Query Builder',
                'category': 'data',
                'description': 'Build complex database queries with UI',
                'icon': 'fa-search',
                'color': '#7c3aed',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'tables',
                            'type': 'textarea',
                            'placeholder': '["users", "orders"]',
                            'label': 'Tables (JSON Array)',
                            'required': True
                        },
                        {
                            'name': 'columns',
                            'type': 'textarea',
                            'placeholder': '[{"column": "users.name", "alias": "user_name"}]',
                            'label': 'Columns (JSON Array)'
                        },
                        {
                            'name': 'joins',
                            'type': 'textarea',
                            'placeholder': '[{"left_table": "users", "right_table": "orders", "left_field": "id", "right_field": "user_id"}]',
                            'label': 'Joins (JSON Array)'
                        },
                        {
                            'name': 'where_conditions',
                            'type': 'textarea',
                            'placeholder': '{"condition": "AND", "rules": [{"field": "users.active", "operator": "=", "value": true}]}',
                            'label': 'WHERE Conditions (JSON)'
                        },
                        {
                            'name': 'limit',
                            'type': 'number',
                            'default': 100,
                            'label': 'Limit'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.data_handlers.QueryBuilderHandler'
            },
            
            # Transform
            {
                'name': 'data_transform',
                'display_name': 'Transform Data',
                'category': 'transform',
                'description': 'Transform and map data',
                'icon': 'fa-cogs',
                'color': '#059669',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'transform_type',
                            'type': 'select',
                            'options': ['map', 'filter', 'aggregate'],
                            'default': 'map',
                            'label': 'Transform Type'
                        },
                        {
                            'name': 'field_mappings',
                            'type': 'textarea',
                            'placeholder': '[{"source": "old_field", "target": "new_field"}]',
                            'label': 'Field Mappings'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.transform_handlers.DataTransformHandler'
            },
            {
                'name': 'json_parser',
                'display_name': 'JSON Parser',
                'category': 'transform',
                'description': 'Parse and manipulate JSON data',
                'icon': 'fa-code',
                'color': '#dc2626',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'operation',
                            'type': 'select',
                            'options': ['parse', 'stringify', 'extract'],
                            'default': 'parse',
                            'label': 'Operation'
                        },
                        {
                            'name': 'json_field',
                            'type': 'text',
                            'placeholder': 'data',
                            'default': 'data',
                            'label': 'JSON Field'
                        },
                        {
                            'name': 'fields',
                            'type': 'textarea',
                            'placeholder': '["field1", "field2.nested"]',
                            'label': 'Fields to Extract'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.transform_handlers.JsonParserHandler'
            },
            
            # Conditions
            {
                'name': 'condition',
                'display_name': 'Condition',
                'category': 'condition',
                'description': 'Branch workflow based on conditions',
                'icon': 'fa-code-branch',
                'color': '#ef4444',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'field',
                            'type': 'text',
                            'placeholder': 'data.status',
                            'label': 'Field Path',
                            'required': True
                        },
                        {
                            'name': 'operator',
                            'type': 'select',
                            'options': ['equals', 'not_equals', 'greater_than', 'less_than', 'contains', 'not_contains', 'is_empty', 'is_not_empty'],
                            'default': 'equals',
                            'label': 'Operator'
                        },
                        {
                            'name': 'value',
                            'type': 'text',
                            'placeholder': 'expected value',
                            'label': 'Value'
                        },
                        {
                            'name': 'logic_operator',
                            'type': 'select',
                            'options': ['AND', 'OR'],
                            'default': 'AND',
                            'label': 'Logic Operator'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.condition_handlers.ConditionHandler'
            },
            {
                'name': 'switch',
                'display_name': 'Switch',
                'category': 'condition',
                'description': 'Route to different paths based on value',
                'icon': 'fa-random',
                'color': '#f59e0b',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'switch_field',
                            'type': 'text',
                            'placeholder': 'data.type',
                            'label': 'Switch Field',
                            'required': True
                        },
                        {
                            'name': 'cases',
                            'type': 'textarea',
                            'placeholder': '{"case1": "output1", "case2": "output2", "default": "default_output"}',
                            'label': 'Cases (JSON)'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.condition_handlers.SwitchHandler'
            },
            
            # Actions
            {
                'name': 'email_send',
                'display_name': 'Send Email',
                'category': 'action',
                'description': 'Send email notifications',
                'icon': 'fa-envelope',
                'color': '#06b6d4',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'to',
                            'type': 'text',
                            'placeholder': 'user@example.com',
                            'label': 'To',
                            'required': True
                        },
                        {
                            'name': 'subject',
                            'type': 'text',
                            'placeholder': 'Email Subject',
                            'label': 'Subject',
                            'required': True
                        },
                        {
                            'name': 'body',
                            'type': 'textarea',
                            'placeholder': 'Email body content...',
                            'label': 'Body',
                            'required': True
                        },
                        {
                            'name': 'from_email',
                            'type': 'text',
                            'placeholder': 'noreply@example.com',
                            'label': 'From Email'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.EmailSendHandler'
            },
            {
                'name': 'slack_notification',
                'display_name': 'Slack Notification',
                'category': 'action',
                'description': 'Send Slack notifications',
                'icon': 'fa-slack',
                'color': '#4a154b',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'webhook_url',
                            'type': 'text',
                            'placeholder': 'https://hooks.slack.com/...',
                            'label': 'Webhook URL',
                            'required': True
                        },
                        {
                            'name': 'message',
                            'type': 'textarea',
                            'placeholder': 'Notification message',
                            'label': 'Message',
                            'required': True
                        },
                        {
                            'name': 'channel',
                            'type': 'text',
                            'placeholder': '#general',
                            'label': 'Channel'
                        },
                        {
                            'name': 'username',
                            'type': 'text',
                            'placeholder': 'Workflow Bot',
                            'default': 'Workflow Bot',
                            'label': 'Username'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.SlackNotificationHandler'
            },
            {
                'name': 'delay',
                'display_name': 'Delay',
                'category': 'action',
                'description': 'Add delay to workflow execution',
                'icon': 'fa-clock',
                'color': '#f59e0b',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'delay_seconds',
                            'type': 'number',
                            'default': 1,
                            'label': 'Delay (seconds)',
                            'required': True
                        },
                        {
                            'name': 'delay_type',
                            'type': 'select',
                            'options': ['fixed', 'random'],
                            'default': 'fixed',
                            'label': 'Delay Type'
                        },
                        {
                            'name': 'min_delay',
                            'type': 'number',
                            'default': 1,
                            'label': 'Min Delay (for random)'
                        },
                        {
                            'name': 'max_delay',
                            'type': 'number',
                            'default': 5,
                            'label': 'Max Delay (for random)'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.DelayHandler'
            },
            
            # Output
            {
                'name': 'database_save',
                'display_name': 'Save to Database',
                'category': 'output',
                'description': 'Save data to database',
                'icon': 'fa-save',
                'color': '#059669',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'table_name',
                            'type': 'text',
                            'placeholder': 'table_name',
                            'label': 'Table Name',
                            'required': True
                        },
                        {
                            'name': 'operation',
                            'type': 'select',
                            'options': ['insert', 'update', 'upsert'],
                            'default': 'insert',
                            'label': 'Operation'
                        },
                        {
                            'name': 'where_conditions',
                            'type': 'textarea',
                            'placeholder': '{"id": "{{input.id}}"}',
                            'label': 'WHERE Conditions (JSON)'
                        },
                        {
                            'name': 'unique_columns',
                            'type': 'text',
                            'placeholder': 'id,email',
                            'label': 'Unique Columns (for upsert)'
                        }
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
                'color': '#7c2d12',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'file_path',
                            'type': 'text',
                            'placeholder': '/tmp/export.json',
                            'label': 'File Path',
                            'required': True
                        },
                        {
                            'name': 'format',
                            'type': 'select',
                            'options': ['json', 'csv', 'txt'],
                            'default': 'json',
                            'label': 'Format'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.output_handlers.FileExportHandler'
            },
            {
                'name': 'webhook_send',
                'display_name': 'Send Webhook',
                'category': 'action',
                'description': 'Send webhook to external service',
                'icon': 'fa-paper-plane',
                'color': '#7c3aed',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'url',
                            'type': 'text',
                            'placeholder': 'https://api.example.com/webhook',
                            'label': 'URL',
                            'required': True
                        },
                        {
                            'name': 'method',
                            'type': 'select',
                            'options': ['POST', 'PUT', 'PATCH'],
                            'default': 'POST',
                            'label': 'Method'
                        },
                        {
                            'name': 'headers',
                            'type': 'textarea',
                            'placeholder': '{"Content-Type": "application/json"}',
                            'label': 'Headers'
                        },
                        {
                            'name': 'payload',
                            'type': 'textarea',
                            'placeholder': 'JSON payload',
                            'label': 'Payload'
                        },
                        {
                            'name': 'timeout',
                            'type': 'number',
                            'default': 30,
                            'label': 'Timeout (seconds)'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.WebhookSendHandler'
            },
            {
                'name': 'file_write',
                'display_name': 'Write File',
                'category': 'action',
                'description': 'Write data to file',
                'icon': 'fa-file-text',
                'color': '#6b7280',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'file_path',
                            'type': 'text',
                            'placeholder': '/tmp/output.txt',
                            'label': 'File Path',
                            'required': True
                        },
                        {
                            'name': 'content',
                            'type': 'textarea',
                            'placeholder': 'File content',
                            'label': 'Content'
                        },
                        {
                            'name': 'format',
                            'type': 'select',
                            'options': ['text', 'json'],
                            'default': 'text',
                            'label': 'Format'
                        },
                        {
                            'name': 'append',
                            'type': 'checkbox',
                            'default': False,
                            'label': 'Append Mode'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.FileWriteHandler'
            },
            {
                'name': 'log',
                'display_name': 'Log Message',
                'category': 'action',
                'description': 'Log messages for debugging',
                'icon': 'fa-file-text',
                'color': '#6b7280',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'message',
                            'type': 'textarea',
                            'placeholder': 'Log message',
                            'label': 'Message'
                        },
                        {
                            'name': 'level',
                            'type': 'select',
                            'options': ['info', 'warning', 'error', 'debug'],
                            'default': 'info',
                            'label': 'Log Level'
                        },
                        {
                            'name': 'include_data',
                            'type': 'checkbox',
                            'default': False,
                            'label': 'Include Input Data'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.action_handlers.LogHandler'
            },
            {
                'name': 'command_execution',
                'display_name': 'Execute Command',
                'category': 'action',
                'description': 'Execute system commands',
                'icon': 'fa-terminal',
                'color': '#374151',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'command',
                            'type': 'textarea',
                            'placeholder': 'echo "Hello World"',
                            'label': 'Command',
                            'required': True
                        },
                        {
                            'name': 'working_directory',
                            'type': 'text',
                            'placeholder': '/tmp',
                            'default': '/tmp',
                            'label': 'Working Directory'
                        },
                        {
                            'name': 'timeout',
                            'type': 'number',
                            'default': 300,
                            'label': 'Timeout (seconds)'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.command_handlers.CommandExecutionHandler'
            },
            {
                'name': 'response',
                'display_name': 'HTTP Response',
                'category': 'output',
                'description': 'Send HTTP response (for webhooks)',
                'icon': 'fa-reply',
                'color': '#0891b2',
                'config_schema': {
                    'fields': [
                        {
                            'name': 'status_code',
                            'type': 'number',
                            'default': 200,
                            'label': 'Status Code'
                        },
                        {
                            'name': 'response_data',
                            'type': 'textarea',
                            'placeholder': 'JSON response',
                            'label': 'Response Data'
                        },
                        {
                            'name': 'headers',
                            'type': 'textarea',
                            'placeholder': '{"Content-Type": "application/json"}',
                            'label': 'Headers'
                        }
                    ]
                },
                'handler_class': 'apps.workflow_app.handlers.output_handlers.ResponseHandler'
            }
        ]
        
        created_count = 0
        updated_count = 0
        
        for node_type_data in node_types:
            node_type, created = NodeType.objects.get_or_create(
                name=node_type_data['name'],
                defaults=node_type_data
            )
            
            if created:
                created_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f'Created node type: {node_type.display_name}')
                )
            else:
                # Update existing node type
                for key, value in node_type_data.items():
                    setattr(node_type, key, value)
                node_type.save()
                updated_count += 1
                self.stdout.write(
                    self.style.WARNING(f'Updated node type: {node_type.display_name}')
                )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully set up node types: {created_count} created, {updated_count} updated'
            )
        )
