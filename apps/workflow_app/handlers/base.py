"""
Base node handler class
"""
from abc import ABC, abstractmethod
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

class BaseNodeHandler(ABC):
    """
    Base class for all node handlers
    """
    
    def __init__(self):
        self.logger = logger
    
    @abstractmethod
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the node with given configuration and input data
        
        Args:
            config: Node configuration (resolved variables)
            input_data: Input data from previous nodes
            context: Execution context
            
        Returns:
            Dict containing execution result
        """
        pass
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """
        Validate node configuration
        
        Args:
            config: Node configuration to validate
            
        Returns:
            True if valid, raises exception if invalid
        """
        return True
    
    def get_required_fields(self) -> list:
        """
        Get list of required configuration fields
        
        Returns:
            List of required field names
        """
        return []
    
    def get_output_schema(self) -> Dict[str, Any]:
        """
        Get schema for node output
        
        Returns:
            Dict describing output schema
        """
        return {
            'type': 'object',
            'properties': {
                'data': {'type': 'object'},
                'success': {'type': 'boolean'},
                'message': {'type': 'string'}
            }
        }
    
    def log_execution(self, message: str, level: str = 'info'):
        """
        Log execution message
        
        Args:
            message: Message to log
            level: Log level (info, warning, error)
        """
        log_method = getattr(self.logger, level, self.logger.info)
        log_method(f"[{self.__class__.__name__}] {message}")
