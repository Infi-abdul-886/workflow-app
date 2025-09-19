/**
 * Complete Workflow Editor - Main editor functionality
 */
class WorkflowEditor {
    constructor(options = {}) {
        this.options = {
            workflowId: null,
            workflowData: { nodes: [], connections: [] },
            csrfToken: null,
            apiBaseUrl: "api/workflows/",
            autoSave: true,
            ...options,
        }

        // Editor state
        this.nodes = new Map()
        this.connections = new Map()
        this.selectedNode = null
        this.selectedConnection = null
        this.nodeTypes = new Map()
        this.isDirty = false
        this.isLoading = false
        this.draggedNode = null
        this.connectionStart = null
        this.isConnecting = false

        // Canvas state
        this.canvasOffset = { x: 0, y: 0 }
        this.zoom = 1
        this.isPanning = false
        this.lastPanPoint = { x: 0, y: 0 }

        this.init()
    }

    init() {
        this.setupCanvas()
        this.setupEventListeners()
        this.loadNodeTypes()
        this.loadWorkflow()
        this.setupAutoSave()
    }

    setupCanvas() {
        const canvas = document.getElementById('workflow-canvas')
        if (!canvas) return

        canvas.innerHTML = `
            <svg class="connections-svg" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1;">
                <defs>
                    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                        <polygon points="0 0, 10 3.5, 0 7" fill="#3b82f6" />
                    </marker>
                </defs>
            </svg>
            <div class="nodes-container" style="position: relative; z-index: 2; width: 100%; height: 100%;"></div>
        `

        this.connectionsLayer = canvas.querySelector('.connections-svg')
        this.nodesContainer = canvas.querySelector('.nodes-container')
    }

    setupEventListeners() {
        // Canvas events
        const canvas = document.getElementById('workflow-canvas')
        canvas.addEventListener('drop', this.onCanvasDrop.bind(this))
        canvas.addEventListener('dragover', this.onCanvasDragOver.bind(this))
        canvas.addEventListener('mousedown', this.onCanvasMouseDown.bind(this))
        canvas.addEventListener('mousemove', this.onCanvasMouseMove.bind(this))
        canvas.addEventListener('mouseup', this.onCanvasMouseUp.bind(this))
        canvas.addEventListener('wheel', this.onCanvasWheel.bind(this))

        // Toolbar events
        document.getElementById('save-btn')?.addEventListener('click', () => this.saveWorkflow())
        document.getElementById('test-btn')?.addEventListener('click', () => this.testWorkflow())
        document.getElementById('zoom-in')?.addEventListener('click', () => this.zoomIn())
        document.getElementById('zoom-out')?.addEventListener('click', () => this.zoomOut())
        document.getElementById('zoom-fit')?.addEventListener('click', () => this.fitToView())
        document.getElementById('center-canvas')?.addEventListener('click', () => this.centerCanvas())
        document.getElementById('clear-canvas')?.addEventListener('click', () => this.clearCanvas())

        // Node palette events
        this.setupNodePalette()

        // Tab events
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab)
            })
        })

        // Keyboard shortcuts
        document.addEventListener('keydown', this.onKeyDown.bind(this))
    }

    setupNodePalette() {
        const paletteContent = document.querySelector('.palette-content')
        if (!paletteContent) return

        // Setup search
        const searchInput = document.getElementById('node-search')
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.filterNodes(e.target.value)
            })
        }

        // Setup category toggles
        document.querySelectorAll('.category-header').forEach(header => {
            header.addEventListener('click', () => {
                const category = header.closest('.node-category')
                category.classList.toggle('collapsed')
            })
        })
    }

    async loadNodeTypes() {
        try {
            const response = await fetch('/workflow/api/node-types/')
            if (response.ok) {
                const nodeTypes = await response.json()
                nodeTypes.forEach(nodeType => {
                    this.nodeTypes.set(nodeType.name, nodeType)
                })
                this.renderNodePalette()
            } else {
                this.loadDefaultNodeTypes()
            }
        } catch (error) {
            console.warn('Failed to load node types, using defaults:', error)
            this.loadDefaultNodeTypes()
        }
    }

    loadDefaultNodeTypes() {
        const defaultTypes = [
            {
                name: 'manual_trigger',
                display_name: 'Manual Trigger',
                category: 'trigger',
                icon: 'fa-hand-pointer',
                color: '#10b981',
                config_schema: { fields: [] }
            },
            {
                name: 'webhook_trigger',
                display_name: 'Webhook',
                category: 'trigger',
                icon: 'fa-globe',
                color: '#3b82f6',
                config_schema: {
                    fields: [
                        { name: 'path', type: 'text', label: 'Endpoint Path', placeholder: '/webhook/my-endpoint' },
                        { name: 'method', type: 'select', label: 'HTTP Method', options: ['GET', 'POST', 'PUT', 'DELETE'], default: 'POST' }
                    ]
                }
            },
            {
                name: 'http_request',
                display_name: 'HTTP Request',
                category: 'data',
                icon: 'fa-exchange-alt',
                color: '#8b5cf6',
                config_schema: {
                    fields: [
                        { name: 'url', type: 'text', label: 'URL', placeholder: 'https://api.example.com/data', required: true },
                        { name: 'method', type: 'select', label: 'Method', options: ['GET', 'POST', 'PUT', 'DELETE'], default: 'GET' },
                        { name: 'headers', type: 'textarea', label: 'Headers (JSON)', placeholder: '{"Content-Type": "application/json"}' },
                        { name: 'body', type: 'textarea', label: 'Body', placeholder: 'Request body' }
                    ]
                }
            },
            {
                name: 'database_query',
                display_name: 'Database Query',
                category: 'data',
                icon: 'fa-database',
                color: '#059669',
                config_schema: {
                    fields: [
                        { name: 'query_type', type: 'select', label: 'Query Type', options: ['SELECT', 'INSERT', 'UPDATE', 'DELETE'], default: 'SELECT' },
                        { name: 'table_name', type: 'text', label: 'Table Name', placeholder: 'users', required: true },
                        { name: 'conditions', type: 'text', label: 'WHERE Conditions', placeholder: 'active = true' },
                        { name: 'fields', type: 'text', label: 'Fields', placeholder: '*', default: '*' },
                        { name: 'limit', type: 'number', label: 'Limit', default: 100 }
                    ]
                }
            },
            {
                name: 'condition',
                display_name: 'Condition',
                category: 'condition',
                icon: 'fa-code-branch',
                color: '#ef4444',
                config_schema: {
                    fields: [
                        { name: 'field', type: 'text', label: 'Field Path', placeholder: 'data.status', required: true },
                        { name: 'operator', type: 'select', label: 'Operator', options: ['equals', 'not_equals', 'greater_than', 'less_than', 'contains'], default: 'equals' },
                        { name: 'value', type: 'text', label: 'Value', placeholder: 'expected value' }
                    ]
                }
            },
            {
                name: 'data_transform',
                display_name: 'Transform Data',
                category: 'transform',
                icon: 'fa-cogs',
                color: '#f59e0b',
                config_schema: {
                    fields: [
                        { name: 'transform_type', type: 'select', label: 'Transform Type', options: ['map', 'filter', 'aggregate'], default: 'map' },
                        { name: 'field_mappings', type: 'textarea', label: 'Field Mappings (JSON)', placeholder: '[{"source": "old_field", "target": "new_field"}]' }
                    ]
                }
            },
            {
                name: 'email_send',
                display_name: 'Send Email',
                category: 'action',
                icon: 'fa-envelope',
                color: '#06b6d4',
                config_schema: {
                    fields: [
                        { name: 'to', type: 'text', label: 'To', placeholder: 'user@example.com', required: true },
                        { name: 'subject', type: 'text', label: 'Subject', placeholder: 'Email Subject', required: true },
                        { name: 'body', type: 'textarea', label: 'Body', placeholder: 'Email body...', required: true }
                    ]
                }
            },
            {
                name: 'json_parser',
                display_name: 'JSON Parser',
                category: 'transform',
                icon: 'fa-code',
                color: '#dc2626',
                config_schema: {
                    fields: [
                        { name: 'operation', type: 'select', label: 'Operation', options: ['parse', 'stringify', 'extract'], default: 'parse' },
                        { name: 'json_field', type: 'text', label: 'JSON Field', placeholder: 'data', default: 'data' }
                    ]
                }
            },
            {
                name: 'delay',
                display_name: 'Delay',
                category: 'action',
                icon: 'fa-clock',
                color: '#f59e0b',
                config_schema: {
                    fields: [
                        { name: 'delay_seconds', type: 'number', label: 'Delay (seconds)', default: 1, required: true }
                    ]
                }
            },
            {
                name: 'webhook_send',
                display_name: 'Send Webhook',
                category: 'action',
                icon: 'fa-paper-plane',
                color: '#7c3aed',
                config_schema: {
                    fields: [
                        { name: 'url', type: 'text', label: 'URL', placeholder: 'https://api.example.com/webhook', required: true },
                        { name: 'method', type: 'select', label: 'Method', options: ['POST', 'PUT', 'PATCH'], default: 'POST' },
                        { name: 'payload', type: 'textarea', label: 'Payload (JSON)', placeholder: 'JSON payload' }
                    ]
                }
            },
            {
                name: 'response',
                display_name: 'HTTP Response',
                category: 'output',
                icon: 'fa-reply',
                color: '#0891b2',
                config_schema: {
                    fields: [
                        { name: 'status_code', type: 'number', label: 'Status Code', default: 200 },
                        { name: 'response_data', type: 'textarea', label: 'Response Data (JSON)', placeholder: 'JSON response' }
                    ]
                }
            }
        ]

        defaultTypes.forEach(nodeType => {
            this.nodeTypes.set(nodeType.name, nodeType)
        })
        this.renderNodePalette()
    }

    renderNodePalette() {
        const categories = this.groupNodesByCategory()
        
        Object.entries(categories).forEach(([category, nodes]) => {
            const categoryElement = document.querySelector(`[data-category="${category}"] .category-nodes`)
            if (!categoryElement) return

            categoryElement.innerHTML = ''
            nodes.forEach(nodeType => {
                const nodeElement = this.createPaletteNode(nodeType)
                categoryElement.appendChild(nodeElement)
            })
        })
    }

    groupNodesByCategory() {
        const categories = {}
        this.nodeTypes.forEach(nodeType => {
            const category = nodeType.category || 'other'
            if (!categories[category]) {
                categories[category] = []
            }
            categories[category].push(nodeType)
        })
        return categories
    }

    createPaletteNode(nodeType) {
        const nodeDiv = document.createElement('div')
        nodeDiv.className = 'palette-node'
        nodeDiv.draggable = true
        nodeDiv.dataset.nodeType = nodeType.name
        nodeDiv.title = nodeType.description || nodeType.display_name

        nodeDiv.innerHTML = `
            <div class="node-icon" style="background-color: ${nodeType.color}">
                <i class="fas ${nodeType.icon}"></i>
            </div>
            <span class="node-name">${nodeType.display_name}</span>
        `

        nodeDiv.addEventListener('dragstart', (e) => {
            this.draggedNode = nodeType
            e.dataTransfer.effectAllowed = 'copy'
        })

        return nodeDiv
    }

    onCanvasDragOver(e) {
        e.preventDefault()
        e.dataTransfer.dropEffect = 'copy'
    }

    onCanvasDrop(e) {
        e.preventDefault()
        if (!this.draggedNode) return

        const rect = e.currentTarget.getBoundingClientRect()
        const x = (e.clientX - rect.left - this.canvasOffset.x) / this.zoom
        const y = (e.clientY - rect.top - this.canvasOffset.y) / this.zoom

        this.addNode(this.draggedNode, { x, y })
        this.draggedNode = null
    }

    addNode(nodeType, position) {
        const nodeId = this.generateId()
        const node = {
            id: nodeId,
            type: nodeType.name,
            name: nodeType.display_name,
            position: position,
            config: this.getDefaultConfig(nodeType),
            data: {}
        }

        this.nodes.set(nodeId, node)
        this.renderNode(node)
        this.markDirty()
        return nodeId
    }

    renderNode(node) {
        const nodeType = this.nodeTypes.get(node.type)
        if (!nodeType) return

        let nodeElement = document.querySelector(`[data-node-id="${node.id}"]`)
        
        if (!nodeElement) {
            nodeElement = document.createElement('div')
            nodeElement.className = 'workflow-node'
            nodeElement.dataset.nodeId = node.id
            nodeElement.style.position = 'absolute'
            this.nodesContainer.appendChild(nodeElement)
        }

        nodeElement.style.left = `${node.position.x}px`
        nodeElement.style.top = `${node.position.y}px`
        nodeElement.className = `workflow-node ${this.selectedNode?.id === node.id ? 'selected' : ''}`

        nodeElement.innerHTML = `
            <div class="node-header" style="background-color: ${nodeType.color}">
                <div class="node-icon">
                    <i class="fas ${nodeType.icon}"></i>
                </div>
                <div class="node-title">${node.name}</div>
                <div class="node-status ${node.status || ''}"></div>
            </div>
            <div class="node-body">
                <div class="node-description">${this.getNodeDescription(node)}</div>
            </div>
            ${nodeType.category !== 'trigger' ? '<div class="node-handle input" data-type="input"></div>' : ''}
            <div class="node-handle output" data-type="output"></div>
        `

        // Add event listeners
        nodeElement.addEventListener('click', (e) => {
            e.stopPropagation()
            this.selectNode(node.id)
        })

        nodeElement.addEventListener('mousedown', (e) => {
            if (e.target.classList.contains('node-handle')) return
            this.startNodeDrag(e, node.id)
        })

        // Handle connection events
        nodeElement.querySelectorAll('.node-handle').forEach(handle => {
            handle.addEventListener('mousedown', (e) => {
                e.stopPropagation()
                this.startConnection(e, node.id, handle.dataset.type)
            })
        })
    }

    getNodeDescription(node) {
        const config = node.config || {}
        const keys = Object.keys(config)
        
        if (keys.length === 0) {
            return 'Click to configure'
        }

        const firstKey = keys[0]
        const value = config[firstKey]
        if (value) {
            return `${firstKey}: ${String(value).substring(0, 30)}${String(value).length > 30 ? '...' : ''}`
        }
        
        return 'Configured'
    }

    selectNode(nodeId) {
        this.selectedNode = this.nodes.get(nodeId)
        this.selectedConnection = null
        
        // Update visual selection
        document.querySelectorAll('.workflow-node').forEach(el => {
            el.classList.remove('selected')
        })
        document.querySelector(`[data-node-id="${nodeId}"]`)?.classList.add('selected')

        // Show properties panel
        this.showNodeProperties(this.selectedNode)
    }

    showNodeProperties(node) {
        const nodeType = this.nodeTypes.get(node.type)
        if (!nodeType) return

        document.getElementById('no-selection').style.display = 'none'
        document.getElementById('connection-properties').style.display = 'none'
        
        const propertiesPanel = document.getElementById('node-properties')
        propertiesPanel.style.display = 'block'
        
        document.getElementById('panel-title').textContent = node.name

        let html = `
            <div class="form-section">
                <h4>General</h4>
                <div class="form-group">
                    <label for="node-name">Node Name</label>
                    <input type="text" id="node-name" value="${node.name}" class="form-control">
                </div>
            </div>
        `

        if (nodeType.config_schema && nodeType.config_schema.fields) {
            html += '<div class="form-section"><h4>Configuration</h4>'
            
            nodeType.config_schema.fields.forEach(field => {
                const value = node.config[field.name] || field.default || ''
                html += this.generateFormField(field, value)
            })
            
            html += '</div>'
        }

        // Add data preview section
        html += `
            <div class="form-section">
                <h4>Data Preview</h4>
                <div class="data-preview">
                    <pre id="node-data-preview">${JSON.stringify(node.data || {}, null, 2)}</pre>
                </div>
            </div>
        `

        propertiesPanel.innerHTML = html

        // Add event listeners
        propertiesPanel.querySelectorAll('input, select, textarea').forEach(input => {
            input.addEventListener('change', (e) => {
                this.updateNodeProperty(node.id, e.target.name || e.target.id.replace('node-', ''), e.target.value)
            })
        })
    }

    generateFormField(field, value) {
        const fieldId = `field-${field.name}`
        let html = `<div class="form-group">`
        html += `<label for="${fieldId}">${field.label}</label>`

        switch (field.type) {
            case 'text':
                html += `<input type="text" id="${fieldId}" name="${field.name}" value="${value}" placeholder="${field.placeholder || ''}" class="form-control" ${field.required ? 'required' : ''}>`
                break
            case 'number':
                html += `<input type="number" id="${fieldId}" name="${field.name}" value="${value}" placeholder="${field.placeholder || ''}" class="form-control" ${field.required ? 'required' : ''}>`
                break
            case 'textarea':
                html += `<textarea id="${fieldId}" name="${field.name}" placeholder="${field.placeholder || ''}" class="form-control" rows="3" ${field.required ? 'required' : ''}>${value}</textarea>`
                break
            case 'select':
                html += `<select id="${fieldId}" name="${field.name}" class="form-control" ${field.required ? 'required' : ''}>`
                if (!field.required) {
                    html += '<option value="">-- Select --</option>'
                }
                field.options.forEach(option => {
                    const selected = value === option ? 'selected' : ''
                    html += `<option value="${option}" ${selected}>${option}</option>`
                })
                html += '</select>'
                break
            case 'checkbox':
                const checked = value === true || value === 'true' ? 'checked' : ''
                html += `<label class="checkbox-label"><input type="checkbox" id="${fieldId}" name="${field.name}" ${checked}> ${field.label}</label>`
                break
        }

        html += '</div>'
        return html
    }

    updateNodeProperty(nodeId, property, value) {
        const node = this.nodes.get(nodeId)
        if (!node) return

        if (property === 'name') {
            node.name = value
        } else if (property === 'description') {
            node.description = value
        } else if (property === 'continue_on_error') {
            node.continue_on_error = value
        } else if (property === 'timeout') {
            node.timeout = value
        } else {
            if (!node.config) node.config = {}
            node.config[property] = value
        }

        this.renderNode(node)
        this.markDirty()
    }

    startConnection(e, nodeId, handleType) {
        e.preventDefault()
        e.stopPropagation()
        
        if (handleType === 'output') {
            this.isConnecting = true
            this.connectionStart = { nodeId, handleType }
            
            // Add visual feedback
            const sourceNode = document.querySelector(`[data-node-id="${nodeId}"]`)
            const sourceHandle = sourceNode.querySelector('.node-handle.output')
            sourceHandle.classList.add('connecting')
            
            // Set up mouse move listener for temporary connection
            const canvas = document.getElementById('workflow-canvas')
            const canvasRect = canvas.getBoundingClientRect()
            
            const updateTempConnection = (e) => {
                this.updateTempConnection(e, canvasRect)
            }
            
            const finishConnection = (e) => {
                document.removeEventListener('mousemove', updateTempConnection)
                document.removeEventListener('mouseup', finishConnection)
                sourceHandle.classList.remove('connecting')
                this.finishConnection(e)
            }
            
            document.addEventListener('mousemove', updateTempConnection)
            document.addEventListener('mouseup', finishConnection)
            
        } else if (handleType === 'input' && this.connectionStart) {
            // Complete connection
            this.completeConnection(nodeId)
        }
    }
    
    updateTempConnection(e, canvasRect) {
        if (!this.connectionStart) return
        
        let tempLine = this.connectionsLayer.querySelector('.temp-connection')
        if (!tempLine) {
            tempLine = document.createElementNS('http://www.w3.org/2000/svg', 'path')
            tempLine.setAttribute('class', 'temp-connection')
            tempLine.setAttribute('stroke', '#6b7280')
            tempLine.setAttribute('stroke-width', '2')
            tempLine.setAttribute('stroke-dasharray', '5,5')
            tempLine.setAttribute('fill', 'none')
            this.connectionsLayer.appendChild(tempLine)
        }
        
        const sourceNode = document.querySelector(`[data-node-id="${this.connectionStart.nodeId}"]`)
        const sourceHandle = sourceNode.querySelector('.node-handle.output')
        const sourceRect = sourceHandle.getBoundingClientRect()
        
        const startX = sourceRect.left + sourceRect.width / 2 - canvasRect.left
        const startY = sourceRect.top + sourceRect.height / 2 - canvasRect.top
        const endX = e.clientX - canvasRect.left
        const endY = e.clientY - canvasRect.top
        
        const dx = endX - startX
        const controlOffset = Math.max(50, Math.abs(dx) * 0.5)
        
        const path = `M ${startX} ${startY} C ${startX + controlOffset} ${startY}, ${endX - controlOffset} ${endY}, ${endX} ${endY}`
        tempLine.setAttribute('d', path)
    }
    
    finishConnection(e) {
        // Remove temporary connection
        const tempLine = this.connectionsLayer.querySelector('.temp-connection')
        if (tempLine) {
            tempLine.remove()
        }
        
        // Check if we're over an input handle
        const target = document.elementFromPoint(e.clientX, e.clientY)
        if (target && target.classList.contains('node-handle') && target.classList.contains('input')) {
            const targetNode = target.closest('.workflow-node')
            const targetNodeId = targetNode.getAttribute('data-node-id')
            
            if (this.connectionStart && targetNodeId !== this.connectionStart.nodeId) {
                this.completeConnection(targetNodeId)
            }
        }
        
        this.isConnecting = false
        this.connectionStart = null
    }

    createTempConnection(e) {
        const tempLine = document.createElementNS('http://www.w3.org/2000/svg', 'line')
        tempLine.setAttribute('class', 'temp-connection')
        tempLine.setAttribute('stroke', '#6b7280')
        tempLine.setAttribute('stroke-width', '2')
        tempLine.setAttribute('stroke-dasharray', '5,5')
        
        const startNode = document.querySelector(`[data-node-id="${this.connectionStart.nodeId}"]`)
        const startHandle = startNode.querySelector('.node-handle.output')
        const startRect = startHandle.getBoundingClientRect()
        const canvasRect = document.getElementById('workflow-canvas').getBoundingClientRect()
        
        const startX = startRect.left + startRect.width / 2 - canvasRect.left
        const startY = startRect.top + startRect.height / 2 - canvasRect.top
        
        tempLine.setAttribute('x1', startX)
        tempLine.setAttribute('y1', startY)
        tempLine.setAttribute('x2', e.clientX - canvasRect.left)
        tempLine.setAttribute('y2', e.clientY - canvasRect.top)
        
        this.connectionsLayer.appendChild(tempLine)
        
        // Update temp connection on mouse move
        const updateTempConnection = (e) => {
            tempLine.setAttribute('x2', e.clientX - canvasRect.left)
            tempLine.setAttribute('y2', e.clientY - canvasRect.top)
        }
        
        document.addEventListener('mousemove', updateTempConnection)
        
        // Clean up on mouse up
        const cleanup = () => {
            document.removeEventListener('mousemove', updateTempConnection)
            document.removeEventListener('mouseup', cleanup)
            tempLine.remove()
            this.isConnecting = false
            this.connectionStart = null
        }
        
        document.addEventListener('mouseup', cleanup)
    }

    completeConnection(targetNodeId) {
        if (!this.connectionStart || this.connectionStart.nodeId === targetNodeId) return

        const connectionId = this.generateId()
        const connection = {
            id: connectionId,
            source: this.connectionStart.nodeId,
            target: targetNodeId,
            sourceHandle: 'output',
            targetHandle: 'input'
        }

        this.connections.set(connectionId, connection)
        this.renderConnection(connection)
        this.markDirty()
    }

    renderConnection(connection) {
        const sourceNode = document.querySelector(`[data-node-id="${connection.source}"]`)
        const targetNode = document.querySelector(`[data-node-id="${connection.target}"]`)
        
        if (!sourceNode || !targetNode) return

        const sourceHandle = sourceNode.querySelector('.node-handle.output')
        const targetHandle = targetNode.querySelector('.node-handle.input')
        
        if (!sourceHandle || !targetHandle) return
        
        const sourceRect = sourceHandle.getBoundingClientRect()
        const targetRect = targetHandle.getBoundingClientRect()
        const canvasRect = document.getElementById('workflow-canvas').getBoundingClientRect()
        
        const startX = sourceRect.left + sourceRect.width / 2 - canvasRect.left
        const startY = sourceRect.top + sourceRect.height / 2 - canvasRect.top
        const endX = targetRect.left + targetRect.width / 2 - canvasRect.left
        const endY = targetRect.top + targetRect.height / 2 - canvasRect.top
        
        let connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connection.id}"]`)
        
        if (!connectionElement) {
            connectionElement = document.createElementNS('http://www.w3.org/2000/svg', 'path')
            connectionElement.setAttribute('data-connection-id', connection.id)
            connectionElement.setAttribute('class', 'connection-line')
            connectionElement.setAttribute('stroke', '#3b82f6')
            connectionElement.setAttribute('stroke-width', '2')
            connectionElement.setAttribute('fill', 'none')
            connectionElement.setAttribute('marker-end', 'url(#arrowhead)')
            connectionElement.style.pointerEvents = 'stroke'
            connectionElement.style.cursor = 'pointer'
            this.connectionsLayer.appendChild(connectionElement)
            
            connectionElement.addEventListener('click', (e) => {
                e.stopPropagation()
                this.selectConnection(connection.id)
            })
        }

        // Create curved path
        const dx = endX - startX
        const dy = endY - startY
        const controlOffset = Math.max(50, Math.abs(dx) * 0.5)
        
        const path = `M ${startX} ${startY} C ${startX + controlOffset} ${startY}, ${endX - controlOffset} ${endY}, ${endX} ${endY}`
        connectionElement.setAttribute('d', path)
    }

    selectConnection(connectionId) {
        this.selectedConnection = this.connections.get(connectionId)
        this.selectedNode = null
        
        // Update visual selection
        document.querySelectorAll('.workflow-node').forEach(el => {
            el.classList.remove('selected')
        })
        document.querySelectorAll('.connection-line').forEach(el => {
            el.classList.remove('selected')
        })
        document.querySelector(`[data-connection-id="${connectionId}"]`)?.classList.add('selected')

        this.showConnectionProperties(this.selectedConnection)
    }

    showConnectionProperties(connection) {
        document.getElementById('no-selection').style.display = 'none'
        document.getElementById('node-properties').style.display = 'none'
        
        const propertiesPanel = document.getElementById('connection-properties')
        propertiesPanel.style.display = 'block'
        
        document.getElementById('panel-title').textContent = 'Connection Properties'

        propertiesPanel.innerHTML = `
            <div class="form-section">
                <h4>Connection Details</h4>
                <div class="form-group">
                    <label>Source Node</label>
                    <input type="text" value="${this.nodes.get(connection.source)?.name || connection.source}" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>Target Node</label>
                    <input type="text" value="${this.nodes.get(connection.target)?.name || connection.target}" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <button class="btn btn-danger" onclick="workflowEditor.deleteConnection('${connection.id}')">
                        <i class="fas fa-trash"></i> Delete Connection
                    </button>
                </div>
            </div>
        `
    }

    deleteConnection(connectionId) {
        this.connections.delete(connectionId)
        const connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connectionId}"]`)
        if (connectionElement) {
            connectionElement.remove()
        }
        this.hideProperties()
        this.markDirty()
    }

    hideProperties() {
        document.getElementById('no-selection').style.display = 'flex'
        document.getElementById('node-properties').style.display = 'none'
        document.getElementById('connection-properties').style.display = 'none'
        document.getElementById('panel-title').textContent = 'Properties'
        
        this.selectedNode = null
        this.selectedConnection = null
        
        document.querySelectorAll('.workflow-node').forEach(el => {
            el.classList.remove('selected')
        })
        document.querySelectorAll('.connection-line').forEach(el => {
            el.classList.remove('selected')
        })
    }

    onCanvasMouseDown(e) {
        if (e.target.id === 'workflow-canvas' || e.target.classList.contains('nodes-container')) {
            this.hideProperties()
            this.startPanning(e)
        }
    }

    startPanning(e) {
        this.isPanning = true
        this.lastPanPoint = { x: e.clientX, y: e.clientY }
        document.getElementById('workflow-canvas').style.cursor = 'grabbing'
    }

    onCanvasMouseMove(e) {
        if (this.isPanning) {
            const dx = e.clientX - this.lastPanPoint.x
            const dy = e.clientY - this.lastPanPoint.y
            
            this.canvasOffset.x += dx
            this.canvasOffset.y += dy
            
            this.updateCanvasTransform()
            this.lastPanPoint = { x: e.clientX, y: e.clientY }
        }
    }

    onCanvasMouseUp(e) {
        if (this.isPanning) {
            this.isPanning = false
            document.getElementById('workflow-canvas').style.cursor = 'grab'
        }
    }

    startNodeDrag(e, nodeId) {
        e.preventDefault()
        const node = this.nodes.get(nodeId)
        if (!node) return

        const startX = e.clientX
        const startY = e.clientY
        const startPos = { ...node.position }

        const onMouseMove = (e) => {
            const dx = (e.clientX - startX) / this.zoom
            const dy = (e.clientY - startY) / this.zoom
            
            node.position.x = startPos.x + dx
            node.position.y = startPos.y + dy
            
            this.renderNode(node)
            this.renderAllConnections()
        }

        const onMouseUp = () => {
            document.removeEventListener('mousemove', onMouseMove)
            document.removeEventListener('mouseup', onMouseUp)
            this.markDirty()
        }

        document.addEventListener('mousemove', onMouseMove)
        document.addEventListener('mouseup', onMouseUp)
    }

    renderAllConnections() {
        this.connections.forEach(connection => {
            this.renderConnection(connection)
        })
    }

    onCanvasWheel(e) {
        e.preventDefault()
        
        const rect = e.currentTarget.getBoundingClientRect()
        const mouseX = e.clientX - rect.left
        const mouseY = e.clientY - rect.top
        
        const scaleFactor = e.deltaY > 0 ? 0.9 : 1.1
        const newZoom = Math.max(0.1, Math.min(3, this.zoom * scaleFactor))
        
        // Zoom towards mouse position
        const zoomChange = newZoom / this.zoom
        this.canvasOffset.x = mouseX - (mouseX - this.canvasOffset.x) * zoomChange
        this.canvasOffset.y = mouseY - (mouseY - this.canvasOffset.y) * zoomChange
        this.zoom = newZoom
        
        this.updateCanvasTransform()
        this.updateZoomDisplay()
    }

    updateCanvasTransform() {
        const transform = `translate(${this.canvasOffset.x}px, ${this.canvasOffset.y}px) scale(${this.zoom})`
        this.nodesContainer.style.transform = transform
        this.connectionsLayer.style.transform = transform
    }

    updateZoomDisplay() {
        const zoomDisplay = document.getElementById('zoom-level')
        if (zoomDisplay) {
            zoomDisplay.textContent = `${Math.round(this.zoom * 100)}%`
        }
    }

    zoomIn() {
        this.zoom = Math.min(this.zoom * 1.2, 3)
        this.updateCanvasTransform()
        this.updateZoomDisplay()
    }

    zoomOut() {
        this.zoom = Math.max(this.zoom / 1.2, 0.1)
        this.updateCanvasTransform()
        this.updateZoomDisplay()
    }

    fitToView() {
        if (this.nodes.size === 0) return

        let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity
        
        this.nodes.forEach(node => {
            minX = Math.min(minX, node.position.x)
            minY = Math.min(minY, node.position.y)
            maxX = Math.max(maxX, node.position.x + 200)
            maxY = Math.max(maxY, node.position.y + 100)
        })

        const workflowWidth = maxX - minX
        const workflowHeight = maxY - minY
        const canvas = document.getElementById('workflow-canvas')
        const canvasRect = canvas.getBoundingClientRect()
        
        const scaleX = (canvasRect.width - 100) / workflowWidth
        const scaleY = (canvasRect.height - 100) / workflowHeight
        
        this.zoom = Math.min(scaleX, scaleY, 1)
        
        const centerX = (minX + maxX) / 2
        const centerY = (minY + maxY) / 2
        
        this.canvasOffset.x = canvasRect.width / 2 - centerX * this.zoom
        this.canvasOffset.y = canvasRect.height / 2 - centerY * this.zoom
        
        this.updateCanvasTransform()
        this.updateZoomDisplay()
    }

    centerCanvas() {
        if (this.nodes.size === 0) return

        let centerX = 0, centerY = 0
        this.nodes.forEach(node => {
            centerX += node.position.x
            centerY += node.position.y
        })
        
        centerX /= this.nodes.size
        centerY /= this.nodes.size
        
        const canvas = document.getElementById('workflow-canvas')
        const canvasRect = canvas.getBoundingClientRect()
        
        this.canvasOffset.x = canvasRect.width / 2 - centerX * this.zoom
        this.canvasOffset.y = canvasRect.height / 2 - centerY * this.zoom
        
        this.updateCanvasTransform()
    }

    clearCanvas() {
        if (confirm('Are you sure you want to clear the entire canvas?')) {
            this.nodes.clear()
            this.connections.clear()
            this.nodesContainer.innerHTML = ''
            this.connectionsLayer.innerHTML = `
                <defs>
                    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                        <polygon points="0 0, 10 3.5, 0 7" fill="#3b82f6" />
                    </marker>
                </defs>
            `
            this.hideProperties()
            this.markDirty()
        }
    }

    onKeyDown(e) {
        if (e.key === 'Delete' && (this.selectedNode || this.selectedConnection)) {
            this.deleteSelected()
        } else if (e.key === 'Escape') {
            this.hideProperties()
        } else if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            e.preventDefault()
            this.saveWorkflow()
        }
    }

    deleteSelected() {
        if (this.selectedNode) {
            this.deleteNode(this.selectedNode.id)
        } else if (this.selectedConnection) {
            this.deleteConnection(this.selectedConnection.id)
        }
    }

    deleteNode(nodeId) {
        // Remove connections
        const connectionsToDelete = []
        this.connections.forEach((connection, id) => {
            if (connection.source === nodeId || connection.target === nodeId) {
                connectionsToDelete.push(id)
            }
        })
        
        connectionsToDelete.forEach(id => this.deleteConnection(id))
        
        // Remove node
        this.nodes.delete(nodeId)
        const nodeElement = document.querySelector(`[data-node-id="${nodeId}"]`)
        if (nodeElement) {
            nodeElement.remove()
        }
        
        this.hideProperties()
        this.markDirty()
    }

    async saveWorkflow() {
        if (this.isLoading) return

        try {
            this.isLoading = true
            this.showLoading('Saving workflow...')

            const workflowData = this.getWorkflowData()
            const url = this.options.workflowId 
                ? `${this.options.apiBaseUrl}${this.options.workflowId}/`
                : this.options.apiBaseUrl

            const method = this.options.workflowId ? 'PUT' : 'POST'

            const response = await fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': this.options.csrfToken,
                },
                body: JSON.stringify(workflowData),
            })

            if (response.ok) {
                const result = await response.json()
                
                if (!this.options.workflowId) {
                    this.options.workflowId = result.id
                    window.history.replaceState({}, '', `/workflow/${result.id}/edit/`)
                }

                this.markClean()
                this.showNotification('Workflow saved successfully', 'success')
            } else {
                const errorData = await response.json()
                throw new Error(errorData.error || 'Failed to save workflow')
            }
        } catch (error) {
            console.error('Save error:', error)
            this.showNotification(error.message || 'Failed to save workflow', 'error')
        } finally {
            this.isLoading = false
            this.hideLoading()
        }
    }

    async testWorkflow() {
        if (!this.options.workflowId) {
            // Save workflow first
            await this.saveWorkflow()
            if (!this.options.workflowId) {
                this.showNotification('Failed to save workflow before testing', 'error')
                return
            }
        }

        try {
            this.showLoading('Testing workflow...')

            // CSRF helper - read from meta token or csrftoken cookie
            function getCookie(name) {
                const value = `; ${document.cookie}`;
                const parts = value.split(`; ${name}=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
            }
            const meta = document.querySelector('meta[name="csrf-token"]');
            const csrfToken = meta && meta.getAttribute('content') ? meta.getAttribute('content') : (getCookie('csrftoken') || this.options.csrfToken);

            const response = await fetch(`/api/workflows/${this.options.workflowId}/test/`, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken || '',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({ 
                    input_data: {},
                    test_mode: true 
                }),
            })

            if (response.ok) {
                const result = await response.json()
                this.showNotification(`Workflow test ${result.success ? 'completed successfully' : 'failed'}`, result.success ? 'success' : 'error')
                this.switchTab('logs')
                
                // Update node statuses
                if (result.node_executions) {
                    this.updateNodeStatuses(result.node_executions)
                }
                
                // Display logs
                this.displayTestResults(result)
            } else {
                const errorData = await response.json()
                throw new Error(errorData.error || 'Failed to start workflow test')
            }
        } catch (error) {
            console.error('Test error:', error)
            this.showNotification(error.message || 'Failed to test workflow', 'error')
        } finally {
            this.hideLoading()
        }
    }
    
    displayTestResults(result) {
        const logsContainer = document.getElementById('execution-logs')
        if (!logsContainer) return

        let logsHtml = `
            <div class="test-results">
                <div class="test-summary">
                    <strong>Test Results:</strong> ${result.success ? 'SUCCESS' : 'FAILED'}
                    ${result.duration_seconds ? ` (${result.duration_seconds.toFixed(2)}s)` : ''}
                </div>
            </div>
        `

        if (result.node_executions && result.node_executions.length > 0) {
            result.node_executions.forEach(nodeExec => {
                const timestamp = new Date().toLocaleTimeString()
                const levelClass = nodeExec.status === 'failed' ? 'log-error' : 'log-info'
                const message = nodeExec.error_message || `Node executed successfully`

                logsHtml += `
                    <div class="log-entry ${levelClass}">
                        <span class="log-timestamp">[${timestamp}]</span>
                        <span class="log-level">${nodeExec.status.toUpperCase()}</span>
                        <span class="log-node">${nodeExec.node_name}:</span>
                        <span class="log-message">${message}</span>
                        ${nodeExec.duration_ms ? `<span class="log-duration">(${nodeExec.duration_ms}ms)</span>` : ''}
                    </div>
                `
            })
        }

        logsContainer.innerHTML = logsHtml
        logsContainer.scrollTop = logsContainer.scrollHeight
    }
    async pollExecutionStatus(executionId) {
        const maxPolls = 60
        let pollCount = 0

        const poll = async () => {
            try {
                const response = await fetch(`/workflow/api/executions/${executionId}/`)
                if (response.ok) {
                    const execution = await response.json()
                    
                    // Update node statuses
                    this.updateNodeStatuses(execution.node_executions || [])

                    if (execution.status === 'running' || execution.status === 'queued') {
                        if (pollCount < maxPolls) {
                            pollCount++
                            setTimeout(poll, 2000)
                        }
                    } else {
                        this.loadExecutionLogs(executionId)
                        this.showNotification(`Workflow ${execution.status}`, execution.status === 'success' ? 'success' : 'error')
                    }
                }
            } catch (error) {
                console.error('Polling error:', error)
            }
        }

        poll()
    }

    updateNodeStatuses(nodeExecutions) {
        // Reset all node statuses
        this.nodes.forEach(node => {
            node.status = ''
        })

        // Update based on execution results
        nodeExecutions.forEach(nodeExec => {
            const node = this.nodes.get(nodeExec.node_id)
            if (node) {
                node.status = nodeExec.status
                node.data = nodeExec.output_data || {}
                this.renderNode(node)
            }
        })

        // Update data preview if node is selected
        if (this.selectedNode) {
            const dataPreview = document.getElementById('node-data-preview')
            if (dataPreview) {
                dataPreview.textContent = JSON.stringify(this.selectedNode.data || {}, null, 2)
            }
        }
    }

    async loadExecutionLogs(executionId) {
        try {
            const response = await fetch(`/workflow/api/executions/${executionId}/logs/`)
            if (response.ok) {
                const data = await response.json()
                this.displayExecutionLogs(data.logs)
            }
        } catch (error) {
            console.error('Failed to load execution logs:', error)
        }
    }

    displayExecutionLogs(logs) {
        const logsContainer = document.getElementById('execution-logs')
        if (!logsContainer) return

        if (!logs || logs.length === 0) {
            logsContainer.innerHTML = '<div class="log-placeholder"><i class="fas fa-info-circle"></i><p>No logs available</p></div>'
            return
        }

        let logsHtml = ''
        logs.forEach(log => {
            const timestamp = new Date(log.timestamp).toLocaleTimeString()
            const levelClass = `log-${log.level.toLowerCase()}`

            logsHtml += `
                <div class="log-entry ${levelClass}">
                    <span class="log-timestamp">[${timestamp}]</span>
                    <span class="log-level">${log.level}</span>
                    <span class="log-node">${log.node_name}:</span>
                    <span class="log-message">${log.message}</span>
                    ${log.duration_ms ? `<span class="log-duration">(${log.duration_ms}ms)</span>` : ''}
                </div>
            `
        })

        logsContainer.innerHTML = logsHtml
        logsContainer.scrollTop = logsContainer.scrollHeight
    }

    getWorkflowData() {
        const nameInput = document.getElementById('workflow-name')
        
        const nodes = []
        const connections = []

        this.nodes.forEach(node => {
            nodes.push({
                id: node.id,
                type: node.type,
                name: node.name,
                position: node.position,
                config: node.config || {},
                continue_on_error: node.continue_on_error || false,
                timeout: node.timeout || 30
            })
        })

        this.connections.forEach(connection => {
            connections.push({
                source: connection.source,
                target: connection.target,
                source_output: connection.sourceHandle || 'main',
                target_input: connection.targetHandle || 'main'
            })
        })

        return {
            name: nameInput ? nameInput.value : 'Untitled Workflow',
            description: document.getElementById('workflow-description')?.value || '',
            status: 'draft',
            definition: { nodes, connections }
        }
    }

    loadWorkflow() {
        if (this.options.workflowData && this.options.workflowData.nodes) {
            this.options.workflowData.nodes.forEach(nodeData => {
                const node = {
                    id: nodeData.id,
                    type: nodeData.type,
                    name: nodeData.name,
                    position: nodeData.position || { x: 100, y: 100 },
                    config: nodeData.config || {},
                    data: {}
                }
                this.nodes.set(node.id, node)
                this.renderNode(node)
            })

            if (this.options.workflowData.connections) {
                this.options.workflowData.connections.forEach(connData => {
                    const connection = {
                        id: this.generateId(),
                        source: connData.source,
                        target: connData.target,
                        sourceHandle: connData.source_output || 'main',
                        targetHandle: connData.target_input || 'main'
                    }
                    this.connections.set(connection.id, connection)
                    this.renderConnection(connection)
                })
            }
        }
    }

    switchTab(tabName) {
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tabName)
        })

        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.toggle('active', content.id === `${tabName}-tab`)
        })
    }

    filterNodes(searchTerm) {
        const term = searchTerm.toLowerCase()
        
        document.querySelectorAll('.palette-node').forEach(node => {
            const name = node.querySelector('.node-name').textContent.toLowerCase()
            const matches = name.includes(term)
            node.style.display = matches ? 'flex' : 'none'
        })
    }

    getDefaultConfig(nodeType) {
        const config = {}
        if (nodeType.config_schema && nodeType.config_schema.fields) {
            nodeType.config_schema.fields.forEach(field => {
                if (field.default !== undefined) {
                    config[field.name] = field.default
                }
            })
        }
        return config
    }

    generateId() {
        return 'node_' + Math.random().toString(36).substr(2, 9)
    }

    markDirty() {
        this.isDirty = true
        this.updateSaveButton()
    }

    markClean() {
        this.isDirty = false
        this.updateSaveButton()
    }

    updateSaveButton() {
        const saveBtn = document.getElementById('save-btn')
        if (saveBtn) {
            saveBtn.classList.toggle('btn-warning', this.isDirty)
            saveBtn.innerHTML = this.isDirty 
                ? '<i class="fas fa-save"></i> Save*' 
                : '<i class="fas fa-save"></i> Save'
        }
    }

    setupAutoSave() {
        if (this.options.autoSave) {
            setInterval(() => {
                if (this.isDirty && !this.isLoading) {
                    this.saveWorkflow()
                }
            }, 30000)
        }
    }

    showLoading(message = 'Loading...') {
        const overlay = document.getElementById('loading-overlay')
        if (overlay) {
            const spinner = overlay.querySelector('.loading-spinner p')
            if (spinner) spinner.textContent = message
            overlay.style.display = 'flex'
        }
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay')
        if (overlay) {
            overlay.style.display = 'none'
        }
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div')
        notification.className = `notification notification-${type}`
        notification.innerHTML = `
            <i class="fas ${this.getNotificationIcon(type)}"></i>
            <span>${message}</span>
        `

        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
            z-index: 10000;
            display: flex;
            align-items: center;
            gap: 8px;
            animation: slideIn 0.3s ease;
        `

        const colors = {
            success: '#10b981',
            error: '#ef4444',
            warning: '#f59e0b',
            info: '#3b82f6',
        }

        notification.style.backgroundColor = colors[type] || colors.info
        document.body.appendChild(notification)

        setTimeout(() => {
            notification.remove()
        }, 3000)
    }

    getNotificationIcon(type) {
        const icons = {
            success: 'fa-check-circle',
            error: 'fa-times-circle',
            warning: 'fa-exclamation-triangle',
            info: 'fa-info-circle',
        }
        return icons[type] || icons.info
    }
}

// Global instance
window.WorkflowEditor = WorkflowEditor
