"""
Condition node handlers for workflow branching
"""
import json
from typing import Dict, Any, List
from .base import BaseNodeHandler
from ..utils import ExpressionEvaluator

class ConditionHandler(BaseNodeHandler):
    """Handler for condition nodes that branch workflow execution"""
    
    def __init__(self):
        super().__init__()
        self.expression_evaluator = ExpressionEvaluator()
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        conditions = config.get('conditions', [])
        logic_operator = config.get('logic_operator', 'AND').upper()
        
        if not conditions:
            raise ValueError("No conditions specified")
        
        # Parse conditions if string
        if isinstance(conditions, str):
            try:
                conditions = json.loads(conditions)
            except json.JSONDecodeError:
                raise ValueError("Invalid conditions format")
        
        if not isinstance(conditions, list):
            raise ValueError("Conditions must be a list")
        
        # Evaluate each condition
        condition_results = []
        for i, condition in enumerate(conditions):
            try:
                result = self._evaluate_condition(condition, input_data, context)
                condition_results.append(result)
                self.log_execution(f"Condition {i+1}: {result}")
            except Exception as e:
                self.log_execution(f"Condition {i+1} evaluation failed: {str(e)}", 'error')
                condition_results.append(False)
        
        # Apply logic operator
        if logic_operator == 'AND':
            final_result = all(condition_results)
        elif logic_operator == 'OR':
            final_result = any(condition_results)
        else:
            raise ValueError(f"Unsupported logic operator: {logic_operator}")
        
        self.log_execution(f"Final condition result: {final_result}")
        
        return {
            'data': {
                'condition_result': final_result,
                'individual_results': condition_results,
                'logic_operator': logic_operator
            },
            'success': True,
            'message': f"Condition evaluated to {final_result}",
            'branch_condition': final_result,  # Used by execution engine for branching
            'true_path': final_result,
            'false_path': not final_result
        }
    
    def _evaluate_condition(self, condition: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> bool:
        """
        Evaluate a single condition
        
        Args:
            condition: Condition definition
            input_data: Input data
            context: Execution context
            
        Returns:
            Boolean result of condition evaluation
        """
        field = condition.get('field', '')
        operator = condition.get('operator', 'equals')
        value = condition.get('value', '')
        
        if not field:
            raise ValueError("Condition field is required")
        
        # Get the actual value from input data
        actual_value = self._get_field_value(field, input_data, context)
        
        # Convert expected value to appropriate type
        expected_value = self._convert_value(value, actual_value)
        
        # Evaluate based on operator
        return self._apply_operator(actual_value, operator, expected_value)
    
    def _get_field_value(self, field_path: str, input_data: Dict[str, Any], context: Dict[str, Any]) -> Any:
        """
        Get value from field path (supports dot notation)
        
        Args:
            field_path: Path to field (e.g., 'data.user.name')
            input_data: Input data
            context: Execution context
            
        Returns:
            Field value
        """
        # Handle special prefixes
        if field_path.startswith('input.'):
            data = input_data.get('data', {})
            path = field_path[6:]  # Remove 'input.' prefix
        elif field_path.startswith('context.'):
            data = context
            path = field_path[8:]  # Remove 'context.' prefix
        else:
            data = input_data.get('data', {})
            path = field_path
        
        # Navigate through nested objects
        current = data
        for part in path.split('.'):
            if isinstance(current, dict) and part in current:
                current = current[part]
            elif isinstance(current, list) and part.isdigit():
                index = int(part)
                if 0 <= index < len(current):
                    current = current[index]
                else:
                    return None
            else:
                return None
        
        return current
    
    def _convert_value(self, value: Any, reference_value: Any) -> Any:
        """
        Convert value to match the type of reference value
        
        Args:
            value: Value to convert
            reference_value: Reference value for type matching
            
        Returns:
            Converted value
        """
        if reference_value is None:
            return value
        
        ref_type = type(reference_value)
        
        try:
            if ref_type == int:
                return int(value)
            elif ref_type == float:
                return float(value)
            elif ref_type == bool:
                if isinstance(value, str):
                    return value.lower() in ('true', '1', 'yes', 'on')
                return bool(value)
            else:
                return str(value)
        except (ValueError, TypeError):
            return value
    
    def _apply_operator(self, actual: Any, operator: str, expected: Any) -> bool:
        """
        Apply comparison operator
        
        Args:
            actual: Actual value
            operator: Comparison operator
            expected: Expected value
            
        Returns:
            Boolean result
        """
        operator = operator.lower()
        
        if operator == 'equals' or operator == '==':
            return actual == expected
        elif operator == 'not_equals' or operator == '!=':
            return actual != expected
        elif operator == 'greater_than' or operator == '>':
            return actual > expected
        elif operator == 'greater_than_or_equal' or operator == '>=':
            return actual >= expected
        elif operator == 'less_than' or operator == '<':
            return actual < expected
        elif operator == 'less_than_or_equal' or operator == '<=':
            return actual <= expected
        elif operator == 'contains':
            return str(expected).lower() in str(actual).lower()
        elif operator == 'not_contains':
            return str(expected).lower() not in str(actual).lower()
        elif operator == 'starts_with':
            return str(actual).lower().startswith(str(expected).lower())
        elif operator == 'ends_with':
            return str(actual).lower().endswith(str(expected).lower())
        elif operator == 'is_empty':
            return not actual or (isinstance(actual, (list, dict, str)) and len(actual) == 0)
        elif operator == 'is_not_empty':
            return bool(actual) and (not isinstance(actual, (list, dict, str)) or len(actual) > 0)
        else:
            raise ValueError(f"Unsupported operator: {operator}")

class SwitchHandler(BaseNodeHandler):
    """Handler for switch nodes that route to different paths based on value"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        switch_field = config.get('switch_field', '')
        cases = config.get('cases', {})
        
        if not switch_field:
            raise ValueError("Switch field is required")
        
        # Parse cases if string
        if isinstance(cases, str):
            try:
                cases = json.loads(cases)
            except json.JSONDecodeError:
                raise ValueError("Invalid cases format")
        
        if not isinstance(cases, dict):
            raise ValueError("Cases must be a dictionary")
        
        # Get the switch value
        switch_value = self._get_field_value(switch_field, input_data, context)
        
        # Find matching case
        matched_case = None
        output_path = None
        
        # Check for exact match first
        switch_value_str = str(switch_value)
        if switch_value_str in cases:
            matched_case = switch_value_str
            output_path = cases[switch_value_str]
        elif 'default' in cases:
            matched_case = 'default'
            output_path = cases['default']
        
        self.log_execution(f"Switch value '{switch_value}' matched case '{matched_case}'")
        
        result = {
            'data': {
                'switch_value': switch_value,
                'matched_case': matched_case,
                'output_path': output_path,
                'available_cases': list(cases.keys())
            },
            'success': True,
            'message': f"Switch routed to case '{matched_case}'"
        }
        
        # Add output paths for branching
        if output_path:
            result[output_path] = input_data.get('data', {})
        
        return result
    
    def _get_field_value(self, field_path: str, input_data: Dict[str, Any], context: Dict[str, Any]) -> Any:
        """Get value from field path (same as ConditionHandler)"""
        if field_path.startswith('input.'):
            data = input_data.get('data', {})
            path = field_path[6:]
        elif field_path.startswith('context.'):
            data = context
            path = field_path[8:]
        else:
            data = input_data.get('data', {})
            path = field_path
        
        current = data
        for part in path.split('.'):
            if isinstance(current, dict) and part in current:
                current = current[part]
            elif isinstance(current, list) and part.isdigit():
                index = int(part)
                if 0 <= index < len(current):
                    current = current[index]
                else:
                    return None
            else:
                return None
        
        return current
