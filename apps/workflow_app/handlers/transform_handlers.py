"""
Transform node handlers for data manipulation
"""
import json
import re
from typing import Dict, Any, List
from .base import BaseNodeHandler

class DataTransformHandler(BaseNodeHandler):
    """Handler for data transformation nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        transform_type = config.get('transform_type', 'map')
        field_mappings = config.get('field_mappings', [])
        
        data = input_data.get('data', {})
        
        if transform_type == 'map':
            return self._map_fields(data, field_mappings)
        elif transform_type == 'filter':
            return self._filter_data(data, config)
        elif transform_type == 'aggregate':
            return self._aggregate_data(data, config)
        else:
            raise ValueError(f"Unsupported transform type: {transform_type}")
    
    def _map_fields(self, data: Any, mappings: List[Dict]) -> Dict[str, Any]:
        """Map fields from input to output"""
        if isinstance(data, list):
            result = []
            for item in data:
                mapped_item = {}
                for mapping in mappings:
                    source_field = mapping.get('source')
                    target_field = mapping.get('target')
                    if source_field and target_field:
                        value = self._get_nested_value(item, source_field)
                        self._set_nested_value(mapped_item, target_field, value)
                result.append(mapped_item)
            return {'data': result, 'success': True, 'message': f'Mapped {len(result)} items'}
        else:
            mapped_data = {}
            for mapping in mappings:
                source_field = mapping.get('source')
                target_field = mapping.get('target')
                if source_field and target_field:
                    value = self._get_nested_value(data, source_field)
                    self._set_nested_value(mapped_data, target_field, value)
            return {'data': mapped_data, 'success': True, 'message': 'Data mapped successfully'}
    
    def _filter_data(self, data: Any, config: Dict) -> Dict[str, Any]:
        """Filter data based on conditions"""
        if not isinstance(data, list):
            data = [data]
        
        filter_field = config.get('filter_field', '')
        filter_operator = config.get('filter_operator', 'equals')
        filter_value = config.get('filter_value', '')
        
        filtered_data = []
        for item in data:
            item_value = self._get_nested_value(item, filter_field)
            if self._evaluate_condition(item_value, filter_operator, filter_value):
                filtered_data.append(item)
        
        return {
            'data': filtered_data,
            'success': True,
            'message': f'Filtered to {len(filtered_data)} items'
        }
    
    def _aggregate_data(self, data: Any, config: Dict) -> Dict[str, Any]:
        """Aggregate data"""
        if not isinstance(data, list):
            return {'data': data, 'success': True, 'message': 'No aggregation needed for single item'}
        
        agg_type = config.get('aggregation_type', 'count')
        agg_field = config.get('aggregation_field', '')
        
        if agg_type == 'count':
            result = len(data)
        elif agg_type == 'sum' and agg_field:
            result = sum(float(self._get_nested_value(item, agg_field) or 0) for item in data)
        elif agg_type == 'avg' and agg_field:
            values = [float(self._get_nested_value(item, agg_field) or 0) for item in data]
            result = sum(values) / len(values) if values else 0
        elif agg_type == 'min' and agg_field:
            values = [self._get_nested_value(item, agg_field) for item in data if self._get_nested_value(item, agg_field) is not None]
            result = min(values) if values else None
        elif agg_type == 'max' and agg_field:
            values = [self._get_nested_value(item, agg_field) for item in data if self._get_nested_value(item, agg_field) is not None]
            result = max(values) if values else None
        else:
            result = len(data)
        
        return {
            'data': {'result': result, 'type': agg_type, 'field': agg_field},
            'success': True,
            'message': f'Aggregated {len(data)} items using {agg_type}'
        }
    
    def _get_nested_value(self, data: Dict, path: str) -> Any:
        """Get nested value using dot notation"""
        if not path:
            return data
        
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
    
    def _set_nested_value(self, data: Dict, path: str, value: Any):
        """Set nested value using dot notation"""
        parts = path.split('.')
        current = data
        
        for part in parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        
        current[parts[-1]] = value
    
    def _evaluate_condition(self, value: Any, operator: str, expected: Any) -> bool:
        """Evaluate a condition"""
        if operator == 'equals':
            return value == expected
        elif operator == 'not_equals':
            return value != expected
        elif operator == 'contains':
            return str(expected).lower() in str(value).lower()
        elif operator == 'greater_than':
            return float(value or 0) > float(expected or 0)
        elif operator == 'less_than':
            return float(value or 0) < float(expected or 0)
        else:
            return False

class JsonParserHandler(BaseNodeHandler):
    """Handler for JSON parsing and manipulation"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        operation = config.get('operation', 'parse')
        
        if operation == 'parse':
            return self._parse_json(input_data, config)
        elif operation == 'stringify':
            return self._stringify_json(input_data, config)
        elif operation == 'extract':
            return self._extract_fields(input_data, config)
        else:
            raise ValueError(f"Unsupported JSON operation: {operation}")
    
    def _parse_json(self, input_data: Dict, config: Dict) -> Dict[str, Any]:
        """Parse JSON string to object"""
        json_field = config.get('json_field', 'data')
        data = input_data.get('data', {})
        
        json_string = self._get_nested_value(data, json_field)
        if not json_string:
            return {'data': {}, 'success': False, 'message': 'No JSON string found'}
        
        try:
            parsed_data = json.loads(json_string)
            return {
                'data': parsed_data,
                'success': True,
                'message': 'JSON parsed successfully'
            }
        except json.JSONDecodeError as e:
            return {
                'data': {},
                'success': False,
                'message': f'JSON parsing failed: {str(e)}'
            }
    
    def _stringify_json(self, input_data: Dict, config: Dict) -> Dict[str, Any]:
        """Convert object to JSON string"""
        data = input_data.get('data', {})
        
        try:
            json_string = json.dumps(data, indent=2)
            return {
                'data': {'json_string': json_string},
                'success': True,
                'message': 'Object converted to JSON string'
            }
        except Exception as e:
            return {
                'data': {},
                'success': False,
                'message': f'JSON stringify failed: {str(e)}'
            }
    
    def _extract_fields(self, input_data: Dict, config: Dict) -> Dict[str, Any]:
        """Extract specific fields from JSON data"""
        fields_to_extract = config.get('fields', [])
        data = input_data.get('data', {})
        
        extracted_data = {}
        for field in fields_to_extract:
            value = self._get_nested_value(data, field)
            if value is not None:
                extracted_data[field] = value
        
        return {
            'data': extracted_data,
            'success': True,
            'message': f'Extracted {len(extracted_data)} fields'
        }
    
    def _get_nested_value(self, data: Dict, path: str) -> Any:
        """Get nested value using dot notation"""
        if not path:
            return data
        
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
