"""
Node handlers for different node types
"""
from typing import Dict, Any, Optional
from .base import BaseNodeHandler
from .trigger_handlers import WebhookTriggerHandler, ScheduleTriggerHandler, ManualTriggerHandler
from .data_handlers import DatabaseQueryHandler, HttpRequestHandler, GRMDataHandler, QueryBuilderHandler
from .transform_handlers import DataTransformHandler, JsonParserHandler
from .condition_handlers import ConditionHandler, SwitchHandler
from .action_handlers import EmailSendHandler, SlackNotificationHandler, DelayHandler, WebhookSendHandler, FileWriteHandler, LogHandler
from .output_handlers import DatabaseSaveHandler, FileExportHandler, ResponseHandler
from .command_handlers import CommandExecutionHandler, FileOperationHandler

# Registry of all node handlers
NODE_HANDLERS = {
    # Trigger handlers
    'webhook_trigger': WebhookTriggerHandler,
    'schedule_trigger': ScheduleTriggerHandler,
    'manual_trigger': ManualTriggerHandler,
    
    # Data handlers
    'database_query': DatabaseQueryHandler,
    'http_request': HttpRequestHandler,
    'grm_data': GRMDataHandler,
    'query_builder': QueryBuilderHandler,
    
    # Transform handlers
    'data_transform': DataTransformHandler,
    'json_parser': JsonParserHandler,
    
    # Condition handlers
    'condition': ConditionHandler,
    'switch': SwitchHandler,
    
    # Action handlers
    'email_send': EmailSendHandler,
    'slack_notification': SlackNotificationHandler,
    'delay': DelayHandler,
    'webhook_send': WebhookSendHandler,
    'file_write': FileWriteHandler,
    'log': LogHandler,
    
    # Output handlers
    'database_save': DatabaseSaveHandler,
    'file_export': FileExportHandler,
    'response': ResponseHandler,
    
    # Command handlers
    'command_execution': CommandExecutionHandler,
    'file_operation': FileOperationHandler,
}

def get_node_handler(node_type: str) -> Optional[BaseNodeHandler]:
    """
    Get a node handler instance for the given node type
    
    Args:
        node_type: Type of node to get handler for
        
    Returns:
        BaseNodeHandler instance or None if not found
    """
    handler_class = NODE_HANDLERS.get(node_type)
    if handler_class:
        return handler_class()
    return None

def register_node_handler(node_type: str, handler_class: type):
    """
    Register a new node handler
    
    Args:
        node_type: Type of node
        handler_class: Handler class to register
    """
    NODE_HANDLERS[node_type] = handler_class

def get_available_node_types() -> list:
    """
    Get list of all available node types
    
    Returns:
        List of node type names
    """
    return list(NODE_HANDLERS.keys())