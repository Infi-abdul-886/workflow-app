from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q, Count, Avg
from django.utils import timezone
from django.http import JsonResponse
from datetime import timedelta
import json
import uuid

from .models import (
    NodeType, Workflow, WorkflowExecution, NodeExecution,
    WorkflowWebhook, WorkflowSchedule, WorkflowTemplate, WorkflowVariable
)
from .serializers import (
    NodeTypeSerializer, WorkflowSerializer, WorkflowExecutionSerializer,
    WorkflowWebhookSerializer, WorkflowScheduleSerializer, WorkflowTemplateSerializer,
    WorkflowVariableSerializer, WorkflowExecuteSerializer
)
from .engine import WorkflowEngine
from .tasks import execute_workflow_task

class NodeTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """API for node types"""
    queryset = NodeType.objects.filter(is_active=True)
    serializer_class = NodeTypeSerializer
    permission_classes = [IsAuthenticated]

class WorkflowViewSet(viewsets.ModelViewSet):
    """API for workflows"""
    serializer_class = WorkflowSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Workflow.objects.filter(created_by_id=self.request.user.id)
    
    def perform_create(self, serializer):
        serializer.save(created_by_id=self.request.user.id)
    
    def create(self, request, *args, **kwargs):
        """Create a new workflow"""
        data = request.data.copy()
        
        # Ensure required fields
        if not data.get('name'):
            data['name'] = 'Untitled Workflow'
        
        if not data.get('definition'):
            data['definition'] = {'nodes': [], 'connections': []}
        
        workflow = Workflow.objects.create(
            name=data['name'],
            description=data.get('description', ''),
            definition=data['definition'],
            created_by_id=request.user.id,
            status='draft'
        )
        
        return Response({
            'id': str(workflow.id),
            'name': workflow.name,
            'status': workflow.status,
            'message': 'Workflow created successfully'
        }, status=status.HTTP_201_CREATED)
    
    def update(self, request, *args, **kwargs):
        """Update an existing workflow"""
        instance = self.get_object()
        
        # Update fields
        if 'name' in request.data:
            instance.name = request.data['name']
        if 'description' in request.data:
            instance.description = request.data['description']
        if 'definition' in request.data:
            instance.definition = request.data['definition']
            instance.version += 1
        if 'status' in request.data:
            instance.status = request.data['status']
        
        instance.save()
        
        return Response({
            'id': str(instance.id),
            'name': instance.name,
            'status': instance.status,
            'version': instance.version,
            'message': 'Workflow updated successfully'
        })
    
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
            triggered_by_user_id=request.user.id,
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
                'output_data': execution.output_data,
                'duration_seconds': execution.duration_seconds
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
        
        return Response({'status': 'active', 'message': 'Workflow activated'})
    
    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Deactivate a workflow"""
        workflow = self.get_object()
        workflow.status = 'inactive'
        workflow.save()
        
        return Response({'status': 'inactive', 'message': 'Workflow deactivated'})
    
    @action(detail=True, methods=['post'])
    def duplicate(self, request, pk=None):
        """Duplicate a workflow"""
        workflow = self.get_object()
        
        new_workflow = Workflow.objects.create(
            name=f"{workflow.name} (Copy)",
            description=workflow.description,
            definition=workflow.definition,
            created_by_id=request.user.id,
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
        
        return Response(export_data)

class WorkflowExecutionViewSet(viewsets.ReadOnlyModelViewSet):
    """API for workflow executions"""
    serializer_class = WorkflowExecutionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowExecution.objects.filter(
            workflow__created_by_id=self.request.user.id
        ).select_related('workflow')
    
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
    
    def perform_create(self, serializer):
        serializer.save(created_by_id=self.request.user.id)

class WorkflowWebhookViewSet(viewsets.ModelViewSet):
    """API for workflow webhooks"""
    serializer_class = WorkflowWebhookSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowWebhook.objects.filter(
            workflow__created_by_id=self.request.user.id
        )

class WorkflowTemplateViewSet(viewsets.ModelViewSet):
    """API for workflow templates"""
    serializer_class = WorkflowTemplateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return WorkflowTemplate.objects.filter(
            Q(is_public=True) | Q(created_by_id=self.request.user.id)
        )
    
    def perform_create(self, serializer):
        serializer.save(created_by_id=self.request.user.id)
    
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

# Additional API endpoints
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats_api(request):
    """Get dashboard statistics"""
    user_workflows = Workflow.objects.filter(created_by_id=request.user.id)
    user_executions = WorkflowExecution.objects.filter(workflow__in=user_workflows)
    
    # Calculate statistics
    total_workflows = user_workflows.count()
    active_workflows = user_workflows.filter(status='active').count()
    total_executions = user_executions.count()
    successful_executions = user_executions.filter(status='success').count()
    failed_executions = user_executions.filter(status='failed').count()
    running_executions = user_executions.filter(status='running').count()
    
    success_rate = round((successful_executions / total_executions * 100) if total_executions > 0 else 0, 1)
    
    # Daily execution data
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
    
    return Response({
        'total_workflows': total_workflows,
        'active_workflows': active_workflows,
        'total_executions': total_executions,
        'successful_executions': successful_executions,
        'failed_executions': failed_executions,
        'running_executions': running_executions,
        'success_rate': success_rate,
        'daily_executions': daily_executions
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recent_activity_api(request):
    """Get recent activity for dashboard"""
    user_workflows = Workflow.objects.filter(created_by_id=request.user.id)
    
    recent_executions = WorkflowExecution.objects.filter(
        workflow__in=user_workflows
    ).select_related('workflow').order_by('-started_at')[:10]
    
    recent_workflows = user_workflows.order_by('-updated_at')[:10]
    
    executions_data = []
    for execution in recent_executions:
        executions_data.append({
            'id': str(execution.id),
            'workflow_name': execution.workflow.name,
            'status': execution.status,
            'started_at': execution.started_at.isoformat()
        })
    
    workflows_data = []
    for workflow in recent_workflows:
        workflows_data.append({
            'id': str(workflow.id),
            'name': workflow.name,
            'status': workflow.status,
            'updated_at': workflow.updated_at.isoformat()
        })
    
    return Response({
        'executions': executions_data,
        'workflows': workflows_data
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def execution_logs_api(request, execution_id):
    """Get execution logs"""
    try:
        execution = WorkflowExecution.objects.get(
            id=execution_id,
            workflow__created_by_id=request.user.id
        )
        
        logs = []
        for node_execution in execution.node_executions.all().order_by('execution_order'):
            logs.append({
                'timestamp': node_execution.started_at.isoformat() if node_execution.started_at else '',
                'level': 'error' if node_execution.status == 'failed' else 'info',
                'node_name': node_execution.node_name,
                'message': node_execution.error_message or f"Node executed with status: {node_execution.status}",
                'duration_ms': node_execution.duration_ms,
                'status': node_execution.status,
                'input_data': node_execution.input_data,
                'output_data': node_execution.output_data
            })
        
        return Response({
            'logs': logs,
            'execution': {
                'id': str(execution.id),
                'status': execution.status,
                'started_at': execution.started_at.isoformat(),
                'finished_at': execution.finished_at.isoformat() if execution.finished_at else None,
                'duration_seconds': execution.duration_seconds
            }
        })
        
    except WorkflowExecution.DoesNotExist:
        return Response({'error': 'Execution not found'}, status=404)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def test_workflow_api(request, workflow_id):
    """Test a workflow with sample data"""
    try:
        workflow = Workflow.objects.get(
            id=workflow_id,
            created_by_id=request.user.id
        )
        
        # Create test execution
        execution = WorkflowExecution.objects.create(
            workflow=workflow,
            triggered_by='manual',
            triggered_by_user_id=request.user.id,
            input_data=request.data.get('input_data', {}),
            execution_context={
                'test_mode': True,
                'manual_trigger': True
            }
        )
        
        # Execute synchronously for testing
        engine = WorkflowEngine()
        success = engine.execute_workflow(str(execution.id))
        execution.refresh_from_db()
        
        return Response({
            'execution_id': str(execution.id),
            'status': execution.status,
            'success': success,
            'output_data': execution.output_data,
            'node_executions': [
                {
                    'node_id': ne.node_id,
                    'node_name': ne.node_name,
                    'status': ne.status,
                    'duration_ms': ne.duration_ms,
                    'output_data': ne.output_data
                }
                for ne in execution.node_executions.all().order_by('execution_order')
            ]
        })
        
    except Workflow.DoesNotExist:
        return Response({'error': 'Workflow not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=500)