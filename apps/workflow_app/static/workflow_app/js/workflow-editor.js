/**
 * Complete Workflow Editor Implementation
 */
class WorkflowEditor {
    constructor(options = {}) {
        this.options = {
            workflowId: null,
            workflowData: { nodes: [], connections: [] },
            csrfToken: null,
            apiBaseUrl: '/api/workflows/',
            autoSave: true,
            ...options
        };

        // State
        this.workflow = null;
        this.nodes = new Map();
        this.connections = new Map();
        this.selectedNode = null;
        this.selectedConnection = null;
        this.isDirty = false;
        this.isLoading = false;
        this.nodeTypes = new Map();

        // Canvas state
        this.canvas = {
            scale: 1,
            offsetX: 0,
            offsetY: 0,
            isDragging: false,
            isConnecting: false,
            connectionStart: null,
            dragStart: null
        };

        this.init();
    }

    async init() {
        this.setupDOM();
        this.setupEventListeners();
        await this.loadNodeTypes();
        this.loadWorkflow();
        this.renderNodePalette();
    }

    setupDOM() {
        // Ensure all required DOM elements exist
        if (!document.getElementById('workflow-canvas')) {
            const canvasContainer = document.querySelector('.canvas-container');
            if (canvasContainer) {
                canvasContainer.innerHTML = `
                    <div class="canvas-wrapper">
                        <div id="workflow-canvas" class="workflow-canvas">
                            <svg class="connections-layer" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1;">
                                <defs>
                                    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                                        <polygon points="0 0, 10 3.5, 0 7" fill="#666" />
                                    </marker>
                                </defs>
                            </svg>
                            <div class="nodes-layer" style="position: relative; z-index: 2;"></div>
                        </div>
                    </div>
                `;
            }
        }

        this.canvas.element = document.getElementById('workflow-canvas');
        this.connectionsLayer = document.querySelector('.connections-layer');
        this.nodesLayer = document.querySelector('.nodes-layer');
    }

    setupEventListeners() {
        // Toolbar buttons
        document.getElementById('save-btn')?.addEventListener('click', () => this.saveWorkflow());
        document.getElementById('test-btn')?.addEventListener('click', () => this.testWorkflow());
        document.getElementById('deploy-btn')?.addEventListener('click', () => this.deployWorkflow());
        
        // Workflow name and description
        document.getElementById('workflow-name')?.addEventListener('change', (e) => {
            this.updateWorkflowProperty('name', e.target.value);
        });
        
        document.getElementById('workflow-description')?.addEventListener('change', (e) => {
            this.updateWorkflowProperty('description', e.target.value);
        });

        // Canvas events
        if (this.canvas.element) {
            this.canvas.element.addEventListener('dragover', this.onDragOver.bind(this));
            this.canvas.element.addEventListener('drop', this.onDrop.bind(this));
            this.canvas.element.addEventListener('click', this.onCanvasClick.bind(this));
        }

        // Node palette search
        document.getElementById('node-search')?.addEventListener('input', (e) => {
            this.filterNodes(e.target.value);
        });

        // Tab switching
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab);
            });
        });

        // Zoom controls
        document.getElementById('zoom-in')?.addEventListener('click', () => this.zoomIn());
        document.getElementById('zoom-out')?.addEventListener('click', () => this.zoomOut());
        document.getElementById('zoom-fit')?.addEventListener('click', () => this.fitToView());

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch (e.key) {
                    case 's':
                        e.preventDefault();
                        this.saveWorkflow();
                        break;
                    case 'Enter':
                        if (e.shiftKey) {
                            e.preventDefault();
                            this.testWorkflow();
                        }
                        break;
                }
            }
            
            if (e.key === 'Delete' && this.selectedNode) {
                this.deleteNode(this.selectedNode);
            }
        });
    }

    async loadNodeTypes() {
        try {
            const response = await fetch('/api/node-types/', {
                credentials: 'same-origin'
            });
            
            if (response.ok) {
                const nodeTypes = await response.json();
                nodeTypes.forEach(nodeType => {
                    this.nodeTypes.set(nodeType.name, nodeType);
                });
            } else {
                // Load default node types if API fails
                this.loadDefaultNodeTypes();
            }
        } catch (error) {
            console.warn('Failed to load node types from API:', error);
            this.loadDefaultNodeTypes();
        }
    }

    loadDefaultNodeTypes() {
        const defaultTypes = [
            {
                name: 'manual_trigger',
                display_name: 'Manual Trigger',
                category: 'trigger',
                icon: 'fa-play',
                color: '#10b981',
                description: 'Manually triggered workflow start',
                config_schema: { fields: [] }
            },
            {
                name: 'database_query',
                display_name: 'Database Query',
                category: 'data',
                icon: 'fa-database',
                color: '#8b5cf6',
                description: 'Query GRM database',
                config_schema: {
                    fields: [
                        { name: 'query_type', type: 'select', options: ['SELECT', 'INSERT', 'UPDATE', 'DELETE'], default: 'SELECT', label: 'Query Type' },
                        { name: 'table_name', type: 'text', required: true, label: 'Table Name' },
                        { name: 'conditions', type: 'text', label: 'WHERE Conditions' },
                        { name: 'fields', type: 'text', default: '*', label: 'Fields' },
                        { name: 'limit', type: 'number', default: 100, label: 'Limit' }
                    ]
                }
            },
            {
                name: 'http_request',
                display_name: 'HTTP Request',
                category: 'data',
                icon: 'fa-globe',
                color: '#3b82f6',
                description: 'Make HTTP requests',
                config_schema: {
                    fields: [
                        { name: 'method', type: 'select', options: ['GET', 'POST', 'PUT', 'DELETE'], default: 'GET', label: 'Method' },
                        { name: 'url', type: 'text', required: true, label: 'URL' },
                        { name: 'headers', type: 'textarea', label: 'Headers (JSON)' },
                        { name: 'body', type: 'textarea', label: 'Body' }
                    ]
                }
            },
            {
                name: 'condition',
                display_name: 'Condition',
                category: 'condition',
                icon: 'fa-code-branch',
                color: '#ef4444',
                description: 'Conditional branching',
                config_schema: {
                    fields: [
                        { name: 'conditions', type: 'textarea', required: true, label: 'Conditions (JSON)' },
                        { name: 'logic_operator', type: 'select', options: ['AND', 'OR'], default: 'AND', label: 'Logic' }
                    ]
                }
            },
            {
                name: 'email_send',
                display_name: 'Send Email',
                category: 'action',
                icon: 'fa-envelope',
                color: '#06b6d4',
                description: 'Send email notifications',
                config_schema: {
                    fields: [
                        { name: 'to', type: 'text', required: true, label: 'To' },
                        { name: 'subject', type: 'text', required: true, label: 'Subject' },
                        { name: 'body', type: 'textarea', required: true, label: 'Body' }
                    ]
                }
            },
            {
                name: 'log',
                display_name: 'Log Message',
                category: 'action',
                icon: 'fa-file-text',
                color: '#6b7280',
                description: 'Log messages',
                config_schema: {
                    fields: [
                        { name: 'message', type: 'textarea', label: 'Message' },
                        { name: 'level', type: 'select', options: ['info', 'warning', 'error'], default: 'info', label: 'Level' }
                    ]
                }
            }
        ];

        defaultTypes.forEach(nodeType => {
            this.nodeTypes.set(nodeType.name, nodeType);
        });
    }

    renderNodePalette() {
        const categories = this.groupNodesByCategory();
        
        Object.entries(categories).forEach(([category, nodes]) => {
            const categoryElement = document.querySelector(`[data-category="${category}"] .category-nodes`);
            if (categoryElement) {
                categoryElement.innerHTML = '';
                
                nodes.forEach(nodeType => {
                    const nodeElement = this.createPaletteNode(nodeType);
                    categoryElement.appendChild(nodeElement);
                });
            }
        });

        // Setup category toggles
        document.querySelectorAll('.category-header').forEach(header => {
            header.addEventListener('click', () => {
                const category = header.closest('.node-category');
                category.classList.toggle('collapsed');
            });
        });
    }

    groupNodesByCategory() {
        const categories = {};
        
        this.nodeTypes.forEach(nodeType => {
            const category = nodeType.category || 'other';
            if (!categories[category]) {
                categories[category] = [];
            }
            categories[category].push(nodeType);
        });

        return categories;
    }

    createPaletteNode(nodeType) {
        const nodeDiv = document.createElement('div');
        nodeDiv.className = 'palette-node';
        nodeDiv.draggable = true;
        nodeDiv.setAttribute('data-node-type', nodeType.name);
        nodeDiv.title = nodeType.description;

        nodeDiv.innerHTML = `
            <div class="node-icon" style="background-color: ${nodeType.color}">
                <i class="fas ${nodeType.icon}"></i>
            </div>
            <span class="node-name">${nodeType.display_name}</span>
        `;

        nodeDiv.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', nodeType.name);
            e.dataTransfer.setData('application/json', JSON.stringify(nodeType));
        });

        return nodeDiv;
    }

    onDragOver(e) {
        e.preventDefault();
    }

    onDrop(e) {
        e.preventDefault();
        
        const nodeTypeName = e.dataTransfer.getData('text/plain');
        const nodeType = this.nodeTypes.get(nodeTypeName);
        
        if (!nodeType) return;

        const rect = this.canvas.element.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        this.addNode(nodeType, { x, y });
    }

    addNode(nodeType, position) {
        const nodeId = this.generateId();
        const node = {
            id: nodeId,
            type: nodeType.name,
            name: nodeType.display_name,
            position: position,
            config: {},
            status: 'pending'
        };

        this.nodes.set(nodeId, node);
        this.renderNode(node);
        this.markDirty();
        
        return nodeId;
    }

    renderNode(node) {
        let nodeElement = document.querySelector(`[data-node-id="${node.id}"]`);
        
        if (!nodeElement) {
            nodeElement = document.createElement('div');
            nodeElement.className = 'workflow-node';
            nodeElement.setAttribute('data-node-id', node.id);
            nodeElement.style.position = 'absolute';
            this.nodesLayer.appendChild(nodeElement);
        }

        const nodeType = this.nodeTypes.get(node.type);
        const isSelected = this.selectedNode === node.id;

        nodeElement.className = `workflow-node ${isSelected ? 'selected' : ''} status-${node.status}`;
        nodeElement.style.left = `${node.position.x}px`;
        nodeElement.style.top = `${node.position.y}px`;

        nodeElement.innerHTML = `
            <div class="node-header">
                <div class="node-icon" style="background-color: ${nodeType?.color || '#6b7280'}">
                    <i class="fas ${nodeType?.icon || 'fa-cube'}"></i>
                </div>
                <div class="node-title">${node.name}</div>
                <div class="node-status ${node.status}"></div>
            </div>
            <div class="node-body">
                ${this.getNodeDescription(node)}
            </div>
            <div class="node-handles">
                <div class="node-handle input" data-handle="input"></div>
                <div class="node-handle output" data-handle="output"></div>
            </div>
        `;

        // Add event listeners
        nodeElement.addEventListener('click', (e) => {
            e.stopPropagation();
            this.selectNode(node.id);
        });

        nodeElement.addEventListener('mousedown', (e) => {
            if (e.target.classList.contains('node-handle')) return;
            this.startNodeDrag(e, node.id);
        });

        // Handle connection events
        const handles = nodeElement.querySelectorAll('.node-handle');
        handles.forEach(handle => {
            handle.addEventListener('mousedown', (e) => {
                e.stopPropagation();
                this.startConnection(e, node.id, handle.dataset.handle, handle.classList.contains('output'));
            });
        });
    }

    getNodeDescription(node) {
        const config = node.config || {};
        const keys = Object.keys(config);
        
        if (keys.length > 0) {
            const firstKey = keys[0];
            const value = config[firstKey];
            return `${firstKey}: ${String(value).substring(0, 30)}${String(value).length > 30 ? '...' : ''}`;
        }
        
        return 'Click to configure';
    }

    selectNode(nodeId) {
        // Clear previous selection
        document.querySelectorAll('.workflow-node.selected').forEach(el => {
            el.classList.remove('selected');
        });

        this.selectedNode = nodeId;
        this.selectedConnection = null;

        // Highlight selected node
        const nodeElement = document.querySelector(`[data-node-id="${nodeId}"]`);
        if (nodeElement) {
            nodeElement.classList.add('selected');
        }

        // Show properties panel
        this.showNodeProperties(nodeId);
    }

    showNodeProperties(nodeId) {
        const node = this.nodes.get(nodeId);
        const nodeType = this.nodeTypes.get(node.type);
        
        if (!node || !nodeType) return;

        // Update panel title
        document.getElementById('panel-title').textContent = node.name;

        // Hide other sections
        document.getElementById('no-selection').style.display = 'none';
        document.getElementById('connection-properties').style.display = 'none';

        // Show node properties
        const propertiesContainer = document.getElementById('node-properties');
        propertiesContainer.style.display = 'block';
        propertiesContainer.innerHTML = this.generateNodePropertiesForm(node, nodeType);

        // Setup form listeners
        this.setupPropertiesFormListeners(propertiesContainer, nodeId);
    }

    generateNodePropertiesForm(node, nodeType) {
        let html = `
            <div class="form-section">
                <h4>General</h4>
                <div class="form-group">
                    <label for="node-name">Node Name</label>
                    <input type="text" id="node-name" name="name" value="${node.name}" class="form-control">
                </div>
            </div>
        `;

        if (nodeType.config_schema && nodeType.config_schema.fields) {
            html += `<div class="form-section"><h4>Configuration</h4>`;

            nodeType.config_schema.fields.forEach(field => {
                const value = node.config[field.name] || field.default || '';
                html += this.generateFormField(field, value);
            });

            html += `</div>`;
        }

        return html;
    }

    generateFormField(field, value) {
        const fieldId = `field-${field.name}`;
        const required = field.required ? 'required' : '';

        let html = `<div class="form-group">`;
        html += `<label for="${fieldId}">${field.label || field.name}</label>`;

        switch (field.type) {
            case 'text':
                html += `<input type="text" id="${fieldId}" name="${field.name}" value="${value}" class="form-control" ${required}>`;
                break;
            case 'number':
                html += `<input type="number" id="${fieldId}" name="${field.name}" value="${value}" class="form-control" ${required}>`;
                break;
            case 'textarea':
                html += `<textarea id="${fieldId}" name="${field.name}" class="form-control" rows="3" ${required}>${value}</textarea>`;
                break;
            case 'select':
                html += `<select id="${fieldId}" name="${field.name}" class="form-control" ${required}>`;
                field.options.forEach(option => {
                    const selected = value === option ? 'selected' : '';
                    html += `<option value="${option}" ${selected}>${option}</option>`;
                });
                html += `</select>`;
                break;
            case 'checkbox':
                const checked = value === true || value === 'true' ? 'checked' : '';
                html += `<input type="checkbox" id="${fieldId}" name="${field.name}" ${checked}>`;
                break;
            default:
                html += `<input type="text" id="${fieldId}" name="${field.name}" value="${value}" class="form-control" ${required}>`;
        }

        html += `</div>`;
        return html;
    }

    setupPropertiesFormListeners(container, nodeId) {
        const formElements = container.querySelectorAll('input, select, textarea');
        
        formElements.forEach(element => {
            element.addEventListener('change', (e) => {
                this.updateNodeProperty(nodeId, e.target.name, e.target.value);
            });
        });
    }

    updateNodeProperty(nodeId, property, value) {
        const node = this.nodes.get(nodeId);
        if (!node) return;

        if (property === 'name') {
            node.name = value;
        } else {
            if (!node.config) node.config = {};
            node.config[property] = value;
        }

        this.renderNode(node);
        this.markDirty();
    }

    updateWorkflowProperty(property, value) {
        if (!this.workflow) {
            this.workflow = {
                name: 'Untitled Workflow',
                description: '',
                definition: { nodes: [], connections: [] }
            };
        }

        this.workflow[property] = value;
        this.markDirty();
    }

    startNodeDrag(e, nodeId) {
        this.canvas.isDragging = true;
        this.canvas.dragStart = {
            x: e.clientX,
            y: e.clientY,
            nodeId: nodeId
        };

        document.addEventListener('mousemove', this.onNodeDrag.bind(this));
        document.addEventListener('mouseup', this.onNodeDragEnd.bind(this));
    }

    onNodeDrag(e) {
        if (!this.canvas.isDragging || !this.canvas.dragStart) return;

        const dx = e.clientX - this.canvas.dragStart.x;
        const dy = e.clientY - this.canvas.dragStart.y;

        const node = this.nodes.get(this.canvas.dragStart.nodeId);
        if (node) {
            node.position.x += dx;
            node.position.y += dy;
            this.renderNode(node);
        }

        this.canvas.dragStart.x = e.clientX;
        this.canvas.dragStart.y = e.clientY;
    }

    onNodeDragEnd(e) {
        this.canvas.isDragging = false;
        this.canvas.dragStart = null;
        this.markDirty();

        document.removeEventListener('mousemove', this.onNodeDrag.bind(this));
        document.removeEventListener('mouseup', this.onNodeDragEnd.bind(this));
    }

    startConnection(e, nodeId, handle, isOutput) {
        if (!isOutput) return; // Only start connections from output handles

        this.canvas.isConnecting = true;
        this.canvas.connectionStart = { nodeId, handle };

        document.addEventListener('mousemove', this.onConnectionDrag.bind(this));
        document.addEventListener('mouseup', this.onConnectionEnd.bind(this));
    }

    onConnectionDrag(e) {
        // Visual feedback for connection dragging
        // This would show a temporary line following the mouse
    }

    onConnectionEnd(e) {
        if (!this.canvas.isConnecting) return;

        // Find target handle
        const target = e.target;
        if (target && target.classList.contains('node-handle') && target.classList.contains('input')) {
            const targetNodeElement = target.closest('.workflow-node');
            const targetNodeId = targetNodeElement.getAttribute('data-node-id');
            const targetHandle = target.dataset.handle;

            if (targetNodeId !== this.canvas.connectionStart.nodeId) {
                this.addConnection(
                    this.canvas.connectionStart.nodeId,
                    this.canvas.connectionStart.handle,
                    targetNodeId,
                    targetHandle
                );
            }
        }

        this.canvas.isConnecting = false;
        this.canvas.connectionStart = null;

        document.removeEventListener('mousemove', this.onConnectionDrag.bind(this));
        document.removeEventListener('mouseup', this.onConnectionEnd.bind(this));
    }

    addConnection(sourceNodeId, sourceHandle, targetNodeId, targetHandle) {
        const connectionId = this.generateId();
        const connection = {
            id: connectionId,
            source: sourceNodeId,
            sourceHandle: sourceHandle,
            target: targetNodeId,
            targetHandle: targetHandle
        };

        this.connections.set(connectionId, connection);
        this.renderConnection(connection);
        this.markDirty();
    }

    renderConnection(connection) {
        const sourceNode = this.nodes.get(connection.source);
        const targetNode = this.nodes.get(connection.target);

        if (!sourceNode || !targetNode) return;

        const sourcePos = this.getNodeHandlePosition(sourceNode, 'output');
        const targetPos = this.getNodeHandlePosition(targetNode, 'input');

        let connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connection.id}"]`);

        if (!connectionElement) {
            connectionElement = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            connectionElement.setAttribute('data-connection-id', connection.id);
            connectionElement.setAttribute('class', 'connection-line');
            connectionElement.setAttribute('marker-end', 'url(#arrowhead)');
            this.connectionsLayer.appendChild(connectionElement);

            connectionElement.addEventListener('click', (e) => {
                e.stopPropagation();
                this.selectConnection(connection.id);
            });
        }

        const path = this.createConnectionPath(sourcePos, targetPos);
        connectionElement.setAttribute('d', path);
    }

    getNodeHandlePosition(node, handleType) {
        const nodeElement = document.querySelector(`[data-node-id="${node.id}"]`);
        if (!nodeElement) return { x: 0, y: 0 };

        const nodeRect = nodeElement.getBoundingClientRect();
        const canvasRect = this.canvas.element.getBoundingClientRect();

        const handleElement = nodeElement.querySelector(`.node-handle.${handleType}`);
        if (!handleElement) return { x: 0, y: 0 };

        const handleRect = handleElement.getBoundingClientRect();

        return {
            x: handleRect.left + handleRect.width / 2 - canvasRect.left,
            y: handleRect.top + handleRect.height / 2 - canvasRect.top
        };
    }

    createConnectionPath(start, end) {
        const dx = end.x - start.x;
        const controlOffset = Math.max(50, Math.abs(dx) * 0.5);

        return `M ${start.x} ${start.y} C ${start.x + controlOffset} ${start.y}, ${end.x - controlOffset} ${end.y}, ${end.x} ${end.y}`;
    }

    selectConnection(connectionId) {
        this.selectedConnection = connectionId;
        this.selectedNode = null;

        // Clear node selection
        document.querySelectorAll('.workflow-node.selected').forEach(el => {
            el.classList.remove('selected');
        });

        // Highlight connection
        document.querySelectorAll('.connection-line.selected').forEach(el => {
            el.classList.remove('selected');
        });

        const connectionElement = document.querySelector(`[data-connection-id="${connectionId}"]`);
        if (connectionElement) {
            connectionElement.classList.add('selected');
        }
    }

    deleteNode(nodeId) {
        // Remove connections
        const connectionsToRemove = [];
        this.connections.forEach((connection, id) => {
            if (connection.source === nodeId || connection.target === nodeId) {
                connectionsToRemove.push(id);
            }
        });

        connectionsToRemove.forEach(id => this.deleteConnection(id));

        // Remove node
        this.nodes.delete(nodeId);
        const nodeElement = document.querySelector(`[data-node-id="${nodeId}"]`);
        if (nodeElement) {
            nodeElement.remove();
        }

        this.selectedNode = null;
        this.hideProperties();
        this.markDirty();
    }

    deleteConnection(connectionId) {
        this.connections.delete(connectionId);
        const connectionElement = document.querySelector(`[data-connection-id="${connectionId}"]`);
        if (connectionElement) {
            connectionElement.remove();
        }
        this.markDirty();
    }

    onCanvasClick(e) {
        if (e.target === this.canvas.element) {
            this.clearSelection();
        }
    }

    clearSelection() {
        this.selectedNode = null;
        this.selectedConnection = null;

        document.querySelectorAll('.workflow-node.selected').forEach(el => {
            el.classList.remove('selected');
        });

        document.querySelectorAll('.connection-line.selected').forEach(el => {
            el.classList.remove('selected');
        });

        this.hideProperties();
    }

    hideProperties() {
        document.getElementById('no-selection').style.display = 'flex';
        document.getElementById('node-properties').style.display = 'none';
        document.getElementById('connection-properties').style.display = 'none';
    }

    async saveWorkflow() {
        if (this.isLoading) return;

        this.isLoading = true;
        this.showLoading('Saving workflow...');

        try {
            const workflowData = this.getWorkflowData();
            
            const url = this.options.workflowId 
                ? `/api/workflows/${this.options.workflowId}/`
                : '/api/workflows/';
            
            const method = this.options.workflowId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': this.getCsrfToken()
                },
                credentials: 'same-origin',
                body: JSON.stringify(workflowData)
            });

            const result = await response.json();

            if (response.ok) {
                this.workflow = result;
                this.options.workflowId = result.id;
                this.isDirty = false;
                this.showNotification('Workflow saved successfully', 'success');
                
                // Update URL if this was a new workflow
                if (!this.options.workflowId) {
                    window.history.replaceState({}, '', `/workflows/${result.id}/edit/`);
                }
            } else {
                throw new Error(result.error || 'Failed to save workflow');
            }
        } catch (error) {
            console.error('Save error:', error);
            this.showNotification('Failed to save workflow', 'error');
        } finally {
            this.isLoading = false;
            this.hideLoading();
        }
    }

    async testWorkflow() {
        if (!this.options.workflowId) {
            this.showNotification('Please save the workflow first', 'warning');
            return;
        }

        this.showLoading('Testing workflow...');

        try {
            const response = await fetch(`/api/workflows/${this.options.workflowId}/test/`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': this.getCsrfToken()
                },
                credentials: 'same-origin',
                body: JSON.stringify({
                    input_data: {}
                })
            });

            const result = await response.json();

            if (response.ok) {
                this.showTestResults(result);
                this.showNotification('Workflow test completed', 'success');
            } else {
                throw new Error(result.error || 'Test failed');
            }
        } catch (error) {
            console.error('Test error:', error);
            this.showNotification('Workflow test failed', 'error');
        } finally {
            this.hideLoading();
        }
    }

    showTestResults(result) {
        const logsContainer = document.getElementById('execution-logs');
        if (!logsContainer) return;

        let logsHtml = '<div class="test-results">';
        logsHtml += `<div class="test-summary">Test execution ${result.status} in ${result.duration_seconds || 0}s</div>`;
        logsHtml += '</div>';

        if (result.node_executions) {
            result.node_executions.forEach(nodeExec => {
                logsHtml += `
                    <div class="log-entry log-${nodeExec.status === 'failed' ? 'error' : 'info'}">
                        <div class="log-node">${nodeExec.node_name}</div>
                        <div class="log-message">Status: ${nodeExec.status}</div>
                        ${nodeExec.duration_ms ? `<div class="log-duration">${nodeExec.duration_ms}ms</div>` : ''}
                    </div>
                `;

                // Update node visual status
                const nodeElement = document.querySelector(`[data-node-id="${nodeExec.node_id}"]`);
                if (nodeElement) {
                    nodeElement.className = nodeElement.className.replace(/status-\w+/, `status-${nodeExec.status}`);
                }
            });
        }

        logsContainer.innerHTML = logsHtml;
        this.switchTab('logs');
    }

    async deployWorkflow() {
        if (!this.options.workflowId) {
            this.showNotification('Please save the workflow first', 'warning');
            return;
        }

        if (confirm('Deploy this workflow? It will be activated and ready to run.')) {
            try {
                const response = await fetch(`/api/workflows/${this.options.workflowId}/activate/`, {
                    method: 'POST',
                    headers: {
                        'X-CSRFToken': this.getCsrfToken()
                    },
                    credentials: 'same-origin'
                });

                const result = await response.json();

                if (response.ok) {
                    this.workflow.status = 'active';
                    this.updateWorkflowStatus('active');
                    this.showNotification('Workflow deployed successfully', 'success');
                } else {
                    throw new Error(result.error || 'Deploy failed');
                }
            } catch (error) {
                console.error('Deploy error:', error);
                this.showNotification('Failed to deploy workflow', 'error');
            }
        }
    }

    updateWorkflowStatus(status) {
        const statusElement = document.querySelector('.workflow-status');
        if (statusElement) {
            statusElement.className = `workflow-status status-${status}`;
            statusElement.textContent = status.charAt(0).toUpperCase() + status.slice(1);
        }
    }

    getWorkflowData() {
        const nodes = [];
        const connections = [];

        this.nodes.forEach(node => {
            nodes.push({
                id: node.id,
                type: node.type,
                name: node.name,
                position: node.position,
                config: node.config || {}
            });
        });

        this.connections.forEach(connection => {
            connections.push({
                id: connection.id,
                source: connection.source,
                sourceHandle: connection.sourceHandle,
                target: connection.target,
                targetHandle: connection.targetHandle
            });
        });

        return {
            name: document.getElementById('workflow-name')?.value || 'Untitled Workflow',
            description: document.getElementById('workflow-description')?.value || '',
            definition: { nodes, connections }
        };
    }

    loadWorkflow() {
        if (this.options.workflowData && this.options.workflowData.nodes) {
            this.options.workflowData.nodes.forEach(nodeData => {
                this.nodes.set(nodeData.id, nodeData);
                this.renderNode(nodeData);
            });

            if (this.options.workflowData.connections) {
                this.options.workflowData.connections.forEach(connectionData => {
                    this.connections.set(connectionData.id, connectionData);
                    this.renderConnection(connectionData);
                });
            }
        }
    }

    switchTab(tabName) {
        // Update tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tabName);
        });

        // Update tab content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.toggle('active', content.id === `${tabName}-tab`);
        });
    }

    filterNodes(searchTerm) {
        const term = searchTerm.toLowerCase();
        
        document.querySelectorAll('.palette-node').forEach(node => {
            const name = node.querySelector('.node-name').textContent.toLowerCase();
            const matches = name.includes(term);
            node.style.display = matches ? 'flex' : 'none';
        });
    }

    zoomIn() {
        this.canvas.scale = Math.min(this.canvas.scale * 1.2, 3);
        this.updateCanvasTransform();
    }

    zoomOut() {
        this.canvas.scale = Math.max(this.canvas.scale / 1.2, 0.1);
        this.updateCanvasTransform();
    }

    fitToView() {
        // Implementation for fitting workflow to view
        this.canvas.scale = 1;
        this.canvas.offsetX = 0;
        this.canvas.offsetY = 0;
        this.updateCanvasTransform();
    }

    updateCanvasTransform() {
        const transform = `scale(${this.canvas.scale}) translate(${this.canvas.offsetX}px, ${this.canvas.offsetY}px)`;
        if (this.nodesLayer) {
            this.nodesLayer.style.transform = transform;
        }
        if (this.connectionsLayer) {
            this.connectionsLayer.style.transform = transform;
        }

        // Update zoom display
        const zoomDisplay = document.getElementById('zoom-level');
        if (zoomDisplay) {
            zoomDisplay.textContent = `${Math.round(this.canvas.scale * 100)}%`;
        }
    }

    markDirty() {
        this.isDirty = true;
        // Visual indication of unsaved changes
        const saveBtn = document.getElementById('save-btn');
        if (saveBtn) {
            saveBtn.classList.add('btn-warning');
            saveBtn.innerHTML = '<i class="fas fa-save"></i> Save*';
        }
    }

    generateId() {
        return 'node_' + Math.random().toString(36).substr(2, 9);
    }

    getCsrfToken() {
        return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
    }

    showLoading(message = 'Loading...') {
        const overlay = document.getElementById('loading-overlay');
        if (overlay) {
            const spinner = overlay.querySelector('.loading-spinner p');
            if (spinner) spinner.textContent = message;
            overlay.style.display = 'flex';
        }
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
            z-index: 10000;
            animation: slideIn 0.3s ease;
        `;

        const colors = {
            success: '#10b981',
            error: '#ef4444',
            warning: '#f59e0b',
            info: '#3b82f6'
        };

        notification.style.backgroundColor = colors[type] || colors.info;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
}

// Initialize editor when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    if (typeof workflowData !== 'undefined' && typeof workflowId !== 'undefined') {
        window.workflowEditor = new WorkflowEditor({
            workflowId: workflowId,
            workflowData: workflowData,
            csrfToken: document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
        });
    }
});

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
`;
document.head.appendChild(style);