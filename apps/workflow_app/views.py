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
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework_simplejwt.authentication import JWTAuthentication
import json
import uuid
from datetime import datetime, timedelta

from .models import (
    NodeType, Workflow, WorkflowExecution, NodeExecution,
    WorkflowWebhook, WorkflowSchedule, WorkflowTemplate, WorkflowVariable
)
from .serializers import (
    NodeTypeSerializer, WorkflowSerializer, WorkflowExecutionSerializer,
    WorkflowWebhookSerializer, WorkflowScheduleSerializer, WorkflowTemplateSerializer,
    WorkflowVariableSerializer
)
from .engine import WorkflowEngine
from .tasks import execute_workflow_task
from .scheduler import schedule_workflow, unschedule_workflow

# Dashboard View
@login_required
def dashboard_view(request):
    """Dashboard with workflow statistics and recent activity"""
    user_workflows = Workflow.objects.filter(
        Q(created_by_id=request.user.id) | Q(shared_with__id=request.user.id)
    ).distinct()
    
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
        'daily_executions': json.dumps(daily_executions),
    }
    
    return render(request, 'workflow_app/dashboard.html', context)


# Workflow Views
@login_required
@ensure_csrf_cookie
def workflow_list_view(request):
    """List all workflows for the user"""
    # Get the user ID
    user_id = request.user.id if hasattr(request.user, 'id') else None
    
    if not user_id:
        workflows = Workflow.objects.none()
    else:
        workflows = Workflow.objects.filter(
            Q(created_by_id=user_id) | Q(shared_with__id=user_id)
        ).distinct().order_by('-updated_at')
    
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
    for workflow in workflows:
        workflow.execution_count = workflow.executions.count()
    
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
    workflow = get_object_or_404(
        Workflow.objects.select_related(),
        Q(id=workflow_id) & (Q(created_by_id=request.user.id) | Q(shared_with__id=request.user.id))
    )
    
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
        workflow = get_object_or_404(
            Workflow,
            Q(id=workflow_id) & (Q(created_by_id=request.user.id) | Q(shared_with__id=request.user.id))
        )
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
    if not template.is_public and template.created_by != request.user:
        messages.error(request, "You don't have permission to view this template.")
        return redirect('workflow_app:template_list')
    
    # Template structure info
    definition = template.template_definition or {}
    node_count = len(definition.get('nodes', []))
    connection_count = len(definition.get('connections', []))
    
    can_edit = template.created_by == request.user
    
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
        workflow__in=Workflow.objects.filter(
            Q(created_by__id=request.user.id) | Q(shared_with__id=request.user.id)
        )
    ).select_related('workflow', 'triggered_by_user').order_by('-started_at')
    
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
    user_workflows = Workflow.objects.filter(
    Q(created_by__id=request.user.id) | Q(shared_with__id=request.user.id)
    ).distinct().order_by('name')
    
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

# API ViewSets
class NodeTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """API for node types"""
    queryset = NodeType.objects.filter(is_active=True)
    serializer_class = NodeTypeSerializer
    permission_classes = [IsAuthenticated]

class WorkflowViewSet(viewsets.ModelViewSet):
    """API for workflows"""
    serializer_class = WorkflowSerializer
    authentication_classes = [SessionAuthentication, BasicAuthentication, JWTAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Workflow.objects.filter(
            Q(created_by_id=self.request.user.id) | Q(shared_with__id=self.request.user.id)
        ).distinct()
    
    def perform_create(self, serializer):
        serializer.save(created_by_id=self.request.user.id)
    
    @action(detail=True, methods=['post'])
    def execute(self, request, pk=None):
        """Execute a workflow"""
        workflow = self.get_object()
        
        if workflow.status != 'active':
            return Response(
                {'error': 'Workflow must be active to execute'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        input_data = request.data.get('input_data', {})
        sync = request.data.get('sync', False)
        test_mode = request.data.get('test_mode', False)
        
        # Create execution
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by='manual',
            triggered_by_user=request.user,
            input_data=input_data,
            execution_context={
                'manual_trigger': True,
                'test_mode': test_mode
            }
        )
        
        if sync:
            # Execute synchronously
            engine = WorkflowEngine()
            success = engine.execute_workflow(str(execution.id))
            execution.refresh_from_db()
            
            return Response({
                'execution_id': str(execution.id),
                'status': execution.status,
                'success': success,
                'output_data': execution.output_data
            })
        else:
            # Execute asynchronously
            execute_workflow_task.delay(str(execution.id))
            
            return Response({
                'execution_id': str(execution.id),
                'status': 'queued',
                'message': 'Workflow execution started'
            })
    
    @action(detail=True, methods=['post'])
    def activate(self, request, pk=None):
        """Activate a workflow"""
        workflow = self.get_object()
        workflow.status = 'active'
        workflow.save()
        
        # Schedule if cron expression is provided
        if workflow.cron_expression:
            try:
                schedule_workflow(workflow, workflow.cron_expression, workflow.timezone)
            except Exception as e:
                pass  # Continue even if scheduling fails
        
        return Response({'status': 'active', 'message': 'Workflow activated'})
    
    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Deactivate a workflow"""
        workflow = self.get_object()
        workflow.status = 'inactive'
        workflow.save()
        
        # Unschedule if scheduled
        if workflow.is_scheduled:
            try:
                unschedule_workflow(workflow)
            except Exception as e:
                pass  # Continue even if unscheduling fails
        
        return Response({'status': 'inactive', 'message': 'Workflow deactivated'})
    
    @action(detail=True, methods=['post'])
    def duplicate(self, request, pk=None):
        """Duplicate a workflow"""
        workflow = self.get_object()
        
        new_workflow = Workflow.objects.create(
            name=f"{workflow.name} (Copy)",
            description=workflow.description,
            definition=workflow.definition,
            created_by=request.user,
            status='draft'
        )
        
        return Response({
            'id': str(new_workflow.id),
            'name': new_workflow.name,
            'message': 'Workflow duplicated successfully'
        })
    
    @action(detail=True, methods=['get'])
    def export(self, request, pk=None):
        """Export workflow definition"""
        workflow = self.get_object()
        
        export_data = {
            'name': workflow.name,
            'description': workflow.description,
            'definition': workflow.definition,
            'version': workflow.version,
            'exported_at': timezone.now().isoformat(),
            'exported_by': request.user.username
        }
        
        response = HttpResponse(
            json.dumps(export_data, indent=2),
            content_type='application/json'
        )
        response['Content-Disposition'] = f'attachment; filename="workflow-{workflow.name}.json"'
        
        return response
    
    @action(detail=True, methods=['get'])
    def validate(self, request, pk=None):
        """Validate workflow definition"""
        workflow = self.get_object()
        
        errors = []
        warnings = []
        
        definition = workflow.definition or {}
        nodes = definition.get('nodes', [])
        connections = definition.get('connections', [])
        
        # Check for trigger nodes
        trigger_nodes = [n for n in nodes if self.nodeTypes.get(n.get('type', ''), {}).get('category') == 'trigger']
        if not trigger_nodes:
            errors.append("Workflow must have at least one trigger node")
        
        # Check for orphaned nodes
        connected_nodes = set()
        for conn in connections:
            connected_nodes.add(conn.get('source'))
            connected_nodes.add(conn.get('target'))
        
        for node in nodes:
            if node['id'] not in connected_nodes and len(nodes) > 1:
                warnings.append(f"Node '{node.get('name', node['id'])}' is not connected")
        
        # Check for cycles
        if self._has_cycles(nodes, connections):
            errors.append("Workflow contains cycles")
        
        return Response({
            'valid': len(errors) == 0,
            'errors': errors,
            'warnings': warnings
        })
    
    def _has_cycles(self, nodes, connections):
        """Check if workflow has cycles using DFS"""
        # Build adjacency list
        graph = {}
        for node in nodes:
            graph[node['id']] = []
        
        for conn in connections:
            source = conn.get('source')
            target = conn.get('target')
            if source in graph:
                graph[source].append(target)
        
        # DFS to detect cycles
        visited = set()
        rec_stack = set()
        
        def has_cycle_util(node):
            visited.add(node)
            rec_stack.add(node)
            
            for neighbor in graph.get(node, []):
                if neighbor not in visited:
                    if has_cycle_util(neighbor):
                        return True
                elif neighbor in rec_stack:
                    return True
            
            rec_stack.remove(node)
            return False
        
        for node_id in graph:
            if node_id not in visited:
                if has_cycle_util(node_id):
                    return True
        
        return False

class WorkflowExecutionViewSet(viewsets.ReadOnlyModelViewSet):
    """API for workflow executions"""
    serializer_class = WorkflowExecutionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowExecution.objects.filter(
            workflow__in=Workflow.objects.filter(
                Q(created_by_id=self.request.user.id) | Q(shared_with__id=self.request.user.id)
            )
        ).select_related('workflow', 'triggered_by_user')
    
    @action(detail=True, methods=['get'])
    def logs(self, request, pk=None):
        """Get execution logs"""
        execution = self.get_object()
        
        logs = []
        for node_execution in execution.node_executions.all().order_by('execution_order'):
            logs.append({
                'timestamp': node_execution.started_at.isoformat() if node_execution.started_at else '',
                'level': 'error' if node_execution.status == 'failed' else 'info',
                'node_name': node_execution.node_name,
                'message': node_execution.error_message or f"Node executed with status: {node_execution.status}",
                'duration_ms': node_execution.duration_ms,
                'status': node_execution.status
            })
        
        return Response({'logs': logs})
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel a running execution"""
        execution = self.get_object()
        
        if execution.status in ['queued', 'running']:
            execution.status = 'cancelled'
            execution.finished_at = timezone.now()
            execution.calculate_duration()
            execution.save()
            
            return Response({'status': 'cancelled', 'message': 'Execution cancelled'})
        else:
            return Response(
                {'error': 'Execution cannot be cancelled'},
                status=status.HTTP_400_BAD_REQUEST
            )

class WorkflowVariableViewSet(viewsets.ModelViewSet):
    """API for workflow variables"""
    serializer_class = WorkflowVariableSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowVariable.objects.filter(created_by_id=self.request.user.id)

class WorkflowWebhookViewSet(viewsets.ModelViewSet):
    """API for workflow webhooks"""
    serializer_class = WorkflowWebhookSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowWebhook.objects.filter(
            workflow__in=Workflow.objects.filter(
                Q(created_by_id=self.request.user.id) | Q(shared_with__id=self.request.user.id)
            )
        )

class WorkflowTemplateViewSet(viewsets.ModelViewSet):
    """API for workflow templates"""
    serializer_class = WorkflowTemplateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowTemplate.objects.filter(
            Q(is_public=True) | Q(created_by_id=self.request.user.id)
        )
    
    @action(detail=True, methods=['post'])
    def use_template(self, request, pk=None):
        """Create a workflow from template"""
        template = self.get_object()
        
        # Create new workflow from template
        workflow = Workflow.objects.create(
            name=f"{template.name} - {timezone.now().strftime('%Y%m%d')}",
            description=f"Created from template: {template.name}",
            definition=template.template_definition,
            created_by_id=request.user.id,
            status='draft',
            tags=['from-template', template.name.lower().replace(' ', '-')]
        )
        
        # Increment usage count
        template.usage_count += 1
        template.save()
        
        return Response({
            'id': str(workflow.id),
            'name': workflow.name,
            'message': 'Workflow created from template'
        })

# API Endpoints for Editor
@csrf_exempt
@require_http_methods(["GET", "POST"])
def workflow_api(request):
    """API endpoint for workflow operations"""
    if request.method == 'GET':
        # Get available models for query building
        try:
            models_data = []
            for model in apps.get_models():
                if 'django.contrib' in model.__module__:
                    continue
                
                fields = []
                for field in model._meta.get_fields():
                    if hasattr(field, 'column'):
                        fields.append(field.column)
                
                models_data.append({
                    'name': model.__name__,
                    'table': model._meta.db_table,
                    'fields': sorted(list(set(fields)))
                })
            
            return JsonResponse({
                'models': models_data,
                'node_types': list(NodeType.objects.filter(is_active=True).values(
                    'name', 'display_name', 'category', 'icon', 'color', 'config_schema'
                ))
            })
            
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    
    elif request.method == 'POST':
        # Save workflow
        try:
            data = json.loads(request.body)
            workflow_id = data.get('id')
            
            if workflow_id:
                # Update existing workflow
                workflow = Workflow.objects.get(id=workflow_id)
                workflow.name = data.get('name', workflow.name)
                workflow.description = data.get('description', workflow.description)
                workflow.definition = data.get('definition', workflow.definition)
                workflow.save()
            else:
                # Create new workflow
                workflow = Workflow.objects.create(
                    name=data.get('name', 'Untitled Workflow'),
                    description=data.get('description', ''),
                    definition=data.get('definition', {}),
                    created_by_id=data.get('user_id', 1),  # Default user
                    status='draft'
                )
            
            return JsonResponse({
                'id': str(workflow.id),
                'name': workflow.name,
                'status': workflow.status,
                'message': 'Workflow saved successfully'
            })
            
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def execute_workflow_api(request, workflow_id):
    """Execute a workflow via API"""
    try:
        workflow = get_object_or_404(Workflow, id=workflow_id)
        
        if workflow.status != 'active':
            return JsonResponse(
                {'error': 'Workflow must be active to execute'},
                status=400
            )
        
        data = json.loads(request.body) if request.body else {}
        input_data = data.get('input_data', {})
        
        # Get user from request
        user = request.user if request.user.is_authenticated else None
        
        # Create execution
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by='api',
            triggered_by_user=user,
            input_data=input_data,
            execution_context={'api_trigger': True}
        )
        
        # Execute workflow
        execute_workflow_task.delay(str(execution.id))
        
        return JsonResponse({
            'execution_id': str(execution.id),
            'status': 'queued',
            'message': 'Workflow execution started'
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET"])
def execution_status_api(request, execution_id):
    """Get execution status and results"""
    try:
        execution = get_object_or_404(
            WorkflowExecution.objects.select_related('workflow'),
            id=execution_id
        )
        
        # Get node executions
        node_executions = []
        for ne in execution.node_executions.all().order_by('execution_order'):
            node_executions.append({
                'node_id': ne.node_id,
                'node_name': ne.node_name,
                'node_type': ne.node_type,
                'status': ne.status,
                'duration_ms': ne.duration_ms,
                'input_data': ne.input_data,
                'output_data': ne.output_data,
                'error_message': ne.error_message
            })
        
        return JsonResponse({
            'id': str(execution.id),
            'workflow_id': str(execution.workflow.id),
            'workflow_name': execution.workflow.name,
            'status': execution.status,
            'started_at': execution.started_at.isoformat(),
            'finished_at': execution.finished_at.isoformat() if execution.finished_at else None,
            'duration_seconds': execution.duration_seconds,
            'output_data': execution.output_data,
            'error_message': execution.error_message,
            'node_executions': node_executions
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
