from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.core.cache import cache
from .models import Workflow, WorkflowExecution, NodeType
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Workflow)
def workflow_saved(sender, instance, created, **kwargs):
    """Clear cache when workflow is saved"""
    cache_key = f"workflow_{instance.id}"
    cache.delete(cache_key)
    
    if created:
        logger.info(f"New workflow created: {instance.name} (ID: {instance.id})")
    else:
        logger.info(f"Workflow updated: {instance.name} (ID: {instance.id})")

@receiver(post_save, sender=WorkflowExecution)
def execution_saved(sender, instance, created, **kwargs):
    """Log execution status changes"""
    if created:
        logger.info(f"Execution started for workflow {instance.workflow.name}: {instance.id}")
    elif instance.status in ['completed', 'failed', 'cancelled']:
        logger.info(f"Execution {instance.status} for workflow {instance.workflow.name}: {instance.id}")

@receiver(post_delete, sender=Workflow)
def workflow_deleted(sender, instance, **kwargs):
    """Clean up when workflow is deleted"""
    cache_key = f"workflow_{instance.id}"
    cache.delete(cache_key)
    logger.info(f"Workflow deleted: {instance.name} (ID: {instance.id})")
