import uuid
import json
from django.db import models
from django.conf import settings
from django.utils import timezone
from django.core.exceptions import ValidationError

class NodeType(models.Model):
    """Registry of available node types with their schemas"""
    CATEGORY_CHOICES = [
        ('trigger', 'Trigger'),
        ('data', 'Data Source'),
        ('transform', 'Transform'),
        ('condition', 'Condition'),
        ('action', 'Action'),
        ('output', 'Output'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=100, unique=True)
    display_name = models.CharField(max_length=100)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, default='fa-cog')
    color = models.CharField(max_length=7, default='#3b82f6')
    
    # JSON schema defining the configuration fields for this node type
    config_schema = models.JSONField(default=dict, help_text="JSON schema for node configuration")
    
    # Python handler path for execution
    handler_class = models.CharField(max_length=200, blank=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['category', 'display_name']
    
    def __str__(self):
        return self.display_name

class Workflow(models.Model):
    """Main workflow definition"""
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('archived', 'Archived'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    
    # Store creator as integer ID to match existing system
    created_by_id = models.IntegerField()
    
    # Workflow state
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    version = models.IntegerField(default=1)
    
    # Complete workflow definition as JSON
    definition = models.JSONField(default=dict, help_text="Complete workflow definition including nodes and connections")
    
    # Execution settings
    timeout_seconds = models.IntegerField(default=300)
    max_retries = models.IntegerField(default=3)
    retry_delay_seconds = models.IntegerField(default=60)
    
    # Scheduling
    is_scheduled = models.BooleanField(default=False)
    cron_expression = models.CharField(max_length=100, blank=True)
    timezone = models.CharField(max_length=50, default='UTC')
    
    # Metadata
    tags = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_executed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['created_by_id', 'status']),
            models.Index(fields=['status', 'is_scheduled']),
        ]
    
    def __str__(self):
        return f"{self.name} (v{self.version})"
    
    def get_nodes(self):
        """Extract nodes from workflow definition"""
        return self.definition.get('nodes', [])
    
    def get_connections(self):
        """Extract connections from workflow definition"""
        return self.definition.get('connections', [])

class WorkflowExecution(models.Model):
    """Individual workflow execution instance"""
    STATUS_CHOICES = [
        ('queued', 'Queued'),
        ('running', 'Running'),
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
        ('timeout', 'Timeout'),
    ]
    
    TRIGGER_CHOICES = [
        ('manual', 'Manual'),
        ('scheduled', 'Scheduled'),
        ('webhook', 'Webhook'),
        ('api', 'API'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    workflow = models.ForeignKey(Workflow, on_delete=models.CASCADE, related_name='executions')
    
    # Execution details
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='queued')
    triggered_by = models.CharField(max_length=20, choices=TRIGGER_CHOICES, default='manual')
    triggered_by_user_id = models.IntegerField(null=True, blank=True)
    
    # Timing
    started_at = models.DateTimeField(auto_now_add=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    duration_seconds = models.FloatField(null=True, blank=True)
    
    # Data
    input_data = models.JSONField(default=dict, blank=True)
    output_data = models.JSONField(default=dict, blank=True)
    error_message = models.TextField(blank=True)
    error_details = models.JSONField(default=dict, blank=True)
    
    # Execution context
    execution_context = models.JSONField(default=dict, blank=True)
    
    class Meta:
        ordering = ['-started_at']
        indexes = [
            models.Index(fields=['workflow', 'status']),
            models.Index(fields=['status', 'started_at']),
        ]
    
    def __str__(self):
        return f"{self.workflow.name} - {self.status} ({self.started_at})"
    
    def calculate_duration(self):
        """Calculate and update execution duration"""
        if self.started_at and self.finished_at:
            delta = self.finished_at - self.started_at
            self.duration_seconds = delta.total_seconds()
            return self.duration_seconds
        return None

class NodeExecution(models.Model):
    """Individual node execution within a workflow execution"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('skipped', 'Skipped'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    workflow_execution = models.ForeignKey(WorkflowExecution, on_delete=models.CASCADE, related_name='node_executions')
    
    # Node identification
    node_id = models.CharField(max_length=100)  # Node ID from workflow definition
    node_type = models.CharField(max_length=100)
    node_name = models.CharField(max_length=255)
    
    # Execution details
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    execution_order = models.IntegerField(default=0)
    
    # Timing
    started_at = models.DateTimeField(null=True, blank=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    duration_ms = models.FloatField(null=True, blank=True)
    
    # Data
    input_data = models.JSONField(default=dict, blank=True)
    output_data = models.JSONField(default=dict, blank=True)
    error_message = models.TextField(blank=True)
    error_details = models.JSONField(default=dict, blank=True)
    
    # Configuration used during execution
    node_config = models.JSONField(default=dict, blank=True)
    
    class Meta:
        ordering = ['execution_order', 'started_at']
        indexes = [
            models.Index(fields=['workflow_execution', 'status']),
            models.Index(fields=['node_id', 'workflow_execution']),
        ]
    
    def __str__(self):
        return f"{self.node_name} - {self.status}"

class WorkflowWebhook(models.Model):
    """Webhook endpoints for triggering workflows"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    workflow = models.ForeignKey(Workflow, on_delete=models.CASCADE, related_name='webhooks')
    
    # Webhook configuration
    name = models.CharField(max_length=255)
    endpoint_path = models.CharField(max_length=255, unique=True)
    http_method = models.CharField(max_length=10, default='POST', choices=[
        ('GET', 'GET'),
        ('POST', 'POST'),
        ('PUT', 'PUT'),
        ('PATCH', 'PATCH'),
    ])
    
    # Security
    is_active = models.BooleanField(default=True)
    require_auth = models.BooleanField(default=True)
    api_key = models.CharField(max_length=255, blank=True)
    allowed_ips = models.JSONField(default=list, blank=True)
    
    # Request handling
    request_timeout = models.IntegerField(default=30)
    max_payload_size = models.IntegerField(default=1048576)  # 1MB
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    last_triggered_at = models.DateTimeField(null=True, blank=True)
    trigger_count = models.IntegerField(default=0)
    
    class Meta:
        indexes = [
            models.Index(fields=['endpoint_path', 'is_active']),
        ]
    
    def __str__(self):
        return f"{self.name} - {self.endpoint_path}"

class WorkflowSchedule(models.Model):
    """Scheduled workflow executions"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    workflow = models.OneToOneField(Workflow, on_delete=models.CASCADE, related_name='schedule')
    
    # Schedule configuration
    is_active = models.BooleanField(default=True)
    cron_expression = models.CharField(max_length=100)
    timezone = models.CharField(max_length=50, default='UTC')
    
    # Execution limits
    max_executions = models.IntegerField(null=True, blank=True)
    execution_count = models.IntegerField(default=0)
    
    # Date range
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    last_executed_at = models.DateTimeField(null=True, blank=True)
    next_execution_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.workflow.name} - {self.cron_expression}"

class WorkflowTemplate(models.Model):
    """Reusable workflow templates"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    category = models.CharField(max_length=100, blank=True)
    
    # Template definition
    template_definition = models.JSONField(default=dict)
    
    # Metadata
    is_public = models.BooleanField(default=False)
    created_by_id = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    usage_count = models.IntegerField(default=0)
    
    # Tags for categorization
    tags = models.JSONField(default=list, blank=True)
    
    class Meta:
        ordering = ['-usage_count', 'name']
    
    def __str__(self):
        return self.name

class WorkflowVariable(models.Model):
    """Global variables for workflows"""
    SCOPE_CHOICES = [
        ('global', 'Global'),
        ('workflow', 'Workflow'),
        ('user', 'User'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    name = models.CharField(max_length=100)
    value = models.TextField()
    scope = models.CharField(max_length=20, choices=SCOPE_CHOICES, default='workflow')
    
    # Scope references
    workflow = models.ForeignKey(Workflow, on_delete=models.CASCADE, null=True, blank=True, related_name='variables')
    created_by_id = models.IntegerField()
    
    # Security
    is_encrypted = models.BooleanField(default=False)
    is_secret = models.BooleanField(default=False)
    
    # Metadata
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = [['name', 'scope', 'workflow', 'created_by_id']]
        indexes = [
            models.Index(fields=['scope', 'name']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.scope})"