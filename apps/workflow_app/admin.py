from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
import json

from .models import (
    NodeType, Workflow, WorkflowExecution, NodeExecution,
    WorkflowWebhook, WorkflowSchedule, WorkflowTemplate, WorkflowVariable
)

@admin.register(NodeType)
class NodeTypeAdmin(admin.ModelAdmin):
    list_display = ['display_name', 'name', 'category', 'colored_icon', 'is_active', 'created_at']
    list_filter = ['category', 'is_active', 'created_at']
    search_fields = ['name', 'display_name', 'description']
    readonly_fields = ['created_at']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'display_name', 'category', 'description', 'is_active')
        }),
        ('Visual Settings', {
            'fields': ('icon', 'color')
        }),
        ('Configuration', {
            'fields': ('config_schema', 'handler_class'),
            'classes': ('collapse',)
        }),
        ('Metadata', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        })
    )
    
    def colored_icon(self, obj):
        return format_html(
            '<i class="{}" style="color: {}; font-size: 16px;"></i>',
            obj.icon,
            obj.color
        )
    colored_icon.short_description = 'Icon'

class NodeExecutionInline(admin.TabularInline):
    model = NodeExecution
    extra = 0
    readonly_fields = ['node_id', 'node_type', 'status', 'duration_ms', 'started_at', 'finished_at']
    fields = ['node_name', 'node_type', 'status', 'execution_order', 'duration_ms']
    
    def has_add_permission(self, request, obj=None):
        return False

@admin.register(Workflow)
class WorkflowAdmin(admin.ModelAdmin):
    list_display = ['name', 'status', 'version', 'is_scheduled', 'last_executed_at', 'created_at', 'created_by_display']
    list_filter = ['status', 'is_scheduled', 'created_at']
    search_fields = ['name', 'description']
    readonly_fields = ['created_at', 'updated_at', 'last_executed_at', 'version']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'description', 'status')
        }),
        ('Execution Settings', {
            'fields': ('timeout_seconds', 'max_retries', 'retry_delay_seconds'),
            'classes': ('collapse',)
        }),
        ('Scheduling', {
            'fields': ('is_scheduled', 'cron_expression', 'timezone'),
            'classes': ('collapse',)
        }),
        ('Workflow Definition', {
            'fields': ('definition',),
            'classes': ('collapse',)
        }),
        ('Metadata', {
            'fields': ('version', 'tags', 'created_at', 'updated_at', 'last_executed_at'),
            'classes': ('collapse',)
        })
    )
    
    actions = ['activate_workflows', 'deactivate_workflows']
    
    def activate_workflows(self, request, queryset):
        updated = queryset.update(status='active')
        self.message_user(request, f'{updated} workflows activated.')
    activate_workflows.short_description = 'Activate selected workflows'
    
    def deactivate_workflows(self, request, queryset):
        updated = queryset.update(status='inactive')
        self.message_user(request, f'{updated} workflows deactivated.')
    deactivate_workflows.short_description = 'Deactivate selected workflows'

    def created_by_display(self, obj):
        try:
            return str(obj.created_by)
        except Exception:
            return ''
    created_by_display.short_description = 'Created by'

@admin.register(WorkflowExecution)
class WorkflowExecutionAdmin(admin.ModelAdmin):
    list_display = ['workflow', 'status', 'triggered_by', 'duration_display', 'started_at']
    list_filter = ['status', 'triggered_by', 'started_at']
    search_fields = ['workflow__name', 'triggered_by_user__username']
    readonly_fields = ['started_at', 'finished_at', 'duration_seconds']
    inlines = [NodeExecutionInline]
    
    fieldsets = (
        ('Execution Details', {
            'fields': ('workflow', 'status', 'triggered_by', 'triggered_by_user')
        }),
        ('Timing', {
            'fields': ('started_at', 'finished_at', 'duration_seconds')
        }),
        ('Data', {
            'fields': ('input_data', 'output_data'),
            'classes': ('collapse',)
        }),
        ('Errors', {
            'fields': ('error_message', 'error_details'),
            'classes': ('collapse',)
        })
    )
    
    def duration_display(self, obj):
        if obj.duration_seconds:
            return f"{obj.duration_seconds:.2f}s"
        return "-"
    duration_display.short_description = 'Duration'

@admin.register(NodeExecution)
class NodeExecutionAdmin(admin.ModelAdmin):
    list_display = ['node_name', 'node_type', 'workflow_execution', 'status', 'duration_ms', 'started_at']
    list_filter = ['status', 'node_type', 'started_at']
    search_fields = ['node_name', 'workflow_execution__workflow__name']
    readonly_fields = ['started_at', 'finished_at', 'duration_ms']

@admin.register(WorkflowWebhook)
class WorkflowWebhookAdmin(admin.ModelAdmin):
    list_display = ['name', 'workflow', 'endpoint_path', 'http_method', 'is_active', 'trigger_count']
    list_filter = ['http_method', 'is_active', 'require_auth']
    search_fields = ['name', 'endpoint_path', 'workflow__name']
    readonly_fields = ['created_at', 'last_triggered_at', 'trigger_count']

@admin.register(WorkflowSchedule)
class WorkflowScheduleAdmin(admin.ModelAdmin):
    list_display = ['workflow', 'cron_expression', 'is_active', 'execution_count', 'next_execution_at']
    list_filter = ['is_active', 'timezone']
    search_fields = ['workflow__name', 'cron_expression']
    readonly_fields = ['created_at', 'last_executed_at', 'execution_count']

@admin.register(WorkflowTemplate)
class WorkflowTemplateAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'is_public', 'usage_count', 'created_at']
    list_filter = ['is_public', 'category', 'created_at']
    search_fields = ['name', 'description', 'category']
    readonly_fields = ['created_at', 'usage_count']

@admin.register(WorkflowVariable)
class WorkflowVariableAdmin(admin.ModelAdmin):
    list_display = ['name', 'scope', 'workflow', 'is_secret', 'updated_at']
    list_filter = ['scope', 'is_secret', 'is_encrypted']
    search_fields = ['name', 'description', 'workflow__name']
    readonly_fields = ['created_at', 'updated_at']
