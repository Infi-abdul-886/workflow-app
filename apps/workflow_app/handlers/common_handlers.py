"""
Command execution handlers for system operations
"""
import subprocess
import os
import time
from typing import Dict, Any
from .base import BaseNodeHandler

class CommandExecutionHandler(BaseNodeHandler):
    """Handler for executing system commands"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        command = config.get('command', '')
        working_directory = config.get('working_directory', '/tmp')
        timeout = config.get('timeout', 300)
        shell = config.get('shell', True)
        
        if not command:
            raise ValueError("Command is required")
        
        try:
            self.log_execution(f"Executing command: {command}")
            
            # Change to working directory if specified
            original_cwd = os.getcwd()
            if working_directory and os.path.exists(working_directory):
                os.chdir(working_directory)
            
            start_time = time.time()
            
            # Execute command
            result = subprocess.run(
                command,
                shell=shell,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=working_directory if os.path.exists(working_directory) else None
            )
            
            execution_time = time.time() - start_time
            
            # Restore original working directory
            os.chdir(original_cwd)
            
            return {
                'data': {
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'return_code': result.returncode,
                    'execution_time': execution_time,
                    'command': command,
                    'working_directory': working_directory
                },
                'success': result.returncode == 0,
                'message': f'Command executed with return code {result.returncode}'
            }
            
        except subprocess.TimeoutExpired:
            os.chdir(original_cwd)
            raise ValueError(f"Command timed out after {timeout} seconds")
        except Exception as e:
            os.chdir(original_cwd)
            self.log_execution(f"Command execution failed: {str(e)}", 'error')
            raise ValueError(f"Command execution failed: {str(e)}")

class FileOperationHandler(BaseNodeHandler):
    """Handler for file operations"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        operation = config.get('operation', 'read')
        file_path = config.get('file_path', '')
        content = config.get('content', '')
        encoding = config.get('encoding', 'utf-8')
        
        if not file_path:
            raise ValueError("File path is required")
        
        try:
            if operation == 'read':
                return self._read_file(file_path, encoding)
            elif operation == 'write':
                return self._write_file(file_path, content or str(input_data.get('data', '')), encoding)
            elif operation == 'append':
                return self._append_file(file_path, content or str(input_data.get('data', '')), encoding)
            elif operation == 'delete':
                return self._delete_file(file_path)
            elif operation == 'exists':
                return self._check_file_exists(file_path)
            else:
                raise ValueError(f"Unsupported file operation: {operation}")
                
        except Exception as e:
            self.log_execution(f"File operation failed: {str(e)}", 'error')
            raise ValueError(f"File operation failed: {str(e)}")
    
    def _read_file(self, file_path: str, encoding: str) -> Dict[str, Any]:
        """Read file content"""
        if not os.path.exists(file_path):
            raise ValueError(f"File not found: {file_path}")
        
        with open(file_path, 'r', encoding=encoding) as f:
            content = f.read()
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'content': content,
                'file_path': file_path,
                'file_size': file_size,
                'encoding': encoding
            },
            'success': True,
            'message': f'File read successfully: {file_path}'
        }
    
    def _write_file(self, file_path: str, content: str, encoding: str) -> Dict[str, Any]:
        """Write content to file"""
        # Ensure directory exists
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        with open(file_path, 'w', encoding=encoding) as f:
            f.write(content)
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'file_size': file_size,
                'encoding': encoding,
                'content_length': len(content)
            },
            'success': True,
            'message': f'File written successfully: {file_path}'
        }
    
    def _append_file(self, file_path: str, content: str, encoding: str) -> Dict[str, Any]:
        """Append content to file"""
        # Ensure directory exists
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        with open(file_path, 'a', encoding=encoding) as f:
            f.write(content)
        
        file_size = os.path.getsize(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'file_size': file_size,
                'encoding': encoding,
                'appended_length': len(content)
            },
            'success': True,
            'message': f'Content appended to file: {file_path}'
        }
    
    def _delete_file(self, file_path: str) -> Dict[str, Any]:
        """Delete file"""
        if not os.path.exists(file_path):
            raise ValueError(f"File not found: {file_path}")
        
        os.remove(file_path)
        
        return {
            'data': {
                'file_path': file_path,
                'deleted': True
            },
            'success': True,
            'message': f'File deleted successfully: {file_path}'
        }
    
    def _check_file_exists(self, file_path: str) -> Dict[str, Any]:
        """Check if file exists"""
        exists = os.path.exists(file_path)
        
        result = {
            'data': {
                'file_path': file_path,
                'exists': exists
            },
            'success': True,
            'message': f'File {"exists" if exists else "does not exist"}: {file_path}'
        }
        
        if exists:
            stat = os.stat(file_path)
            result['data'].update({
                'file_size': stat.st_size,
                'modified_time': stat.st_mtime,
                'is_file': os.path.isfile(file_path),
                'is_directory': os.path.isdir(file_path)
            })
        
        return result
