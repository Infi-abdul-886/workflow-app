"""
Data source node handlers with GRM database integration
"""
import json
import requests
from typing import Dict, Any
from django.db import connection
from .base import BaseNodeHandler
from django.apps import apps

class DatabaseQueryHandler(BaseNodeHandler):
    """Handler for database query nodes with GRM models integration"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        query_type = config.get('query_type', 'SELECT').upper()
        table_name = config.get('table_name', '')
        conditions = config.get('conditions', '')
        fields = config.get('fields', '*')
        limit = config.get('limit', 100)
        
        if not table_name:
            raise ValueError("Table name is required")
        
        # Build query based on type
        if query_type == 'SELECT':
            query = f"SELECT {fields} FROM {table_name}"
            params = []
            
            if conditions:
                # Handle parameterized conditions from input data
                resolved_conditions = self._resolve_conditions(conditions, input_data)
                query += f" WHERE {resolved_conditions['sql']}"
                params = resolved_conditions['params']
            
            if limit:
                query += f" LIMIT {limit}"
                
        elif query_type == 'INSERT':
            # For INSERT, expect data in input
            data = input_data.get('data', {})
            if not data:
                raise ValueError("No data provided for INSERT operation")
            
            if isinstance(data, list):
                # Bulk insert
                if not data:
                    return {'data': {'affected_rows': 0}, 'success': True, 'message': 'No data to insert'}
                
                columns = list(data[0].keys())
                placeholders = ', '.join(['%s'] * len(columns))
                columns_str = ', '.join(columns)
                
                query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
                params = [[item.get(col) for col in columns] for item in data]
            else:
                # Single insert
                columns = list(data.keys())
                placeholders = ', '.join(['%s'] * len(columns))
                columns_str = ', '.join(columns)
                
                query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
                params = [data[col] for col in columns]
                
        elif query_type == 'UPDATE':
            data = input_data.get('data', {})
            if not data or not conditions:
                raise ValueError("Data and conditions are required for UPDATE operation")
            
            # Build SET clause
            set_columns = [col for col in data.keys()]
            set_clause = ', '.join([f"{col} = %s" for col in set_columns])
            
            # Build WHERE clause
            resolved_conditions = self._resolve_conditions(conditions, input_data)
            
            query = f"UPDATE {table_name} SET {set_clause} WHERE {resolved_conditions['sql']}"
            params = [data[col] for col in set_columns] + resolved_conditions['params']
            
        elif query_type == 'DELETE':
            if not conditions:
                raise ValueError("Conditions are required for DELETE operation")
            
            resolved_conditions = self._resolve_conditions(conditions, input_data)
            query = f"DELETE FROM {table_name} WHERE {resolved_conditions['sql']}"
            params = resolved_conditions['params']
        else:
            raise ValueError(f"Unsupported query type: {query_type}")
        
        try:
            with connection.cursor() as cursor:
                if query_type == 'SELECT':
                    cursor.execute(query, params)
                    columns = [col[0] for col in cursor.description]
                    results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                    
                    return {
                        'data': results,
                        'count': len(results),
                        'success': True,
                        'message': f"Retrieved {len(results)} records"
                    }
                elif query_type == 'INSERT' and isinstance(input_data.get('data'), list):
                    cursor.executemany(query, params)
                    affected_rows = cursor.rowcount
                    
                    return {
                        'data': {'affected_rows': affected_rows},
                        'success': True,
                        'message': f"Inserted {affected_rows} rows"
                    }
                else:
                    cursor.execute(query, params)
                    affected_rows = cursor.rowcount
                    
                    return {
                        'data': {'affected_rows': affected_rows},
                        'success': True,
                        'message': f"{query_type} operation affected {affected_rows} rows"
                    }
                    
        except Exception as e:
            self.log_execution(f"Database query failed: {str(e)}", 'error')
            raise ValueError(f"Database query failed: {str(e)}")
    
    def _resolve_conditions(self, conditions: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Resolve conditions with input data parameters"""
        import re
        
        # Find all {{variable}} patterns
        pattern = r'\{\{([^}]+)\}\}'
        matches = re.findall(pattern, conditions)
        
        resolved_sql = conditions
        params = []
        
        for match in matches:
            # Get value from input data
            value = self._get_nested_value(input_data.get('data', {}), match.strip())
            
            # Replace with placeholder
            resolved_sql = resolved_sql.replace(f'{{{{{match}}}}}', '%s')
            params.append(value)
        
        return {'sql': resolved_sql, 'params': params}
    
    def _get_nested_value(self, data: Dict[str, Any], path: str) -> Any:
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

class HttpRequestHandler(BaseNodeHandler):
    """Handler for HTTP request nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        method = config.get('method', 'GET').upper()
        url = config.get('url', '')
        headers = config.get('headers', {})
        body = config.get('body', '')
        timeout = config.get('timeout', 30)
        
        if not url:
            raise ValueError("URL is required")
        
        # Parse headers if string
        if isinstance(headers, str):
            try:
                headers = json.loads(headers) if headers else {}
            except json.JSONDecodeError:
                headers = {}
        
        # Parse body if string
        request_body = None
        if body:
            if isinstance(body, str):
                try:
                    request_body = json.loads(body)
                except json.JSONDecodeError:
                    request_body = body
            else:
                request_body = body
        elif method in ['POST', 'PUT', 'PATCH']:
            # Use input data as body if not specified
            request_body = input_data.get('data', {})
        
        try:
            self.log_execution(f"Making {method} request to {url}")
            
            response = requests.request(
                method=method,
                url=url,
                headers=headers,
                json=request_body if isinstance(request_body, (dict, list)) else None,
                data=request_body if isinstance(request_body, str) else None,
                timeout=timeout
            )
            
            # Try to parse JSON response
            try:
                response_data = response.json()
            except:
                response_data = response.text
            
            result = {
                'data': response_data,
                'status_code': response.status_code,
                'headers': dict(response.headers),
                'success': response.status_code < 400,
                'message': f"HTTP {method} request completed with status {response.status_code}"
            }
            
            if not result['success']:
                self.log_execution(f"HTTP request failed with status {response.status_code}", 'warning')
            
            return result
            
        except requests.exceptions.Timeout:
            raise ValueError(f"HTTP request timed out after {timeout} seconds")
        except requests.exceptions.RequestException as e:
            raise ValueError(f"HTTP request failed: {str(e)}")

class GRMDataHandler(BaseNodeHandler):
    """Handler for GRM specific data operations"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        operation = config.get('operation', 'get_requests')
        
        if operation == 'get_requests':
            return self._get_request_data(config, input_data)
        elif operation == 'get_passengers':
            return self._get_passenger_data(config, input_data)
        elif operation == 'get_transactions':
            return self._get_transaction_data(config, input_data)
        elif operation == 'update_pnr_status':
            return self._update_pnr_status(config, input_data)
        else:
            raise ValueError(f"Unsupported GRM operation: {operation}")
    
    def _get_request_data(self, config: Dict[str, Any], input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Get request master data"""
        filters = config.get('filters', {})
        limit = config.get('limit', 100)
        
        query = """
            SELECT rm.request_master_id, rm.request_type, rm.trip_type, rm.requested_date,
                   rm.number_of_passenger, rm.request_fare, rm.view_status,
                   ud.first_name, ud.last_name, ud.email_id,
                   cd.corporate_name
            FROM request_master rm
            LEFT JOIN user_details ud ON rm.user_id = ud.user_id
            LEFT JOIN corporate_details cd ON ud.corporate_id = cd.corporate_id
            WHERE 1=1
        """
        
        params = []
        
        # Apply filters from input data
        if 'user_id' in input_data.get('data', {}):
            query += " AND rm.user_id = %s"
            params.append(input_data['data']['user_id'])
        
        if 'status' in filters:
            query += " AND rm.view_status = %s"
            params.append(filters['status'])
        
        if 'date_from' in filters:
            query += " AND rm.requested_date >= %s"
            params.append(filters['date_from'])
        
        query += f" ORDER BY rm.requested_date DESC LIMIT {limit}"
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(query, params)
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return {
                    'data': results,
                    'count': len(results),
                    'success': True,
                    'message': f"Retrieved {len(results)} requests"
                }
        except Exception as e:
            raise ValueError(f"Failed to get request data: {str(e)}")
    
    def _get_passenger_data(self, config: Dict[str, Any], input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Get passenger details"""
        request_master_id = input_data.get('data', {}).get('request_master_id')
        
        if not request_master_id:
            raise ValueError("request_master_id is required")
        
        query = """
            SELECT pd.passenger_id, pd.first_name, pd.last_name, pd.age,
                   pd.pax_email_id, pd.pax_mobile_number, pd.passenger_type,
                   pd.pnr, arm.airlines_request_id
            FROM passenger_details pd
            LEFT JOIN airlines_request_mapping arm ON pd.airlines_request_id = arm.airlines_request_id
            WHERE arm.request_master_id = %s
            ORDER BY pd.passenger_id
        """
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(query, [request_master_id])
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return {
                    'data': results,
                    'count': len(results),
                    'success': True,
                    'message': f"Retrieved {len(results)} passengers"
                }
        except Exception as e:
            raise ValueError(f"Failed to get passenger data: {str(e)}")
    
    def _get_transaction_data(self, config: Dict[str, Any], input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Get transaction details"""
        airlines_request_id = input_data.get('data', {}).get('airlines_request_id')
        
        if not airlines_request_id:
            raise ValueError("airlines_request_id is required")
        
        query = """
            SELECT tm.transaction_id, tm.fare_advised, tm.child_fare, tm.infant_fare,
                   tm.exchange_rate, tm.transaction_date, tm.fare_expiry_date,
                   tm.payment_expiry_date, tm.active_status
            FROM transaction_master tm
            WHERE tm.airlines_request_id = %s
            ORDER BY tm.transaction_date DESC
        """
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(query, [airlines_request_id])
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return {
                    'data': results,
                    'count': len(results),
                    'success': True,
                    'message': f"Retrieved {len(results)} transactions"
                }
        except Exception as e:
            raise ValueError(f"Failed to get transaction data: {str(e)}")
    
    def _update_pnr_status(self, config: Dict[str, Any], input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update PNR status"""
        pnr = input_data.get('data', {}).get('pnr')
        new_status = config.get('status', 'HK')
        
        if not pnr:
            raise ValueError("PNR is required")
        
        query = """
            UPDATE series_request_details 
            SET flight_status = %s 
            WHERE pnr = %s
        """
        
        try:
            with connection.cursor() as cursor:
                cursor.execute(query, [new_status, pnr])
                affected_rows = cursor.rowcount
                
                return {
                    'data': {'affected_rows': affected_rows, 'pnr': pnr, 'status': new_status},
                    'success': True,
                    'message': f"Updated PNR {pnr} status to {new_status}"
                }
        except Exception as e:
            raise ValueError(f"Failed to update PNR status: {str(e)}")

class QueryBuilderHandler(BaseNodeHandler):
    """Handler for advanced query builder nodes"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        try:
            # Parse configuration
            tables = self._parse_json_field(config.get('tables', []))
            columns = self._parse_json_field(config.get('columns', []))
            joins = self._parse_json_field(config.get('joins', []))
            where_conditions = self._parse_json_field(config.get('where_conditions', {}))
            limit = config.get('limit', 100)
            
            if not tables:
                raise ValueError("At least one table is required")
            
            # Build SQL query
            query_parts = []
            params = []
            
            # SELECT clause
            if columns:
                select_parts = []
                for col in columns:
                    if isinstance(col, dict):
                        column_name = col.get('column', '')
                        alias = col.get('alias', '')
                        if column_name:
                            if alias:
                                select_parts.append(f"`{column_name}` AS `{alias}`")
                            else:
                                select_parts.append(f"`{column_name}`")
                    elif isinstance(col, str):
                        select_parts.append(f"`{col}`")
                
                if select_parts:
                    query_parts.append(f"SELECT {', '.join(select_parts)}")
                else:
                    query_parts.append("SELECT *")
            else:
                query_parts.append("SELECT *")
            
            # FROM clause
            base_table = tables[0]
            query_parts.append(f"FROM `{base_table}`")
            
            # JOIN clauses
            if joins:
                for join in joins:
                    if isinstance(join, dict):
                        left_table = join.get('left_table', '')
                        right_table = join.get('right_table', '')
                        left_field = join.get('left_field', '')
                        right_field = join.get('right_field', '')
                        
                        if all([left_table, right_table, left_field, right_field]):
                            query_parts.append(
                                f"LEFT JOIN `{right_table}` ON `{left_table}`.`{left_field}` = `{right_table}`.`{right_field}`"
                            )
            
            # WHERE clause
            if where_conditions and isinstance(where_conditions, dict):
                where_sql, where_params = self._build_where_clause(where_conditions, input_data)
                if where_sql:
                    query_parts.append(f"WHERE {where_sql}")
                    params.extend(where_params)
            
            # LIMIT clause
            if limit:
                query_parts.append(f"LIMIT {int(limit)}")
            
            # Execute query
            final_query = ' '.join(query_parts)
            
            with connection.cursor() as cursor:
                cursor.execute(final_query, params)
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            return {
                'data': results,
                'count': len(results),
                'query': final_query,
                'success': True,
                'message': f'Query executed successfully, returned {len(results)} rows'
            }
            
        except Exception as e:
            self.log_execution(f"Query builder execution failed: {str(e)}", 'error')
            raise ValueError(f"Query execution failed: {str(e)}")
    
    def _parse_json_field(self, value):
        """Parse JSON field value"""
        if isinstance(value, str):
            try:
                return json.loads(value) if value.strip() else ([] if '[' in value or value == '' else {})
            except json.JSONDecodeError:
                return [] if isinstance(value, str) and ('[' in value or value == '') else {}
        return value if value is not None else []
    
    def _build_where_clause(self, conditions, input_data):
        """Build WHERE clause from conditions object"""
        if not conditions or not conditions.get('rules'):
            return "", []
        
        condition_type = conditions.get('condition', 'AND').upper()
        rules = conditions.get('rules', [])
        
        sql_parts = []
        params = []
        
        for rule in rules:
            if isinstance(rule, dict):
                field = rule.get('field', '')
                operator = rule.get('operator', '=')
                value = rule.get('value')
                
                # Resolve value from input data if it's a variable
                if isinstance(value, str) and value.startswith('{{') and value.endswith('}}'):
                    var_path = value[2:-2].strip()
                    value = self._get_nested_value(input_data.get('data', {}), var_path)
                
                if field and operator and value is not None:
                    # Handle different operators
                    if operator.upper() in ['IN', 'NOT IN']:
                        if isinstance(value, list):
                            placeholders = ', '.join(['%s'] * len(value))
                            sql_parts.append(f"`{field}` {operator.upper()} ({placeholders})")
                            params.extend(value)
                    elif operator.upper() in ['IS NULL', 'IS NOT NULL']:
                        sql_parts.append(f"`{field}` {operator.upper()}")
                    else:
                        sql_parts.append(f"`{field}` {operator} %s")
                        params.append(value)
        
        if sql_parts:
            return f" {condition_type} ".join(sql_parts), params
        
        return "", []
    
    def _get_nested_value(self, data: Dict[str, Any], path: str) -> Any:
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