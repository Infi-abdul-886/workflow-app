"""
Trigger node handlers
"""
from typing import Dict, Any
from .base import BaseNodeHandler

class WebhookTriggerHandler(BaseNodeHandler):
    """Handler for webhook trigger nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        # Webhook triggers are handled by the webhook receiver
        # This handler just passes through the webhook data
        
        webhook_data = context.get('webhook_data', {})
        request_headers = context.get('request_headers', {})
        
        return {
            'data': webhook_data,
            'headers': request_headers,
            'success': True,
            'message': 'Webhook trigger activated'
        }

class ScheduleTriggerHandler(BaseNodeHandler):
    """Handler for schedule trigger nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        # Schedule triggers are handled by the scheduler
        # This handler just provides context about the scheduled execution
        
        from django.utils import timezone
        
        return {
            'data': {
                'triggered_at': timezone.now().isoformat(),
                'cron_expression': config.get('cron_expression', ''),
                'timezone': config.get('timezone', 'UTC'),
                'scheduled': True
            },
            'success': True,
            'message': 'Schedule trigger activated'
        }

class ManualTriggerHandler(BaseNodeHandler):
    """Handler for manual trigger nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        # Manual triggers pass through the provided input data
        
        return {
            'data': input_data.get('workflow_input', {}),
            'success': True,
            'message': 'Manual trigger activated'
        }
