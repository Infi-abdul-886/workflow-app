"""
Action node handlers for performing operations
"""
import smtplib
import requests
import time
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Dict, Any
from django.conf import settings
from .base import BaseNodeHandler

class EmailSendHandler(BaseNodeHandler):
    """Handler for sending emails"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        to_email = config.get('to', '')
        subject = config.get('subject', '')
        body = config.get('body', '')
        from_email = config.get('from_email', getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@example.com'))
        
        if not to_email:
            raise ValueError("Recipient email is required")
        
        try:
            # Create message
            msg = MIMEMultipart()
            msg['From'] = from_email
            msg['To'] = to_email
            msg['Subject'] = subject
            
            # Add body
            msg.attach(MIMEText(body, 'plain'))
            
            # Send email (using Django's email backend)
            from django.core.mail import send_mail
            
            send_mail(
                subject=subject,
                message=body,
                from_email=from_email,
                recipient_list=[to_email],
                fail_silently=False
            )
            
            return {
                'data': {
                    'to': to_email,
                    'subject': subject,
                    'sent_at': context.get('execution_time', 'now')
                },
                'success': True,
                'message': f'Email sent successfully to {to_email}'
            }
            
        except Exception as e:
            self.log_execution(f"Email sending failed: {str(e)}", 'error')
            raise ValueError(f"Failed to send email: {str(e)}")

class SlackNotificationHandler(BaseNodeHandler):
    """Handler for sending Slack notifications"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        webhook_url = config.get('webhook_url', '')
        message = config.get('message', '')
        channel = config.get('channel', '')
        username = config.get('username', 'Workflow Bot')
        
        if not webhook_url:
            raise ValueError("Slack webhook URL is required")
        
        if not message:
            raise ValueError("Message is required")
        
        try:
            payload = {
                'text': message,
                'username': username
            }
            
            if channel:
                payload['channel'] = channel
            
            response = requests.post(
                webhook_url,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                return {
                    'data': {
                        'message': message,
                        'channel': channel,
                        'sent_at': context.get('execution_time', 'now')
                    },
                    'success': True,
                    'message': 'Slack notification sent successfully'
                }
            else:
                raise ValueError(f"Slack API returned status {response.status_code}")
                
        except Exception as e:
            self.log_execution(f"Slack notification failed: {str(e)}", 'error')
            raise ValueError(f"Failed to send Slack notification: {str(e)}")

class WebhookSendHandler(BaseNodeHandler):
    """Handler for sending webhook requests"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        url = config.get('url', '')
        method = config.get('method', 'POST').upper()
        headers = config.get('headers', {})
        payload = config.get('payload', {})
        timeout = config.get('timeout', 30)
        
        if not url:
            raise ValueError("Webhook URL is required")
        
        # Parse headers if string
        if isinstance(headers, str):
            try:
                headers = eval(headers) if headers else {}
            except:
                headers = {}
        
        # Use input data as payload if not specified
        if not payload:
            payload = input_data.get('data', {})
        
        try:
            self.log_execution(f"Sending {method} webhook to {url}")
            
            response = requests.request(
                method=method,
                url=url,
                json=payload,
                headers=headers,
                timeout=timeout
            )
            
            # Try to parse JSON response
            try:
                response_data = response.json()
            except:
                response_data = response.text
            
            result = {
                'data': {
                    'response': response_data,
                    'status_code': response.status_code,
                    'headers': dict(response.headers)
                },
                'success': response.status_code < 400,
                'message': f'Webhook sent with status {response.status_code}'
            }
            
            if not result['success']:
                self.log_execution(f"Webhook failed with status {response.status_code}", 'warning')
            
            return result
            
        except requests.exceptions.Timeout:
            raise ValueError(f"Webhook request timed out after {timeout} seconds")
        except requests.exceptions.RequestException as e:
            raise ValueError(f"Webhook request failed: {str(e)}")

class DelayHandler(BaseNodeHandler):
    """Handler for adding delays in workflow execution"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        delay_seconds = config.get('delay_seconds', 1)
        delay_type = config.get('delay_type', 'fixed')
        
        try:
            delay_seconds = float(delay_seconds)
        except (ValueError, TypeError):
            delay_seconds = 1
        
        if delay_type == 'random':
            import random
            min_delay = config.get('min_delay', 1)
            max_delay = config.get('max_delay', 5)
            delay_seconds = random.uniform(float(min_delay), float(max_delay))
        
        self.log_execution(f"Delaying execution for {delay_seconds} seconds")
        
        import time
        time.sleep(delay_seconds)
        
        return {
            'data': {
                'delayed_seconds': delay_seconds,
                'delay_type': delay_type,
                'input_data': input_data.get('data', {})
            },
            'success': True,
            'message': f'Delayed execution for {delay_seconds:.2f} seconds'
        }

class FileWriteHandler(BaseNodeHandler):
    """Handler for writing data to files"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        file_path = config.get('file_path', '')
        content = config.get('content', '')
        file_format = config.get('format', 'text')
        append_mode = config.get('append', False)
        
        if not file_path:
            raise ValueError("File path is required")
        
        # Use input data as content if not specified
        if not content:
            data = input_data.get('data', {})
            if file_format == 'json':
                import json
                content = json.dumps(data, indent=2)
            else:
                content = str(data)
        
        try:
            import os
            
            # Ensure directory exists
            directory = os.path.dirname(file_path)
            if directory and not os.path.exists(directory):
                os.makedirs(directory)
            
            # Write file
            mode = 'a' if append_mode else 'w'
            with open(file_path, mode, encoding='utf-8') as f:
                f.write(content)
                if append_mode:
                    f.write('\n')
            
            file_size = os.path.getsize(file_path)
            
            return {
                'data': {
                    'file_path': file_path,
                    'file_size': file_size,
                    'format': file_format,
                    'append_mode': append_mode
                },
                'success': True,
                'message': f'File written successfully: {file_path}'
            }
            
        except Exception as e:
            self.log_execution(f"File write failed: {str(e)}", 'error')
            raise ValueError(f"Failed to write file: {str(e)}")

class LogHandler(BaseNodeHandler):
    """Handler for logging messages"""
    
    def execute(self, config: Dict[str, Any], input_data: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
        message = config.get('message', '')
        log_level = config.get('level', 'info')
        include_data = config.get('include_data', False)
        
        # Use input data in message if not specified
        if not message:
            message = f"Node executed with data: {input_data.get('data', {})}"
        
        # Log the message
        self.log_execution(message, log_level)
        
        log_data = {
            'message': message,
            'level': log_level,
            'timestamp': context.get('execution_time', 'now')
        }
        
        if include_data:
            log_data['input_data'] = input_data.get('data', {})
        
        return {
            'data': log_data,
            'success': True,
            'message': f'Message logged at {log_level} level'
        }
