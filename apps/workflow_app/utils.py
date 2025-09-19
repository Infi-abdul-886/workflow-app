"""
Utility classes for workflow execution
"""
import re
import json
from typing import Dict, Any, Optional
from django.template import Template, Context
from django.template.engine import Engine

class VariableResolver:
    """Resolves variables and expressions in configuration strings"""
    
    def __init__(self):
        self.variable_pattern = re.compile(r'\{\{([^}]+)\}\}')
    
    def resolve(self, value: str, context: Dict[str, Any], input_data: Dict[str, Any]) -> str:
        """
        Resolve variables in a string value
        
        Args:
            value: String containing variables to resolve
            context: Execution context
            input_data: Input data from previous nodes
            
        Returns:
            String with resolved variables
        """
        if not isinstance(value, str):
            return value
        
        def replace_variable(match):
            var_expression = match.group(1).strip()
            return str(self._evaluate_expression(var_expression, context, input_data))
        
        return self.variable_pattern.sub(replace_variable, value)
    
    def _evaluate_expression(self, expression: str, context: Dict[str, Any], input_data: Dict[str, Any]) -> Any:
        """
        Evaluate a variable expression
        
        Args:
            expression: Variable expression to evaluate
            context: Execution context
            input_data: Input data
            
        Returns:
            Evaluated value
        """
        # Handle special variables
        if expression == 'now()':
            from django.utils import timezone
            return timezone.now().isoformat()
        elif expression == 'timestamp':
            import time
            return str(int(time.time()))
        elif expression.startswith('env.'):
            import os
            env_var = expression[4:]
            return os.getenv(env_var, '')
        
        # Handle input data references
        if expression.startswith('input.'):
            return self._get_nested_value(input_data.get('data', {}), expression[6:])
        elif expression.startswith('context.'):
            return self._get_nested_value(context, expression[8:])
        elif expression.startswith('variables.'):
            return self._get_nested_value(context.get('variables', {}), expression[10:])
        
        # Default to looking in input data
        return self._get_nested_value(input_data.get('data', {}), expression)
    
    def _get_nested_value(self, data: Dict[str, Any], path: str) -> Any:
        """
        Get nested value using dot notation
        
        Args:
            data: Data dictionary
            path: Dot-separated path
            
        Returns:
            Value at path or empty string if not found
        """
        current = data
        for part in path.split('.'):
            if isinstance(current, dict) and part in current:
                current = current[part]
            elif isinstance(current, list) and part.isdigit():
                index = int(part)
                if 0 <= index < len(current):
                    current = current[index]
                else:
                    return ''
            else:
                return ''
        
        return current

class ExpressionEvaluator:
    """Safely evaluates expressions in workflow configurations"""
    
    def __init__(self):
        self.allowed_functions = {
            'len': len,
            'str': str,
            'int': int,
            'float': float,
            'bool': bool,
            'abs': abs,
            'min': min,
            'max': max,
            'sum': sum,
            'round': round,
        }
    
    def evaluate(self, expression: str, context: Dict[str, Any]) -> Any:
        """
        Safely evaluate an expression
        
        Args:
            expression: Expression to evaluate
            context: Context variables
            
        Returns:
            Evaluated result
        """
        # This is a simplified evaluator
        # In production, you'd want a more robust and secure expression evaluator
        try:
            # Create a safe evaluation context
            safe_context = {
                '__builtins__': {},
                **self.allowed_functions,
                **context
            }
            
            # Evaluate the expression
            return eval(expression, safe_context)
        except Exception as e:
            # Return the original expression if evaluation fails
            return expression

class DataValidator:
    """Validates data against schemas"""
    
    @staticmethod
    def validate_json_schema(data: Any, schema: Dict[str, Any]) -> bool:
        """
        Validate data against a JSON schema
        
        Args:
            data: Data to validate
            schema: JSON schema
            
        Returns:
            True if valid, False otherwise
        """
        # Simplified validation - in production use jsonschema library
        try:
            if schema.get('type') == 'object' and not isinstance(data, dict):
                return False
            elif schema.get('type') == 'array' and not isinstance(data, list):
                return False
            elif schema.get('type') == 'string' and not isinstance(data, str):
                return False
            elif schema.get('type') == 'number' and not isinstance(data, (int, float)):
                return False
            elif schema.get('type') == 'boolean' and not isinstance(data, bool):
                return False
            
            return True
        except:
            return False
