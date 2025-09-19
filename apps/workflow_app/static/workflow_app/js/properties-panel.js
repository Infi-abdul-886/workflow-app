/**
 * Properties Panel - Manages node and connection property editing
 */
class PropertiesPanel {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId)
    this.options = {
      autoSave: true,
      ...options,
    }

    this.currentNode = null
    this.currentConnection = null
    this.nodeTypes = new Map()

    this.init()
  }

  init() {
    this.setupPanel()
    this.loadNodeTypes()
  }

  setupPanel() {
    this.container.innerHTML = `
            <div class="panel-header">
                <h3 id="panel-title">Properties</h3>
                <button id="close-panel" class="btn btn-icon">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="panel-content" id="panel-content">
                <div id="no-selection" class="no-selection">
                    <i class="fas fa-mouse-pointer"></i>
                    <p>Select a node to view its properties</p>
                </div>
                <div id="node-properties" class="node-properties" style="display: none;">
                    <!-- Node properties form will be populated here -->
                </div>
                <div id="connection-properties" class="connection-properties" style="display: none;">
                    <!-- Connection properties will be shown here -->
                </div>
            </div>
        `

    // Close panel button
    this.container.querySelector("#close-panel").addEventListener("click", () => {
      this.hide()
    })
  }

  async loadNodeTypes() {
    try {
      const response = await fetch("/workflow/api/node-types/")
      if (response.ok) {
        const nodeTypes = await response.json()
        nodeTypes.forEach((nodeType) => {
          this.nodeTypes.set(nodeType.name, nodeType)
        })
      }
    } catch (error) {
      console.warn("Failed to load node types:", error)
    }
  }

  showNodeProperties(node) {
    this.currentNode = node
    this.currentConnection = null

    const nodeType = this.nodeTypes.get(node.type)
    if (!nodeType) {
      console.warn("Unknown node type:", node.type)
      return
    }

    // Update panel title
    this.container.querySelector("#panel-title").textContent = node.name || nodeType.display_name

    // Hide other sections
    this.container.querySelector("#no-selection").style.display = "none"
    this.container.querySelector("#connection-properties").style.display = "none"

    // Show and populate node properties
    const propertiesContainer = this.container.querySelector("#node-properties")
    propertiesContainer.style.display = "block"
    propertiesContainer.innerHTML = this.generateNodePropertiesForm(node, nodeType)

    // Add event listeners
    this.setupFormEventListeners(propertiesContainer)

    this.emit("nodePropertiesShown", { node })
  }

  showConnectionProperties(connection) {
    this.currentConnection = connection
    this.currentNode = null

    // Update panel title
    this.container.querySelector("#panel-title").textContent = "Connection Properties"

    // Hide other sections
    this.container.querySelector("#no-selection").style.display = "none"
    this.container.querySelector("#node-properties").style.display = "none"

    // Show and populate connection properties
    const propertiesContainer = this.container.querySelector("#connection-properties")
    propertiesContainer.style.display = "block"
    propertiesContainer.innerHTML = this.generateConnectionPropertiesForm(connection)

    // Add event listeners
    this.setupFormEventListeners(propertiesContainer)

    this.emit("connectionPropertiesShown", { connection })
  }

  hide() {
    this.currentNode = null
    this.currentConnection = null

    // Update panel title
    this.container.querySelector("#panel-title").textContent = "Properties"

    // Show no selection message
    this.container.querySelector("#no-selection").style.display = "flex"
    this.container.querySelector("#node-properties").style.display = "none"
    this.container.querySelector("#connection-properties").style.display = "none"

    this.emit("propertiesHidden")
  }

  generateNodePropertiesForm(node, nodeType) {
    let html = `
            <div class="form-section">
                <h4>General</h4>
                <div class="form-group">
                    <label for="node-name">Node Name</label>
                    <input type="text" id="node-name" name="name" value="${node.name || nodeType.display_name}" class="form-control">
                </div>
                <div class="form-group">
                    <label for="node-description">Description</label>
                    <textarea id="node-description" name="description" class="form-control" rows="2" placeholder="Optional description">${node.description || ""}</textarea>
                </div>
            </div>
        `

    if (nodeType.config_schema && nodeType.config_schema.fields) {
      html += `<div class="form-section"><h4>Configuration</h4>`

      nodeType.config_schema.fields.forEach((field) => {
        const value = node.config[field.name] || field.default || ""
        html += this.generateFormField(field, value)
      })

      html += `</div>`
    }

    // Advanced section
    html += `
            <div class="form-section">
                <h4>Advanced</h4>
                <div class="form-group">
                    <label>
                        <input type="checkbox" name="continue_on_error" ${node.continue_on_error ? "checked" : ""}>
                        Continue on Error
                    </label>
                    <small class="form-help">Continue workflow execution even if this node fails</small>
                </div>
                <div class="form-group">
                    <label for="node-timeout">Timeout (seconds)</label>
                    <input type="number" id="node-timeout" name="timeout" value="${node.timeout || 30}" class="form-control" min="1" max="3600">
                </div>
            </div>
        `

    return html
  }

  generateConnectionPropertiesForm(connection) {
    return `
            <div class="form-section">
                <h4>Connection Details</h4>
                <div class="form-group">
                    <label>Source Node</label>
                    <input type="text" value="${connection.source}" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>Source Handle</label>
                    <input type="text" value="${connection.sourceHandle}" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>Target Node</label>
                    <input type="text" value="${connection.target}" class="form-control" readonly>
                </div>
                <div class="form-group">
                    <label>Target Handle</label>
                    <input type="text" value="${connection.targetHandle}" class="form-control" readonly>
                </div>
            </div>
            <div class="form-section">
                <h4>Data Transformation</h4>
                <div class="form-group">
                    <label for="connection-transform">Transform Expression</label>
                    <textarea id="connection-transform" name="transform" class="form-control" rows="3" placeholder="Optional data transformation expression">${connection.transform || ""}</textarea>
                    <small class="form-help">JavaScript expression to transform data passing through this connection</small>
                </div>
            </div>
        `
  }

  generateFormField(field, value) {
    const fieldId = `field-${field.name}`
    const required = field.required ? "required" : ""
    const placeholder = field.placeholder || ""

    let html = `<div class="form-group">`
    html += `<label for="${fieldId}">${field.label || this.formatFieldName(field.name)}</label>`

    switch (field.type) {
      case "text":
        html += `<input type="text" id="${fieldId}" name="${field.name}" value="${value}" placeholder="${placeholder}" class="form-control" ${required}>`
        break

      case "number":
        const min = field.min !== undefined ? `min="${field.min}"` : ""
        const max = field.max !== undefined ? `max="${field.max}"` : ""
        const step = field.step !== undefined ? `step="${field.step}"` : ""
        html += `<input type="number" id="${fieldId}" name="${field.name}" value="${value}" placeholder="${placeholder}" class="form-control" ${min} ${max} ${step} ${required}>`
        break

      case "textarea":
        const rows = field.rows || 3
        html += `<textarea id="${fieldId}" name="${field.name}" placeholder="${placeholder}" class="form-control" rows="${rows}" ${required}>${value}</textarea>`
        break

      case "select":
        html += `<select id="${fieldId}" name="${field.name}" class="form-control" ${required}>`
        if (!field.required) {
          html += `<option value="">-- Select --</option>`
        }
        field.options.forEach((option) => {
          const selected = value === option ? "selected" : ""
          html += `<option value="${option}" ${selected}>${option}</option>`
        })
        html += `</select>`
        break

      case "checkbox":
        const checked = value === true || value === "true" ? "checked" : ""
        html += `<label class="checkbox-label">
                    <input type="checkbox" id="${fieldId}" name="${field.name}" ${checked}>
                    ${field.label || this.formatFieldName(field.name)}
                </label>`
        break

      case "json":
        html += `<textarea id="${fieldId}" name="${field.name}" placeholder="${placeholder}" class="form-control json-editor" rows="5" ${required}>${typeof value === "object" ? JSON.stringify(value, null, 2) : value}</textarea>`
        break

      default:
        html += `<input type="text" id="${fieldId}" name="${field.name}" value="${value}" placeholder="${placeholder}" class="form-control" ${required}>`
    }

    if (field.help) {
      html += `<small class="form-help">${field.help}</small>`
    }

    html += `</div>`
    return html
  }

  setupFormEventListeners(container) {
    // Add change listeners to all form elements
    const formElements = container.querySelectorAll("input, select, textarea")

    formElements.forEach((element) => {
      element.addEventListener("change", (e) => {
        this.handleFieldChange(e.target)
      })

      element.addEventListener("input", (e) => {
        if (this.options.autoSave && (e.target.type === "text" || e.target.tagName === "TEXTAREA")) {
          // Debounce text input changes
          clearTimeout(this.inputTimeout)
          this.inputTimeout = setTimeout(() => {
            this.handleFieldChange(e.target)
          }, 500)
        }
      })
    })

    // JSON validation for JSON fields
    container.querySelectorAll(".json-editor").forEach((textarea) => {
      textarea.addEventListener("blur", (e) => {
        this.validateJsonField(e.target)
      })
    })
  }

  handleFieldChange(element) {
    const fieldName = element.name
    let fieldValue = element.value

    // Handle different input types
    if (element.type === "checkbox") {
      fieldValue = element.checked
    } else if (element.type === "number") {
      fieldValue = element.value ? Number(element.value) : null
    } else if (element.classList.contains("json-editor")) {
      try {
        fieldValue = fieldValue ? JSON.parse(fieldValue) : null
      } catch (e) {
        // Keep as string if JSON parsing fails
        console.warn("Invalid JSON in field:", fieldName)
      }
    }

    if (this.currentNode) {
      this.updateNodeProperty(fieldName, fieldValue)
    } else if (this.currentConnection) {
      this.updateConnectionProperty(fieldName, fieldValue)
    }
  }

  updateNodeProperty(fieldName, fieldValue) {
    if (!this.currentNode) return

    if (fieldName === "name") {
      this.currentNode.name = fieldValue
    } else if (fieldName === "description") {
      this.currentNode.description = fieldValue
    } else if (fieldName === "continue_on_error") {
      this.currentNode.continue_on_error = fieldValue
    } else if (fieldName === "timeout") {
      this.currentNode.timeout = fieldValue
    } else {
      // Configuration field
      if (!this.currentNode.config) {
        this.currentNode.config = {}
      }
      this.currentNode.config[fieldName] = fieldValue
    }

    this.emit("nodePropertyChanged", {
      node: this.currentNode,
      field: fieldName,
      value: fieldValue,
    })
  }

  updateConnectionProperty(fieldName, fieldValue) {
    if (!this.currentConnection) return

    this.currentConnection[fieldName] = fieldValue

    this.emit("connectionPropertyChanged", {
      connection: this.currentConnection,
      field: fieldName,
      value: fieldValue,
    })
  }

  validateJsonField(textarea) {
    try {
      if (textarea.value.trim()) {
        JSON.parse(textarea.value)
      }
      textarea.classList.remove("error")
      textarea.title = ""
    } catch (e) {
      textarea.classList.add("error")
      textarea.title = `Invalid JSON: ${e.message}`
    }
  }

  formatFieldName(name) {
    return name
      .split("_")
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(" ")
  }

  // Public API methods
  getCurrentNode() {
    return this.currentNode
  }

  getCurrentConnection() {
    return this.currentConnection
  }

  updateNodeTypes(nodeTypes) {
    this.nodeTypes.clear()
    nodeTypes.forEach((nodeType) => {
      this.nodeTypes.set(nodeType.name, nodeType)
    })
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
window.PropertiesPanel = PropertiesPanel
