"""
Workflow Execution Engine - Core engine for running n8n-like workflows
"""
import time
import json
import logging
import traceback
from typing import Dict, List, Any, Optional, Tuple
from collections import defaultdict, deque
from django.utils import timezone
from django.db import transaction
from django.conf import settings

from .models import WorkflowExecution, NodeExecution, NodeType
from .handlers import get_node_handler
from .utils import VariableResolver, ExpressionEvaluator

logger = logging.getLogger(__name__)

class WorkflowEngine:
    """
    Main workflow execution engine that processes workflows node by node
    """
    
    def __init__(self):
        self.variable_resolver = VariableResolver()
        self.expression_evaluator = ExpressionEvaluator()
    
    def execute_workflow(self, execution_id: str) -> bool:
        """
        Execute a complete workflow
        
        Args:
            execution_id: UUID of the WorkflowExecution to run
            
        Returns:
            bool: True if successful, False if failed
        """
        try:
            execution = WorkflowExecution.objects.select_related('workflow').get(id=execution_id)
            workflow = execution.workflow
            
            logger.info(f"Starting execution of workflow '{workflow.name}' (ID: {execution_id})")
            
            execution.status = 'running'
            execution.save()
            
            definition = workflow.definition
            if not definition or 'nodes' not in definition:
                raise ValueError("Invalid workflow definition - no nodes found")
            
            nodes = definition['nodes']
            connections = definition.get('connections', [])
            
            if not nodes:
                raise ValueError("Workflow has no nodes to execute")
            
            execution_graph = self._build_execution_graph(nodes, connections)
            
            node_results = {}
            execution_context = {
                'workflow_id': str(workflow.id),
                'execution_id': str(execution.id),
                'input_data': execution.input_data,
                'variables': self._load_workflow_variables(workflow),
                'test_mode': execution.execution_context.get('test_mode', False)
            }
            
            success = self._execute_nodes(
                execution, 
                execution_graph, 
                execution_context,
                node_results
            )
            
            execution.status = 'success' if success else 'failed'
            execution.finished_at = timezone.now()
            execution.calculate_duration()
            execution.output_data = self._sanitize_data_for_storage(node_results)
            execution.save()
            
            logger.info(f"Workflow execution completed with status: {execution.status}")
            return success
            
        except Exception as e:
            logger.error(f"Workflow execution failed: {str(e)}")
            logger.error(traceback.format_exc())
            
            try:
                execution = WorkflowExecution.objects.get(id=execution_id)
                execution.status = 'failed'
                execution.finished_at = timezone.now()
                execution.error_message = str(e)
                execution.error_details = { 'error_type': type(e).__name__, 'traceback': traceback.format_exc() }
                execution.save()
            except WorkflowExecution.DoesNotExist:
                pass
            
            return False

    def _execute_nodes(
        self, 
        execution: WorkflowExecution,
        graph: Dict,
        context: Dict,
        results: Dict
    ) -> bool:
        """
        Execute nodes in the correct order, handling conditional branching.
        """
        execution_order = graph['execution_order']
        node_lookup = graph['nodes']
        
        nodes_to_skip = set()

        for order_index, node_id in enumerate(execution_order):
            if node_id in nodes_to_skip:
                self._create_node_execution_record(
                    execution, node_lookup[node_id], {}, {}, order_index, 'skipped'
                )
                continue

            node_def = node_lookup[node_id]
            
            try:
                node_input = self._prepare_node_input(
                    node_id, node_def, graph['incoming'], results, context
                )
                
                node_result = self._execute_single_node(
                    execution, node_def, node_input, context, order_index
                )
                
                results[node_id] = node_result
                
                # Check for branching instructions from the node result
                if 'branch_condition' in node_result:
                    self._handle_conditional_branching(
                        node_id, 
                        node_result, 
                        graph, 
                        nodes_to_skip
                    )
                
            except Exception as e:
                logger.error(f"Node {node_id} ({node_def.get('name', '')}) execution failed: {str(e)}")
                
                # Create failed node execution record
                self._create_node_execution_record(
                    execution,
                    node_def,
                    node_input if 'node_input' in locals() else {},
                    {},
                    order_index,
                    'failed',
                    str(e)
                )
                
                # Stop execution if configured to do so.
                if not node_def.get('config', {}).get('continue_on_error', False):
                    return False
        
        return True
        
    def _handle_conditional_branching(
        self,
        node_id: str,
        node_result: Dict,
        graph: Dict,
        nodes_to_skip: set
    ):
        """
        Handles conditional branching by identifying which downstream nodes to skip.
        """
        condition_met = node_result['branch_condition']
        outgoing_connections = graph['outgoing'].get(node_id, [])

        # Determine which output path was NOT taken
        path_to_skip = 'true_path' if not condition_met else 'false_path'
        
        # Find the connection for the path that should be skipped
        for connection in outgoing_connections:
            # Assumes your connection definition includes which output it comes from
            # e.g., source_output can be 'true_path' or 'false_path'
            if connection.get('source_output') == path_to_skip:
                # Start a traversal from the target of the skipped path
                nodes_to_traverse = deque([connection['target']])
                visited_for_skipping = set([connection['target']])
                
                while nodes_to_traverse:
                    current_node_id = nodes_to_traverse.popleft()
                    nodes_to_skip.add(current_node_id)
                    
                    # Add all downstream nodes to the traversal queue
                    for downstream_conn in graph['outgoing'].get(current_node_id, []):
                        downstream_node_id = downstream_conn['target']
                        if downstream_node_id not in visited_for_skipping:
                            visited_for_skipping.add(downstream_node_id)
                            nodes_to_traverse.append(downstream_node_id)

    def _build_execution_graph(self, nodes: List[Dict], connections: List[Dict]) -> Dict:
        """
        Build a graph representation of the workflow for execution planning
        
        Args:
            nodes: List of node definitions
            connections: List of connection definitions
            
        Returns:
            Dict containing graph structure with dependencies and execution order
        """
        # Create node lookup
        node_lookup = {node['id']: node for node in nodes}
        
        # Build adjacency lists
        incoming = defaultdict(list)  # nodes that feed into this node
        outgoing = defaultdict(list)  # nodes this node feeds into
        
        for connection in connections:
            source = connection['source']
            target = connection['target']
            
            if source in node_lookup and target in node_lookup:
                outgoing[source].append({
                    'target': target,
                    'source_output': connection.get('source_output', 'main'),
                    'target_input': connection.get('target_input', 'main')
                })
                incoming[target].append({
                    'source': source,
                    'source_output': connection.get('source_output', 'main'),
                    'target_input': connection.get('target_input', 'main')
                })
        
        # Find trigger nodes (nodes with no incoming connections)
        trigger_nodes = []
        for node in nodes:
            node_id = node['id']
            if not incoming[node_id]:
                trigger_nodes.append(node_id)
        
        if not trigger_nodes:
            raise ValueError("Workflow has no trigger nodes (nodes without incoming connections)")
        
        # Calculate execution order using topological sort
        execution_order = self._topological_sort(nodes, incoming, outgoing)
        
        return {
            'nodes': node_lookup,
            'incoming': dict(incoming),
            'outgoing': dict(outgoing),
            'trigger_nodes': trigger_nodes,
            'execution_order': execution_order
        }
    
    def _topological_sort(self, nodes: List[Dict], incoming: Dict, outgoing: Dict) -> List[str]:
        """
        Perform topological sort to determine execution order
        
        Args:
            nodes: List of node definitions
            incoming: Incoming connections for each node
            outgoing: Outgoing connections for each node
            
        Returns:
            List of node IDs in execution order
        """
        # Kahn's algorithm for topological sorting
        in_degree = {}
        for node in nodes:
            node_id = node['id']
            in_degree[node_id] = len(incoming.get(node_id, []))
        
        queue = deque([node_id for node_id, degree in in_degree.items() if degree == 0])
        result = []
        
        while queue:
            current = queue.popleft()
            result.append(current)
            
            # Reduce in-degree for all neighbors
            for connection in outgoing.get(current, []):
                target = connection['target']
                in_degree[target] -= 1
                if in_degree[target] == 0:
                    queue.append(target)
        
        # Check for cycles
        if len(result) != len(nodes):
            remaining_nodes = [node['id'] for node in nodes if node['id'] not in result]
            raise ValueError(f"Workflow contains cycles. Remaining nodes: {remaining_nodes}")
        
        return result
    
    def _prepare_node_input(
        self,
        node_id: str,
        node_def: Dict,
        incoming: Dict,
        results: Dict,
        context: Dict
    ) -> Dict:
        """
        Prepare input data for a node based on its incoming connections
        
        Args:
            node_id: ID of the node to prepare input for
            node_def: Node definition
            incoming: Incoming connections
            results: Results from previous nodes
            context: Execution context
            
        Returns:
            Dict containing prepared input data
        """
        node_input = {
            'context': context,
            'workflow_input': context['input_data']
        }
        
        # Get data from incoming connections
        connections = incoming.get(node_id, [])
        
        if not connections:
            # This is a trigger node, use workflow input
            node_input['data'] = context['input_data']
        elif len(connections) == 1:
            # Single input connection
            connection = connections[0]
            source_id = connection['source']
            source_output = connection['source_output']
            
            if source_id in results:
                source_result = results[source_id]
                if source_output == 'main' or source_output not in source_result:
                    node_input['data'] = source_result.get('data', {})
                else:
                    node_input['data'] = source_result.get(source_output, {})
            else:
                node_input['data'] = {}
        else:
            # Multiple input connections - merge data
            merged_data = {}
            for connection in connections:
                source_id = connection['source']
                source_output = connection['source_output']
                target_input = connection['target_input']
                
                if source_id in results:
                    source_result = results[source_id]
                    if source_output == 'main' or source_output not in source_result:
                        source_data = source_result.get('data', {})
                    else:
                        source_data = source_result.get(source_output, {})
                    
                    if target_input == 'main':
                        if isinstance(merged_data, dict) and isinstance(source_data, dict):
                            merged_data.update(source_data)
                        else:
                            merged_data = source_data
                    else:
                        merged_data[target_input] = source_data
            
            node_input['data'] = merged_data
        
        return node_input
    
    def _execute_single_node(
        self,
        execution: WorkflowExecution,
        node_def: Dict,
        node_input: Dict,
        context: Dict,
        execution_order: int
    ) -> Dict:
        """
        Execute a single node
        
        Args:
            execution: WorkflowExecution instance
            node_def: Node definition
            node_input: Prepared input data
            context: Execution context
            execution_order: Order in execution sequence
            
        Returns:
            Dict containing node execution result
        """
        node_id = node_def['id']
        node_type = node_def['type']
        node_name = node_def.get('name', node_type)
        
        logger.info(f"Executing node: {node_name} ({node_id})")
        
        start_time = time.time()
        
        try:
            # Get node handler
            handler = get_node_handler(node_type)
            if not handler:
                raise ValueError(f"No handler found for node type: {node_type}")
            
            # Resolve variables in node configuration
            node_config = self._resolve_node_config(
                node_def.get('config', {}),
                context,
                node_input
            )
            
            # Execute the node
            result = handler.execute(node_config, node_input, context)
            
            # Ensure result is a dictionary
            if not isinstance(result, dict):
                result = {'data': result}
            
            execution_time = (time.time() - start_time) * 1000  # Convert to milliseconds
            
            # Create successful node execution record
            self._create_node_execution_record(
                execution,
                node_def,
                node_input,
                result,
                execution_order,
                'success',
                None,
                execution_time
            )
            
            logger.info(f"Node {node_name} executed successfully in {execution_time:.2f}ms")
            return result
            
        except Exception as e:
            execution_time = (time.time() - start_time) * 1000
            error_msg = str(e)
            
            logger.error(f"Node {node_name} failed: {error_msg}")
            
            # Create failed node execution record
            self._create_node_execution_record(
                execution,
                node_def,
                node_input,
                {},
                execution_order,
                'failed',
                error_msg,
                execution_time
            )
            
            raise
    
    def _resolve_node_config(self, config: Dict, context: Dict, node_input: Dict) -> Dict:
        """
        Resolve variables and expressions in node configuration
        
        Args:
            config: Raw node configuration
            context: Execution context
            node_input: Node input data
            
        Returns:
            Dict with resolved configuration
        """
        resolved_config = {}
        
        for key, value in config.items():
            if isinstance(value, str):
                # Resolve variables and expressions
                resolved_value = self.variable_resolver.resolve(
                    value, 
                    context, 
                    node_input
                )
                resolved_config[key] = resolved_value
            elif isinstance(value, dict):
                resolved_config[key] = self._resolve_node_config(value, context, node_input)
            elif isinstance(value, list):
                resolved_config[key] = [
                    self._resolve_node_config(item, context, node_input) if isinstance(item, dict)
                    else self.variable_resolver.resolve(item, context, node_input) if isinstance(item, str)
                    else item
                    for item in value
                ]
            else:
                resolved_config[key] = value
        
        return resolved_config
    
    def _create_node_execution_record(
        self,
        execution: WorkflowExecution,
        node_def: Dict,
        input_data: Dict,
        output_data: Dict,
        execution_order: int,
        status: str,
        error_message: Optional[str] = None,
        duration_ms: Optional[float] = None
    ):
        """
        Create a NodeExecution record
        
        Args:
            execution: WorkflowExecution instance
            node_def: Node definition
            input_data: Input data for the node
            output_data: Output data from the node
            execution_order: Order in execution sequence
            status: Execution status
            error_message: Error message if failed
            duration_ms: Execution duration in milliseconds
        """
        node_execution = NodeExecution.objects.create(
            workflow_execution=execution,
            node_id=node_def['id'],
            node_type=node_def['type'],
            node_name=node_def.get('name', node_def['type']),
            status=status,
            execution_order=execution_order,
            started_at=timezone.now(),
            finished_at=timezone.now(),
            duration_ms=duration_ms,
            input_data=self._sanitize_data_for_storage(input_data),
            output_data=self._sanitize_data_for_storage(output_data),
            error_message=error_message or '',
            node_config=node_def.get('config', {})
        )
        
        return node_execution
    
    def _sanitize_data_for_storage(self, data: Any) -> Dict:
        """
        Sanitize data for database storage (remove sensitive info, limit size)
        
        Args:
            data: Data to sanitize
            
        Returns:
            Sanitized data safe for storage
        """
        if not isinstance(data, (dict, list)):
            return {'value': str(data)[:1000]}  # Limit string length
        
        try:
            # Convert to JSON and back to ensure serializability
            json_str = json.dumps(data, default=str)
            
            # Limit size to prevent database issues
            if len(json_str) > 10000:  # 10KB limit
                return {'_truncated': True, '_size': len(json_str), 'preview': json_str[:1000]}
            
            return json.loads(json_str)
        except:
            return {'_error': 'Could not serialize data', 'type': str(type(data))}
    
    def _load_workflow_variables(self, workflow) -> Dict:
        """
        Load workflow variables for use in execution
        
        Args:
            workflow: Workflow instance
            
        Returns:
            Dict of workflow variables
        """
        variables = {}
        
        # Load workflow-specific variables
        for var in workflow.variables.all():
            variables[var.name] = var.value
        
        # Load global variables
        from .models import WorkflowVariable
        global_vars = WorkflowVariable.objects.filter(
            scope='global',
            workflow__isnull=True
        )
        
        for var in global_vars:
            if var.name not in variables:  # Workflow variables override global
                variables[var.name] = var.value
        
        return variables

class ExecutionTimeout:
    """Context manager for execution timeouts"""
    
    def __init__(self, seconds: int):
        self.seconds = seconds
        self.start_time = None
    
    def __enter__(self):
        self.start_time = time.time()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        pass
    
    def check_timeout(self):
        if self.start_time and time.time() - self.start_time > self.seconds:
            raise TimeoutError(f"Execution exceeded {self.seconds} seconds")
