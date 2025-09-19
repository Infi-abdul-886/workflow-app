"""
Output node handlers for saving and exporting data
"""
import json
import csv
import io
from typing import Dict, Any
from django.db import connection
from .base import BaseNodeHandler

class DatabaseSaveHandler(BaseNodeHandler):
    """Handler for saving data to database"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        table_name = config.get('table_name', '')
        operation = config.get('operation', 'insert')
        data = input_data.get('data', {})
        
        if not table_name:
            raise ValueError("Table name is required")
        
        if not data:
            raise ValueError("No data to save")
        
        try:
            with connection.cursor() as cursor:
                if operation == 'insert':
                    return self._insert_data(cursor, table_name, data)
                elif operation == 'update':
                    return self._update_data(cursor, table_name, data, config)
                elif operation == 'upsert':
                    return self._upsert_data(cursor, table_name, data, config)
                else:
                    raise ValueError(f"Unsupported operation: {operation}")
                    
        except Exception as e:
            self.log_execution(f"Database save failed: {str(e)}", 'error')
            raise ValueError(f"Database operation failed: {str(e)}")
    
    def _insert_data(self, cursor, table_name: str, data: Any) -> Dict[str, Any]:
        """Insert data into table"""
        if isinstance(data, list):
            # Bulk insert
            if not data:
                return {'data': {'affected_rows': 0}, 'success': True, 'message': 'No data to insert'}
            
            # Use first item to determine columns
            columns = list(data[0].keys())
            placeholders = ', '.join(['%s'] * len(columns))
            columns_str = ', '.join(columns)
            
            query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
            
            values = []
            for item in data:
                values.append([item.get(col) for col in columns])
            
            cursor.executemany(query, values)
            affected_rows = cursor.rowcount
            
        else:
            # Single insert
            columns = list(data.keys())
            placeholders = ', '.join(['%s'] * len(columns))
            columns_str = ', '.join(columns)
            
            query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
            values = [data[col] for col in columns]
            
            cursor.execute(query, values)
            affected_rows = cursor.rowcount
        
        return {
            'data': {'affected_rows': affected_rows},
            'success': True,
            'message': f'Inserted {affected_rows} rows into {table_name}'
        }
    
    def _update_data(self, cursor, table_name: str, data: Dict, config: Dict) -> Dict[str, Any]:
        """Update data in table"""
        where_conditions = config.get('where_conditions', {})
        
        if not where_conditions:
            raise ValueError("WHERE conditions are required for UPDATE operation")
        
        # Build SET clause
        set_columns = [col for col in data.keys() if col not in where_conditions.keys()]
        set_clause = ', '.join([f"{col} = %s" for col in set_columns])
        
        # Build WHERE clause
        where_clause = ' AND '.join([f"{col} = %s" for col in where_conditions.keys()])
        
        query = f"UPDATE {table_name} SET {set_clause} WHERE {where_clause}"
        
        # Prepare values
        values = [data[col] for col in set_columns] + [where_conditions[col] for col in where_conditions.keys()]
        
        cursor.execute(query, values)
        affected_rows = cursor.rowcount
        
        return {
            'data': {'affected_rows': affected_rows},
            'success': True,
            'message': f'Updated {affected_rows} rows in {table_name}'
        }
    
    def _upsert_data(self, cursor, table_name: str, data: Dict, config: Dict) -> Dict[str, Any]:
        """Insert or update data (upsert)"""
        unique_columns = config.get('unique_columns', [])
        
        if not unique_columns:
            # Fallback to insert
            return self._insert_data(cursor, table_name, data)
        
        # Check if record exists
        where_clause = ' AND '.join([f"{col} = %s" for col in unique_columns])
        check_query = f"SELECT COUNT(*) FROM {table_name} WHERE {where_clause}"
        check_values = [data[col] for col in unique_columns]
        
        cursor.execute(check_query, check_values)
        exists = cursor.fetchone()[0] > 0
        
        if exists:
            # Update
            where_conditions = {col: data[col] for col in unique_columns}
            return self._update_data(cursor, table_name, data, {'where_conditions': where_conditions})
        else:
            # Insert
            return self._insert_data(cursor, table_name, data)

class FileExportHandler(BaseNodeHandler):
    """Handler for exporting data to files"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        file_path = config.get('file_path', '')
        file_format = config.get('format', 'json')
        data = input_data.get('data', {})
        
        if not file_path:
            raise ValueError("File path is required")
        
        try:
            if file_format == 'json':
                return self._export_json(file_path, data)
            elif file_format == 'csv':
                return self._export_csv(file_path, data)
            elif file_format == 'txt':
                return self._export_text(file_path, data)
            else:
                raise ValueError(f"Unsupported file format: {file_format}")
                
        except Exception as e:
            self.log_execution(f"File export failed: {str(e)}", 'error')
            raise ValueError(f"File export failed: {str(e)}")
    
    def _export_json(self, file_path: str, data: Any) -> Dict[str, Any]:
        """Export data as JSON"""
        import os
        
        # Ensure directory exists
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'format': 'json',
                'file_size': file_size
            },
            'success': True,
            'message': f'Data exported to JSON file: {file_path}'
        }
    
    def _export_csv(self, file_path: str, data: Any) -> Dict[str, Any]:
        """Export data as CSV"""
        import os
        
        if not isinstance(data, list):
            data = [data]
        
        if not data:
            raise ValueError("No data to export")
        
        # Ensure directory exists
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        # Get all unique keys from all items
        fieldnames = set()
        for item in data:
            if isinstance(item, dict):
                fieldnames.update(item.keys())
        
        fieldnames = sorted(list(fieldnames))
        
        with open(file_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            
            for item in data:
                if isinstance(item, dict):
                    writer.writerow(item)
                else:
                    # Convert non-dict items to dict
                    writer.writerow({'value': str(item)})
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'format': 'csv',
                'file_size': file_size,
                'rows_exported': len(data)
            },
            'success': True,
            'message': f'Data exported to CSV file: {file_path} ({len(data)} rows)'
        }
    
    def _export_text(self, file_path: str, data: Any) -> Dict[str, Any]:
        """Export data as text"""
        import os
        
        # Ensure directory exists
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        # Convert data to string
        if isinstance(data, (dict, list)):
            content = json.dumps(data, indent=2, ensure_ascii=False)
        else:
            content = str(data)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'format': 'text',
                'file_size': file_size
            },
            'success': True,
            'message': f'Data exported to text file: {file_path}'
        }

class ResponseHandler(BaseNodeHandler):
    """Handler for sending HTTP responses (for webhook workflows)"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        status_code = config.get('status_code', 200)
        response_data = config.get('response_data', {})
        headers = config.get('headers', {})
        
        # Use input data as response if not specified
        if not response_data:
            response_data = input_data.get('data', {})
        
        # Store response in context for webhook handler to use
        context['http_response'] = {
            'status_code': status_code,
            'data': response_data,
            'headers': headers
        }
        
        return {
            'data': {
                'status_code': status_code,
                'response_data': response_data,
                'headers': headers
            },
            'success': True,
            'message': f'HTTP response prepared with status {status_code}'
        }
