from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.core.paginator import Paginator
from django.db.models import Q, Count, Avg
from django.utils import timezone
from django.apps import apps
from django.views.decorators.csrf import ensure_csrf_cookie 
import json
import uuid
from datetime import datetime, timedelta

from .models import (
    NodeType, Workflow, WorkflowExecution, NodeExecution,
    WorkflowWebhook, WorkflowSchedule, WorkflowTemplate, WorkflowVariable
)
from .engine import WorkflowEngine
from .tasks import execute_workflow_task

# Dashboard View
@login_required
def dashboard_view(request):
    """Dashboard with workflow statistics and recent activity"""
    user_workflows = Workflow.objects.filter(created_by_id=request.user.id)
    
    # Calculate statistics
    total_workflows = user_workflows.count()
    active_workflows = user_workflows.filter(status='active').count()
    
    # Execution statistics
    user_executions = WorkflowExecution.objects.filter(workflow__in=user_workflows)
    total_executions = user_executions.count()
    successful_executions = user_executions.filter(status='success').count()
    failed_executions = user_executions.filter(status='failed').count()
    running_executions = user_executions.filter(status='running').count()
    
    success_rate = round((successful_executions / total_executions * 100) if total_executions > 0 else 0, 1)
    error_rate = round((failed_executions / total_executions * 100) if total_executions > 0 else 0, 1)
    
    # Average execution time
    avg_execution_time = user_executions.filter(
        duration_seconds__isnull=False
    ).aggregate(avg_time=Avg('duration_seconds'))['avg_time'] or 0
    
    # Recent activity
    recent_executions = user_executions.order_by('-started_at')[:10]
    recent_workflows = user_workflows.order_by('-updated_at')[:10]
    
    # Top performing workflows
    top_workflows = user_workflows.annotate(
        execution_count=Count('executions')
    ).filter(execution_count__gt=0).order_by('-execution_count')[:5]
    
    # Daily execution data for chart
    daily_executions = []
    for i in range(7):
        date = timezone.now().date() - timedelta(days=i)
        day_executions = user_executions.filter(started_at__date=date)
        daily_executions.append({
            'day': date.strftime('%m/%d'),
            'successful': day_executions.filter(status='success').count(),
            'failed': day_executions.filter(status='failed').count()
        })
    daily_executions.reverse()
    
    context = {
        'total_workflows': total_workflows,
        'active_workflows': active_workflows,
        'total_executions': total_executions,
        'successful_executions': successful_executions,
        'failed_executions': failed_executions,
        'running_executions': running_executions,
        'success_rate': success_rate,
        'error_rate': error_rate,
        'avg_execution_time': round(avg_execution_time, 2),
        'recent_executions': recent_executions,
        'recent_workflows': recent_workflows,
        'top_workflows': top_workflows,
        'daily_executions': json.dumps(daily_executions),
    }
    
    return render(request, 'workflow_app/dashboard.html', context)

# Workflow Views
@login_required
@ensure_csrf_cookie
def workflow_list_view(request):
    """List all workflows for the user"""
    workflows = Workflow.objects.filter(created_by_id=request.user.id).order_by('-updated_at')
    
    # Apply filters
    search_query = request.GET.get('search', '')
    status_filter = request.GET.get('status', '')
    
    if search_query:
        workflows = workflows.filter(
            Q(name__icontains=search_query) |
            Q(description__icontains=search_query)
        )
    
    if status_filter:
        workflows = workflows.filter(status=status_filter)
    
    # Add execution counts
    workflows = workflows.annotate(execution_count=Count('executions'))
    
    # Statistics
    total_workflows = workflows.count()
    active_workflows = workflows.filter(status='active').count()
    draft_workflows = workflows.filter(status='draft').count()
    
    # Pagination
    paginator = Paginator(workflows, 12)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'workflows': page_obj,
        'page_obj': page_obj,
        'search_query': search_query,
        'status_filter': status_filter,
        'total_workflows': total_workflows,
        'active_workflows': active_workflows,
        'draft_workflows': draft_workflows,
    }
    
    return render(request, 'workflow_app/workflow_list.html', context)

@login_required
@ensure_csrf_cookie
def workflow_detail_view(request, workflow_id):
    """Detailed view of a specific workflow"""
    workflow = get_object_or_404(Workflow, id=workflow_id, created_by_id=request.user.id)
    
    # Execution statistics
    executions = workflow.executions.all()
    total_executions = executions.count()
    successful_executions = executions.filter(status='success').count()
    failed_executions = executions.filter(status='failed').count()
    success_rate = round((successful_executions / total_executions * 100) if total_executions > 0 else 0, 1)
    
    # Recent executions
    recent_executions = executions.order_by('-started_at')[:10]
    
    # Workflow structure info
    definition = workflow.definition or {}
    node_count = len(definition.get('nodes', []))
    connection_count = len(definition.get('connections', []))
    
    # Execution history for chart
    execution_history = []
    for i in range(7):
        date = timezone.now().date() - timedelta(days=i)
        day_executions = executions.filter(started_at__date=date)
        execution_history.append({
            'day': date.strftime('%m/%d'),
            'successful': day_executions.filter(status='success').count(),
            'failed': day_executions.filter(status='failed').count()
        })
    execution_history.reverse()
    
    context = {
        'workflow': workflow,
        'total_executions': total_executions,
        'successful_executions': successful_executions,
        'failed_executions': failed_executions,
        'success_rate': success_rate,
        'recent_executions': recent_executions,
        'node_count': node_count,
        'connection_count': connection_count,
        'execution_history': json.dumps(execution_history),
    }
    
    return render(request, 'workflow_app/workflow_detail.html', context)

@login_required
@ensure_csrf_cookie
def workflow_editor_view(request, workflow_id=None):
    """Workflow editor interface"""
    workflow = None
    workflow_json = {'nodes': [], 'connections': []}

    if workflow_id:
        workflow = get_object_or_404(Workflow, id=workflow_id, created_by_id=request.user.id)
        workflow_json = workflow.definition or {'nodes': [], 'connections': []}
    
    context = {
        'workflow': workflow,
        'workflow_json': json.dumps(workflow_json),
    }
    
    return render(request, 'workflow_app/workflow_editor.html', context)

# Template Views
@login_required
@ensure_csrf_cookie
def template_list_view(request):
    """List workflow templates"""
    templates = WorkflowTemplate.objects.filter(
        Q(is_public=True) | Q(created_by_id=request.user.id)
    ).order_by('-usage_count', 'name')
    
    # Apply filters
    search_query = request.GET.get('search', '')
    category_filter = request.GET.get('category', '')
    
    if search_query:
        templates = templates.filter(
            Q(name__icontains=search_query) | 
            Q(description__icontains=search_query)
        )
    
    if category_filter:
        templates = templates.filter(category=category_filter)
    
    # Get categories
    categories = WorkflowTemplate.objects.values_list('category', flat=True).distinct()
    categories = [cat for cat in categories if cat]
    
    # Statistics
    total_templates = templates.count()
    public_templates = templates.filter(is_public=True).count()
    my_templates = templates.filter(created_by_id=request.user.id).count()
    
    # Pagination
    paginator = Paginator(templates, 12)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'templates': page_obj,
        'page_obj': page_obj,
        'categories': categories,
        'search_query': search_query,
        'category_filter': category_filter,
        'total_templates': total_templates,
        'public_templates': public_templates,
        'my_templates': my_templates,
    }
    
    return render(request, 'workflow_app/template_list.html', context)

@login_required
@ensure_csrf_cookie
def template_detail_view(request, template_id):
    """Detailed view of a template"""
    template = get_object_or_404(WorkflowTemplate, id=template_id)
    
    # Check if user can view this template
    if not template.is_public and template.created_by_id != request.user.id:
        messages.error(request, "You don't have permission to view this template.")
        return redirect('workflow_app:template_list')
    
    # Template structure info
    definition = template.template_definition or {}
    node_count = len(definition.get('nodes', []))
    connection_count = len(definition.get('connections', []))
    
    can_edit = template.created_by_id == request.user.id
    
    context = {
        'template': template,
        'node_count': node_count,
        'connection_count': connection_count,
        'can_edit': can_edit,
    }
    
    return render(request, 'workflow_app/template_detail.html', context)

@login_required
def template_create_view(request):
    """Create a new template"""
    if request.method == 'POST':
        name = request.POST.get('name')
        description = request.POST.get('description', '')
        category = request.POST.get('category', '')
        is_public = request.POST.get('is_public') == 'on'
        workflow_id = request.POST.get('workflow_id')
        
        if not name or not workflow_id:
            messages.error(request, "Name and source workflow are required.")
            return redirect('workflow_app:template_create')
        
        try:
            source_workflow = Workflow.objects.get(
                id=workflow_id,
                created_by_id=request.user.id
            )
            
            template = WorkflowTemplate.objects.create(
                name=name,
                description=description,
                category=category,
                template_definition=source_workflow.definition,
                is_public=is_public,
                created_by_id=request.user.id,
                tags=['user-created']
            )
            
            messages.success(request, "Template created successfully!")
            return redirect('workflow_app:template_detail', template_id=template.id)
            
        except Workflow.DoesNotExist:
            messages.error(request, "Source workflow not found.")
    
    # Get user's workflows for template creation
    workflows = Workflow.objects.filter(created_by_id=request.user.id).order_by('name')
    categories = ['automation', 'data-processing', 'notification', 'integration', 'monitoring']
    
    context = {
        'workflows': workflows,
        'categories': categories,
    }
    
    return render(request, 'workflow_app/template_create.html', context)

@login_required
def template_edit_view(request, template_id):
    """Edit a template"""
    template = get_object_or_404(WorkflowTemplate, id=template_id, created_by_id=request.user.id)
    
    if request.method == 'POST':
        template.name = request.POST.get('name', template.name)
        template.description = request.POST.get('description', template.description)
        template.category = request.POST.get('category', template.category)
        template.is_public = request.POST.get('is_public') == 'on'
        template.save()
        
        messages.success(request, "Template updated successfully!")
        return redirect('workflow_app:template_detail', template_id=template.id)
    
    categories = ['automation', 'data-processing', 'notification', 'integration', 'monitoring']
    
    context = {
        'template': template,
        'categories': categories,
    }
    
    return render(request, 'workflow_app/template_edit.html', context)

# Execution Views
@login_required
@ensure_csrf_cookie
def execution_list_view(request):
    """List workflow executions"""
    executions = WorkflowExecution.objects.filter(
        workflow__created_by_id=request.user.id
    ).select_related('workflow').order_by('-started_at')
    
    # Apply filters
    workflow_filter = request.GET.get('workflow', '')
    status_filter = request.GET.get('status', '')
    date_from = request.GET.get('date_from', '')
    date_to = request.GET.get('date_to', '')
    
    if workflow_filter:
        executions = executions.filter(workflow_id=workflow_filter)
    
    if status_filter:
        executions = executions.filter(status=status_filter)
    
    if date_from:
        executions = executions.filter(started_at__date__gte=date_from)
    
    if date_to:
        executions = executions.filter(started_at__date__lte=date_to)
    
    # Statistics
    total_executions = executions.count()
    successful_executions = executions.filter(status='success').count()
    failed_executions = executions.filter(status='failed').count()
    running_executions = executions.filter(status='running').count()
    success_rate = round((successful_executions / total_executions * 100) if total_executions > 0 else 0, 1)
    
    # User workflows for filter dropdown
    user_workflows = Workflow.objects.filter(created_by_id=request.user.id).order_by('name')
    
    # Pagination
    paginator = Paginator(executions, 20)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'executions': page_obj,
        'page_obj': page_obj,
        'user_workflows': user_workflows,
        'workflow_filter': workflow_filter,
        'status_filter': status_filter,
        'date_from': date_from,
        'date_to': date_to,
        'total_executions': total_executions,
        'successful_executions': successful_executions,
        'failed_executions': failed_executions,
        'running_executions': running_executions,
        'success_rate': success_rate,
    }
    
    return render(request, 'workflow_app/execution_list.html', context)

# Webhook Receiver
@csrf_exempt
def webhook_receiver(request, endpoint_path):
    """Receive webhook requests and trigger workflows"""
    try:
        webhook = WorkflowWebhook.objects.get(
            endpoint_path=f"/{endpoint_path}",
            is_active=True,
            workflow__status='active'
        )
        
        # Validate HTTP method
        if webhook.http_method != request.method:
            return JsonResponse({'error': 'Method not allowed'}, status=405)
        
        # Get request data
        if request.content_type == 'application/json':
            try:
                request_data = json.loads(request.body)
            except json.JSONDecodeError:
                request_data = {}
        else:
            request_data = dict(request.POST)
        
        # Create execution
        execution = WorkflowExecution.objects.create(
            workflow=webhook.workflow,
            triggered_by='webhook',
            input_data=request_data,
            execution_context={
                'webhook_id': str(webhook.id),
                'webhook_data': request_data,
                'request_headers': dict(request.headers)
            }
        )
        
        # Update webhook stats
        webhook.last_triggered_at = timezone.now()
        webhook.trigger_count += 1
        webhook.save()
        
        # Execute workflow asynchronously
        execute_workflow_task.delay(str(execution.id))
        
        return JsonResponse({
            'status': 'success',
            'execution_id': str(execution.id),
            'message': 'Workflow triggered successfully'
        })
        
    except WorkflowWebhook.DoesNotExist:
        return JsonResponse({'error': 'Webhook not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)