/**
 * Workflow Canvas - Handles the visual workflow editor
 */
class WorkflowCanvas {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId)
    this.options = {
      gridSize: 20,
      snapToGrid: true,
      ...options,
    }

    // Canvas state
    this.nodes = new Map()
    this.connections = new Map()
    this.selectedNodes = new Set()
    this.selectedConnections = new Set()
    this.clipboard = null

    // Interaction state
    this.isDragging = false
    this.isConnecting = false
    this.isPanning = false
    this.connectionStart = null
    this.dragOffset = { x: 0, y: 0 }
    this.lastMousePos = { x: 0, y: 0 }

    // Canvas transform
    this.transform = {
      x: 0,
      y: 0,
      scale: 1,
    }

    this.init()
  }

  init() {
    this.setupCanvas()
    this.setupEventListeners()
    this.render()
  }

  setupCanvas() {
    this.container.innerHTML = `
            <div class="canvas-wrapper">
                <svg class="connections-layer" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1;">
                    <defs>
                        <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                            <polygon points="0 0, 10 3.5, 0 7" fill="#666" />
                        </marker>
                    </defs>
                </svg>
                <div class="nodes-layer" style="position: relative; z-index: 2;"></div>
                <div class="canvas-grid" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0;"></div>
            </div>
        `

    this.connectionsLayer = this.container.querySelector(".connections-layer")
    this.nodesLayer = this.container.querySelector(".nodes-layer")
    this.gridLayer = this.container.querySelector(".canvas-grid")

    this.updateGrid()
  }

  setupEventListeners() {
    // Mouse events
    this.container.addEventListener("mousedown", this.onMouseDown.bind(this))
    this.container.addEventListener("mousemove", this.onMouseMove.bind(this))
    this.container.addEventListener("mouseup", this.onMouseUp.bind(this))
    this.container.addEventListener("wheel", this.onWheel.bind(this))

    // Keyboard events
    document.addEventListener("keydown", this.onKeyDown.bind(this))
    document.addEventListener("keyup", this.onKeyUp.bind(this))

    // Context menu
    this.container.addEventListener("contextmenu", this.onContextMenu.bind(this))

    // Drag and drop
    this.container.addEventListener("dragover", this.onDragOver.bind(this))
    this.container.addEventListener("drop", this.onDrop.bind(this))
  }

  // Node management
  addNode(nodeData, position) {
    const nodeId = nodeData.id || this.generateId()
    const node = {
      id: nodeId,
      type: nodeData.type,
      name: nodeData.name || nodeData.type,
      position: position || { x: 100, y: 100 },
      config: nodeData.config || {},
      inputs: nodeData.inputs || ["input"],
      outputs: nodeData.outputs || ["output"],
    }

    this.nodes.set(nodeId, node)
    this.renderNode(node)
    return nodeId
  }

  removeNode(nodeId) {
    // Remove connections
    const connectionsToRemove = []
    this.connections.forEach((connection, id) => {
      if (connection.source === nodeId || connection.target === nodeId) {
        connectionsToRemove.push(id)
      }
    })

    connectionsToRemove.forEach((id) => this.removeConnection(id))

    // Remove node
    this.nodes.delete(nodeId)
    const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"]`)
    if (nodeElement) {
      nodeElement.remove()
    }

    this.selectedNodes.delete(nodeId)
    this.emit("nodeRemoved", { nodeId })
  }

  updateNode(nodeId, updates) {
    const node = this.nodes.get(nodeId)
    if (!node) return

    Object.assign(node, updates)
    this.renderNode(node)
    this.emit("nodeUpdated", { nodeId, node })
  }

  renderNode(node) {
    let nodeElement = this.container.querySelector(`[data-node-id="${node.id}"]`)

    if (!nodeElement) {
      nodeElement = document.createElement("div")
      nodeElement.className = "workflow-node"
      nodeElement.setAttribute("data-node-id", node.id)
      nodeElement.setAttribute("data-node-type", node.type)
      this.nodesLayer.appendChild(nodeElement)
    }

    const isSelected = this.selectedNodes.has(node.id)
    nodeElement.className = `workflow-node ${isSelected ? "selected" : ""}`

    nodeElement.style.left = `${node.position.x}px`
    nodeElement.style.top = `${node.position.y}px`

    nodeElement.innerHTML = `
            <div class="node-header">
                <div class="node-icon">
                    <i class="fas ${this.getNodeIcon(node.type)}"></i>
                </div>
                <div class="node-title">${node.name}</div>
                <div class="node-status"></div>
            </div>
            <div class="node-body">
                ${this.getNodeDescription(node)}
            </div>
            <div class="node-handles">
                ${node.inputs
                  .map(
                    (input, index) => `
                    <div class="node-handle input" data-handle="${input}" data-index="${index}"></div>
                `,
                  )
                  .join("")}
                ${node.outputs
                  .map(
                    (output, index) => `
                    <div class="node-handle output" data-handle="${output}" data-index="${index}"></div>
                `,
                  )
                  .join("")}
            </div>
        `

    // Add event listeners
    nodeElement.addEventListener("mousedown", (e) => this.onNodeMouseDown(e, node.id))
    nodeElement.addEventListener("click", (e) => this.onNodeClick(e, node.id))

    // Handle events
    nodeElement.querySelectorAll(".node-handle").forEach((handle) => {
      handle.addEventListener("mousedown", (e) => this.onHandleMouseDown(e, node.id, handle))
    })
  }

  getNodeIcon(nodeType) {
    const icons = {
      trigger: "fa-play-circle",
      webhook: "fa-globe",
      http: "fa-exchange-alt",
      database: "fa-database",
      email: "fa-envelope",
      condition: "fa-code-branch",
      transform: "fa-cogs",
      delay: "fa-clock",
      log: "fa-file-text",
    }
    return icons[nodeType] || "fa-cube"
  }

  getNodeDescription(node) {
    if (node.config && Object.keys(node.config).length > 0) {
      const firstKey = Object.keys(node.config)[0]
      const value = node.config[firstKey]
      if (value) {
        return `${firstKey}: ${String(value).substring(0, 30)}${String(value).length > 30 ? "..." : ""}`
      }
    }
    return "Click to configure"
  }

  // Connection management
  addConnection(sourceNodeId, sourceHandle, targetNodeId, targetHandle) {
    const connectionId = this.generateId()
    const connection = {
      id: connectionId,
      source: sourceNodeId,
      sourceHandle: sourceHandle,
      target: targetNodeId,
      targetHandle: targetHandle,
    }

    this.connections.set(connectionId, connection)
    this.renderConnection(connection)
    this.emit("connectionAdded", { connectionId, connection })
    return connectionId
  }

  removeConnection(connectionId) {
    this.connections.delete(connectionId)
    const connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connectionId}"]`)
    if (connectionElement) {
      connectionElement.remove()
    }
    this.selectedConnections.delete(connectionId)
    this.emit("connectionRemoved", { connectionId })
  }

  renderConnection(connection) {
    const sourceNode = this.nodes.get(connection.source)
    const targetNode = this.nodes.get(connection.target)

    if (!sourceNode || !targetNode) return

    const sourcePos = this.getHandlePosition(sourceNode, connection.sourceHandle, "output")
    const targetPos = this.getHandlePosition(targetNode, connection.targetHandle, "input")

    let connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connection.id}"]`)

    if (!connectionElement) {
      connectionElement = document.createElementNS("http://www.w3.org/2000/svg", "path")
      connectionElement.setAttribute("data-connection-id", connection.id)
      connectionElement.setAttribute("class", "connection-path")
      connectionElement.setAttribute("marker-end", "url(#arrowhead)")
      this.connectionsLayer.appendChild(connectionElement)

      connectionElement.addEventListener("click", (e) => this.onConnectionClick(e, connection.id))
    }

    const isSelected = this.selectedConnections.has(connection.id)
    connectionElement.setAttribute("class", `connection-path ${isSelected ? "selected" : ""}`)

    // Create curved path
    const path = this.createConnectionPath(sourcePos, targetPos)
    connectionElement.setAttribute("d", path)
  }

  getHandlePosition(node, handleName, type) {
    const nodeElement = this.container.querySelector(`[data-node-id="${node.id}"]`)
    if (!nodeElement) return { x: 0, y: 0 }

    const nodeRect = nodeElement.getBoundingClientRect()
    const containerRect = this.container.getBoundingClientRect()

    const handles = nodeElement.querySelectorAll(`.node-handle.${type}[data-handle="${handleName}"]`)
    if (handles.length === 0) return { x: 0, y: 0 }

    const handleRect = handles[0].getBoundingClientRect()

    return {
      x: handleRect.left + handleRect.width / 2 - containerRect.left,
      y: handleRect.top + handleRect.height / 2 - containerRect.top,
    }
  }

  createConnectionPath(start, end) {
    const dx = end.x - start.x
    const dy = end.y - start.y
    const controlOffset = Math.max(50, Math.abs(dx) * 0.5)

    return `M ${start.x} ${start.y} C ${start.x + controlOffset} ${start.y}, ${end.x - controlOffset} ${end.y}, ${end.x} ${end.y}`
  }

  // Event handlers
  onMouseDown(e) {
    if (e.target === this.container || e.target.classList.contains("canvas-grid")) {
      this.clearSelection()
      this.isPanning = true
      this.lastMousePos = { x: e.clientX, y: e.clientY }
      this.container.style.cursor = "grabbing"
    }
  }

  onMouseMove(e) {
    if (this.isPanning) {
      const dx = e.clientX - this.lastMousePos.x
      const dy = e.clientY - this.lastMousePos.y

      this.transform.x += dx
      this.transform.y += dy

      this.updateTransform()
      this.lastMousePos = { x: e.clientX, y: e.clientY }
    }

    if (this.isDragging && this.selectedNodes.size > 0) {
      const dx = e.clientX - this.lastMousePos.x
      const dy = e.clientY - this.lastMousePos.y

      this.selectedNodes.forEach((nodeId) => {
        const node = this.nodes.get(nodeId)
        if (node) {
          node.position.x += dx / this.transform.scale
          node.position.y += dy / this.transform.scale

          if (this.options.snapToGrid) {
            node.position.x = Math.round(node.position.x / this.options.gridSize) * this.options.gridSize
            node.position.y = Math.round(node.position.y / this.options.gridSize) * this.options.gridSize
          }

          this.renderNode(node)
        }
      })

      this.renderConnections()
      this.lastMousePos = { x: e.clientX, y: e.clientY }
    }

    if (this.isConnecting && this.connectionStart) {
      this.updateTempConnection(e)
    }
  }

  onMouseUp(e) {
    if (this.isPanning) {
      this.isPanning = false
      this.container.style.cursor = "grab"
    }

    if (this.isDragging) {
      this.isDragging = false
      this.emit("nodesMoved", { nodeIds: Array.from(this.selectedNodes) })
    }

    if (this.isConnecting) {
      this.finishConnection(e)
    }
  }

  onWheel(e) {
    e.preventDefault()

    const rect = this.container.getBoundingClientRect()
    const mouseX = e.clientX - rect.left
    const mouseY = e.clientY - rect.top

    const scaleFactor = e.deltaY > 0 ? 0.9 : 1.1
    const newScale = Math.max(0.1, Math.min(3, this.transform.scale * scaleFactor))

    // Zoom towards mouse position
    const scaleChange = newScale / this.transform.scale
    this.transform.x = mouseX - (mouseX - this.transform.x) * scaleChange
    this.transform.y = mouseY - (mouseY - this.transform.y) * scaleChange
    this.transform.scale = newScale

    this.updateTransform()
    this.updateGrid()
  }

  onNodeMouseDown(e, nodeId) {
    e.stopPropagation()

    if (!this.selectedNodes.has(nodeId)) {
      if (!e.ctrlKey && !e.metaKey) {
        this.clearSelection()
      }
      this.selectNode(nodeId)
    }

    this.isDragging = true
    this.lastMousePos = { x: e.clientX, y: e.clientY }
  }

  onNodeClick(e, nodeId) {
    e.stopPropagation()
    this.emit("nodeSelected", { nodeId })
  }

  onHandleMouseDown(e, nodeId, handleElement) {
    e.stopPropagation()

    const handleType = handleElement.classList.contains("input") ? "input" : "output"
    const handleName = handleElement.getAttribute("data-handle")

    if (handleType === "output") {
      this.startConnection(nodeId, handleName, e)
    }
  }

  onConnectionClick(e, connectionId) {
    e.stopPropagation()
    this.clearSelection()
    this.selectConnection(connectionId)
    this.emit("connectionSelected", { connectionId })
  }

  onKeyDown(e) {
    if (e.key === "Delete" || e.key === "Backspace") {
      this.deleteSelected()
    } else if (e.key === "Escape") {
      this.clearSelection()
    } else if ((e.ctrlKey || e.metaKey) && e.key === "c") {
      this.copy()
    } else if ((e.ctrlKey || e.metaKey) && e.key === "v") {
      this.paste()
    } else if ((e.ctrlKey || e.metaKey) && e.key === "a") {
      e.preventDefault()
      this.selectAll()
    }
  }

  onKeyUp(e) {
    // Handle key up events if needed
  }

  onContextMenu(e) {
    e.preventDefault()
    // Show context menu
    this.emit("contextMenu", { x: e.clientX, y: e.clientY, target: e.target })
  }

  onDragOver(e) {
    e.preventDefault()
  }

  onDrop(e) {
    e.preventDefault()

    const nodeType = e.dataTransfer.getData("text/plain")
    if (!nodeType) return

    const rect = this.container.getBoundingClientRect()
    const x = (e.clientX - rect.left - this.transform.x) / this.transform.scale
    const y = (e.clientY - rect.top - this.transform.y) / this.transform.scale

    this.emit("nodeDropped", { nodeType, position: { x, y } })
  }

  // Connection handling
  startConnection(sourceNodeId, sourceHandle, e) {
    this.isConnecting = true
    this.connectionStart = {
      nodeId: sourceNodeId,
      handle: sourceHandle,
      position: { x: e.clientX, y: e.clientY },
    }

    // Create temporary connection line
    this.createTempConnection()
  }

  createTempConnection() {
    let tempLine = this.connectionsLayer.querySelector(".temp-connection")
    if (!tempLine) {
      tempLine = document.createElementNS("http://www.w3.org/2000/svg", "path")
      tempLine.setAttribute("class", "temp-connection")
      tempLine.setAttribute("stroke", "#999")
      tempLine.setAttribute("stroke-width", "2")
      tempLine.setAttribute("stroke-dasharray", "5,5")
      tempLine.setAttribute("fill", "none")
      this.connectionsLayer.appendChild(tempLine)
    }
  }

  updateTempConnection(e) {
    const tempLine = this.connectionsLayer.querySelector(".temp-connection")
    if (!tempLine || !this.connectionStart) return

    const rect = this.container.getBoundingClientRect()
    const start = this.getHandlePosition(
      this.nodes.get(this.connectionStart.nodeId),
      this.connectionStart.handle,
      "output",
    )
    const end = {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    }

    const path = this.createConnectionPath(start, end)
    tempLine.setAttribute("d", path)
  }

  finishConnection(e) {
    this.isConnecting = false

    // Remove temporary connection
    const tempLine = this.connectionsLayer.querySelector(".temp-connection")
    if (tempLine) {
      tempLine.remove()
    }

    // Find target handle
    const target = e.target
    if (target && target.classList.contains("node-handle") && target.classList.contains("input")) {
      const targetNodeId = target.closest(".workflow-node").getAttribute("data-node-id")
      const targetHandle = target.getAttribute("data-handle")

      if (this.connectionStart && targetNodeId !== this.connectionStart.nodeId) {
        this.addConnection(this.connectionStart.nodeId, this.connectionStart.handle, targetNodeId, targetHandle)
      }
    }

    this.connectionStart = null
  }

  // Selection management
  selectNode(nodeId) {
    this.selectedNodes.add(nodeId)
    const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"]`)
    if (nodeElement) {
      nodeElement.classList.add("selected")
    }
  }

  selectConnection(connectionId) {
    this.selectedConnections.add(connectionId)
    const connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connectionId}"]`)
    if (connectionElement) {
      connectionElement.classList.add("selected")
    }
  }

  clearSelection() {
    // Clear node selection
    this.selectedNodes.forEach((nodeId) => {
      const nodeElement = this.container.querySelector(`[data-node-id="${nodeId}"]`)
      if (nodeElement) {
        nodeElement.classList.remove("selected")
      }
    })
    this.selectedNodes.clear()

    // Clear connection selection
    this.selectedConnections.forEach((connectionId) => {
      const connectionElement = this.connectionsLayer.querySelector(`[data-connection-id="${connectionId}"]`)
      if (connectionElement) {
        connectionElement.classList.remove("selected")
      }
    })
    this.selectedConnections.clear()

    this.emit("selectionCleared")
  }

  selectAll() {
    this.nodes.forEach((node, nodeId) => {
      this.selectNode(nodeId)
    })
    this.emit("nodesSelected", { nodeIds: Array.from(this.selectedNodes) })
  }

  deleteSelected() {
    // Delete selected connections
    this.selectedConnections.forEach((connectionId) => {
      this.removeConnection(connectionId)
    })

    // Delete selected nodes
    this.selectedNodes.forEach((nodeId) => {
      this.removeNode(nodeId)
    })

    this.emit("selectionDeleted")
  }

  // Clipboard operations
  copy() {
    if (this.selectedNodes.size === 0) return

    const nodeData = []
    this.selectedNodes.forEach((nodeId) => {
      const node = this.nodes.get(nodeId)
      if (node) {
        nodeData.push({ ...node })
      }
    })

    this.clipboard = {
      type: "nodes",
      data: nodeData,
    }

    this.emit("copied", { count: nodeData.length })
  }

  paste() {
    if (!this.clipboard || this.clipboard.type !== "nodes") return

    const pastedNodes = []
    const offset = { x: 50, y: 50 }

    this.clearSelection()

    this.clipboard.data.forEach((nodeData) => {
      const newNode = {
        ...nodeData,
        id: this.generateId(),
        position: {
          x: nodeData.position.x + offset.x,
          y: nodeData.position.y + offset.y,
        },
      }

      const nodeId = this.addNode(newNode, newNode.position)
      this.selectNode(nodeId)
      pastedNodes.push(nodeId)
    })

    this.emit("pasted", { nodeIds: pastedNodes })
  }

  // Utility methods
  generateId() {
    return "node_" + Math.random().toString(36).substr(2, 9)
  }

  updateTransform() {
    const transform = `translate(${this.transform.x}px, ${this.transform.y}px) scale(${this.transform.scale})`
    this.nodesLayer.style.transform = transform
    this.connectionsLayer.style.transform = transform
  }

  updateGrid() {
    const gridSize = this.options.gridSize * this.transform.scale
    this.gridLayer.style.backgroundImage = `
            radial-gradient(circle, #ddd 1px, transparent 1px)
        `
    this.gridLayer.style.backgroundSize = `${gridSize}px ${gridSize}px`
    this.gridLayer.style.backgroundPosition = `${this.transform.x % gridSize}px ${this.transform.y % gridSize}px`
  }

  renderConnections() {
    this.connections.forEach((connection) => {
      this.renderConnection(connection)
    })
  }

  // Public API methods
  getWorkflowData() {
    const nodes = []
    const connections = []

    this.nodes.forEach((node) => {
      nodes.push({ ...node })
    })

    this.connections.forEach((connection) => {
      connections.push({ ...connection })
    })

    return { nodes, connections }
  }

  loadWorkflowData(data) {
    this.clear()

    if (data.nodes) {
      data.nodes.forEach((nodeData) => {
        this.addNode(nodeData, nodeData.position)
      })
    }

    if (data.connections) {
      data.connections.forEach((connectionData) => {
        this.addConnection(
          connectionData.source,
          connectionData.sourceHandle,
          connectionData.target,
          connectionData.targetHandle,
        )
      })
    }
  }

  clear() {
    this.nodes.clear()
    this.connections.clear()
    this.selectedNodes.clear()
    this.selectedConnections.clear()
    this.nodesLayer.innerHTML = ""
    this.connectionsLayer.innerHTML = `
            <defs>
                <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#666" />
                </marker>
            </defs>
        `
  }

  centerView() {
    if (this.nodes.size === 0) return

    let minX = Infinity,
      minY = Infinity,
      maxX = -Infinity,
      maxY = -Infinity

    this.nodes.forEach((node) => {
      minX = Math.min(minX, node.position.x)
      minY = Math.min(minY, node.position.y)
      maxX = Math.max(maxX, node.position.x + 200) // Approximate node width
      maxY = Math.max(maxY, node.position.y + 100) // Approximate node height
    })

    const centerX = (minX + maxX) / 2
    const centerY = (minY + maxY) / 2

    const containerRect = this.container.getBoundingClientRect()
    this.transform.x = containerRect.width / 2 - centerX * this.transform.scale
    this.transform.y = containerRect.height / 2 - centerY * this.transform.scale

    this.updateTransform()
  }

  fitToView() {
    if (this.nodes.size === 0) return

    let minX = Infinity,
      minY = Infinity,
      maxX = -Infinity,
      maxY = -Infinity

    this.nodes.forEach((node) => {
      minX = Math.min(minX, node.position.x)
      minY = Math.min(minY, node.position.y)
      maxX = Math.max(maxX, node.position.x + 200)
      maxY = Math.max(maxY, node.position.y + 100)
    })

    const workflowWidth = maxX - minX
    const workflowHeight = maxY - minY

    const containerRect = this.container.getBoundingClientRect()
    const scaleX = (containerRect.width - 100) / workflowWidth
    const scaleY = (containerRect.height - 100) / workflowHeight

    this.transform.scale = Math.min(scaleX, scaleY, 1)

    const centerX = (minX + maxX) / 2
    const centerY = (minY + maxY) / 2

    this.transform.x = containerRect.width / 2 - centerX * this.transform.scale
    this.transform.y = containerRect.height / 2 - centerY * this.transform.scale

    this.updateTransform()
    this.updateGrid()
  }

  // Event system
  emit(eventName, data) {
    const event = new CustomEvent(eventName, { detail: data })
    this.container.dispatchEvent(event)
  }

  on(eventName, callback) {
    this.container.addEventListener(eventName, callback)
  }

  off(eventName, callback) {
    this.container.removeEventListener(eventName, callback)
  }
}

// Export for use in other modules
window.WorkflowCanvas = WorkflowCanvas
