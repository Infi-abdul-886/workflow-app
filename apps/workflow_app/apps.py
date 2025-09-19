from django.apps import AppConfig

class WorkflowAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.workflow_app'
    verbose_name = 'Workflow Management'

    def ready(self):
        # Import signal handlers
        try:
            import apps.workflow_app.signals
        except ImportError:
            pass
