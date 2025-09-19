/**
 * Node Palette - Manages the draggable node palette
 */
class NodePalette {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId)
    this.options = {
      searchable: true,
      collapsible: true,
      ...options,
    }

    this.nodeTypes = new Map()
    this.filteredTypes = new Map()
    this.searchTerm = ""

    this.init()
  }

  init() {
    this.setupPalette()
    this.loadNodeTypes()
  }

  setupPalette() {
    this.container.innerHTML = `
            <div class="palette-header">
                <h3>Nodes</h3>
                ${
                  this.options.searchable
                    ? '<input type="text" class="search-input" placeholder="Search nodes..." id="node-search">'
                    : ""
                }
            </div>
            <div class="palette-content" id="palette-content">
                <!-- Node categories will be populated here -->
            </div>
        `

    if (this.options.searchable) {
      const searchInput = this.container.querySelector("#node-search")
      searchInput.addEventListener("input", (e) => this.filterNodes(e.target.value))
    }
  }

  async loadNodeTypes() {
    try {
      // Try to load from API first
      const response = await fetch("/workflow/api/node-types/")
      if (response.ok) {
        const nodeTypes = await response.json()
        nodeTypes.forEach((nodeType) => {
          this.nodeTypes.set(nodeType.name, nodeType)
        })
      } else {
        // Fallback to default node types
        this.loadDefaultNodeTypes()
      }
    } catch (error) {
      console.warn("Failed to load node types from API, using defaults:", error)
      this.loadDefaultNodeTypes()
    }

    this.filteredTypes = new Map(this.nodeTypes)
    this.renderPalette()
  }

  loadDefaultNodeTypes() {
    const defaultTypes = [
      // Triggers
      {
        name: "webhook_trigger",
        display_name: "Webhook",
        category: "trigger",
        icon: "fa-globe",
        color: "#10b981",
        description: "Trigger workflow via HTTP webhook",
        config_schema: {
          fields: [
            {
              name: "method",
              type: "select",
              options: ["GET", "POST", "PUT", "DELETE"],
              default: "POST",
              label: "HTTP Method",
            },
            { name: "path", type: "text", placeholder: "/webhook/my-endpoint", label: "Endpoint Path" },
          ],
        },
      },
      {
        name: "schedule_trigger",
        display_name: "Schedule",
        category: "trigger",
        icon: "fa-clock",
        color: "#f59e0b",
        description: "Trigger workflow on schedule",
        config_schema: {
          fields: [
            { name: "cron", type: "text", placeholder: "0 9 * * *", label: "Cron Expression" },
            {
              name: "timezone",
              type: "select",
              options: ["UTC", "America/New_York", "Europe/London"],
              default: "UTC",
              label: "Timezone",
            },
          ],
        },
      },
      {
        name: "manual_trigger",
        display_name: "Manual",
        category: "trigger",
        icon: "fa-hand-pointer",
        color: "#6366f1",
        description: "Manually trigger workflow",
        config_schema: { fields: [] },
      },

      // Data Sources
      {
        name: "http_request",
        display_name: "HTTP Request",
        category: "data",
        icon: "fa-exchange-alt",
        color: "#3b82f6",
        description: "Make HTTP requests to APIs",
        config_schema: {
          fields: [
            {
              name: "method",
              type: "select",
              options: ["GET", "POST", "PUT", "DELETE", "PATCH"],
              default: "GET",
              label: "Method",
            },
            { name: "url", type: "text", placeholder: "https://api.example.com/data", label: "URL", required: true },
            { name: "headers", type: "textarea", placeholder: '{"Content-Type": "application/json"}', label: "Headers" },
            { name: "body", type: "textarea", placeholder: "Request body", label: "Body" },
            { name: "timeout", type: "number", default: 30, label: "Timeout (seconds)" },
          ],
        },
      },
      {
        name: "database_query",
        display_name: "Database Query",
        category: "data",
        icon: "fa-database",
        color: "#8b5cf6",
        description: "Query database for data",
        config_schema: {
          fields: [
            {
              name: "query_type",
              type: "select",
              options: ["SELECT", "INSERT", "UPDATE", "DELETE"],
              default: "SELECT",
              label: "Query Type",
            },
            { name: "table_name", type: "text", placeholder: "users", label: "Table Name", required: true },
            { name: "conditions", type: "text", placeholder: "active = true", label: "WHERE Conditions" },
            { name: "fields", type: "text", placeholder: "*", default: "*", label: "Fields" },
            { name: "limit", type: "number", default: 100, label: "Limit" },
          ],
        },
      },

      // Transform
      {
        name: "data_transform",
        display_name: "Transform Data",
        category: "transform",
        icon: "fa-cogs",
        color: "#059669",
        description: "Transform and map data",
        config_schema: {
          fields: [
            {
              name: "transform_type",
              type: "select",
              options: ["map", "filter", "aggregate"],
              default: "map",
              label: "Transform Type",
            },
            { name: "field_mappings", type: "textarea", placeholder: "JSON field mappings", label: "Field Mappings" },
          ],
        },
      },
      {
        name: "json_parser",
        display_name: "JSON Parser",
        category: "transform",
        icon: "fa-code",
        color: "#dc2626",
        description: "Parse and manipulate JSON data",
        config_schema: {
          fields: [
            {
              name: "operation",
              type: "select",
              options: ["parse", "stringify", "extract"],
              default: "parse",
              label: "Operation",
            },
            { name: "json_field", type: "text", placeholder: "data", default: "data", label: "JSON Field" },
            { name: "fields", type: "textarea", placeholder: "Fields to extract", label: "Fields" },
          ],
        },
      },

      // Conditions
      {
        name: "condition",
        display_name: "Condition",
        category: "condition",
        icon: "fa-code-branch",
        color: "#ef4444",
        description: "Branch workflow based on conditions",
        config_schema: {
          fields: [
            { name: "field", type: "text", placeholder: "data.status", label: "Field Path", required: true },
            {
              name: "operator",
              type: "select",
              options: [
                "equals",
                "not_equals",
                "greater_than",
                "less_than",
                "contains",
                "not_contains",
                "is_empty",
                "is_not_empty",
              ],
              default: "equals",
              label: "Operator",
            },
            { name: "value", type: "text", placeholder: "expected value", label: "Value" },
            {
              name: "logic_operator",
              type: "select",
              options: ["AND", "OR"],
              default: "AND",
              label: "Logic Operator",
            },
          ],
        },
      },
      {
        name: "switch",
        display_name: "Switch",
        category: "condition",
        icon: "fa-random",
        color: "#f59e0b",
        description: "Route to different paths based on value",
        config_schema: {
          fields: [
            { name: "switch_field", type: "text", placeholder: "data.type", label: "Switch Field", required: true },
            { name: "cases", type: "textarea", placeholder: "JSON cases mapping", label: "Cases" },
          ],
        },
      },

      // Actions
      {
        name: "email_send",
        display_name: "Send Email",
        category: "action",
        icon: "fa-envelope",
        color: "#06b6d4",
        description: "Send email notifications",
        config_schema: {
          fields: [
            { name: "to", type: "text", placeholder: "user@example.com", label: "To", required: true },
            { name: "subject", type: "text", placeholder: "Email Subject", label: "Subject", required: true },
            { name: "body", type: "textarea", placeholder: "Email body content...", label: "Body", required: true },
            { name: "from_email", type: "text", placeholder: "noreply@example.com", label: "From Email" },
          ],
        },
      },
      {
        name: "slack_notification",
        display_name: "Slack Notification",
        category: "action",
        icon: "fa-slack",
        color: "#4a154b",
        description: "Send Slack notifications",
        config_schema: {
          fields: [
            {
              name: "webhook_url",
              type: "text",
              placeholder: "https://hooks.slack.com/...",
              label: "Webhook URL",
              required: true,
            },
            { name: "message", type: "textarea", placeholder: "Notification message", label: "Message", required: true },
            { name: "channel", type: "text", placeholder: "#general", label: "Channel" },
            { name: "username", type: "text", placeholder: "Workflow Bot", default: "Workflow Bot", label: "Username" },
          ],
        },
      },
      {
        name: "webhook_send",
        display_name: "Send Webhook",
        category: "action",
        icon: "fa-paper-plane",
        color: "#7c3aed",
        description: "Send webhook to external service",
        config_schema: {
          fields: [
            { name: "url", type: "text", placeholder: "https://api.example.com/webhook", label: "URL", required: true },
            {
              name: "method",
              type: "select",
              options: ["POST", "PUT", "PATCH"],
              default: "POST",
              label: "Method",
            },
            { name: "headers", type: "textarea", placeholder: "JSON headers", label: "Headers" },
            { name: "payload", type: "textarea", placeholder: "JSON payload", label: "Payload" },
            { name: "timeout", type: "number", default: 30, label: "Timeout (seconds)" },
          ],
        },
      },
      {
        name: "delay",
        display_name: "Delay",
        category: "action",
        icon: "fa-clock",
        color: "#f59e0b",
        description: "Add delay to workflow execution",
        config_schema: {
          fields: [
            { name: "delay_seconds", type: "number", default: 1, label: "Delay (seconds)", required: true },
            {
              name: "delay_type",
              type: "select",
              options: ["fixed", "random"],
              default: "fixed",
              label: "Delay Type",
            },
            { name: "min_delay", type: "number", default: 1, label: "Min Delay (for random)" },
            { name: "max_delay", type: "number", default: 5, label: "Max Delay (for random)" },
          ],
        },
      },
      {
        name: "log",
        display_name: "Log Message",
        category: "action",
        icon: "fa-file-text",
        color: "#6b7280",
        description: "Log messages for debugging",
        config_schema: {
          fields: [
            { name: "message", type: "textarea", placeholder: "Log message", label: "Message" },
            {
              name: "level",
              type: "select",
              options: ["info", "warning", "error", "debug"],
              default: "info",
              label: "Log Level",
            },
            { name: "include_data", type: "checkbox", default: false, label: "Include Input Data" },
          ],
        },
      },

      // Output
      {
        name: "database_save",
        display_name: "Save to Database",
        category: "output",
        icon: "fa-save",
        color: "#059669",
        description: "Save data to database",
        config_schema: {
          fields: [
            { name: "table_name", type: "text", placeholder: "table_name", label: "Table Name", required: true },
            {
              name: "operation",
              type: "select",
              options: ["insert", "update", "upsert"],
              default: "insert",
              label: "Operation",
            },
            { name: "where_conditions", type: "textarea", placeholder: "JSON conditions", label: "WHERE Conditions" },
            { name: "unique_columns", type: "text", placeholder: "id,email", label: "Unique Columns (for upsert)" },
          ],
        },
      },
      {
        name: "file_export",
        display_name: "Export to File",
        category: "output",
        icon: "fa-download",
        color: "#7c2d12",
        description: "Export data to file",
        config_schema: {
          fields: [
            { name: "file_path", type: "text", placeholder: "/tmp/export.json", label: "File Path", required: true },
            {
              name: "format",
              type: "select",
              options: ["json", "csv", "txt"],
              default: "json",
              label: "Format",
            },
          ],
        },
      },
      {
        name: "response",
        display_name: "HTTP Response",
        category: "output",
        icon: "fa-reply",
        color: "#0891b2",
        description: "Send HTTP response (for webhooks)",
        config_schema: {
          fields: [
            { name: "status_code", type: "number", default: 200, label: "Status Code" },
            { name: "response_data", type: "textarea", placeholder: "JSON response", label: "Response Data" },
            { name: "headers", type: "textarea", placeholder: "JSON headers", label: "Headers" },
          ],
        },
      },
    ]

    defaultTypes.forEach((nodeType) => {
      this.nodeTypes.set(nodeType.name, nodeType)
    })
  }

  renderPalette() {
    const content = this.container.querySelector("#palette-content")
    const categories = this.groupByCategory(this.filteredTypes)

    content.innerHTML = ""

    Object.entries(categories).forEach(([category, nodes]) => {
      const categoryElement = this.createCategoryElement(category, nodes)
      content.appendChild(categoryElement)
    })
  }

  groupByCategory(nodeTypes) {
    const categories = {}

    nodeTypes.forEach((nodeType) => {
      const category = nodeType.category || "other"
      if (!categories[category]) {
        categories[category] = []
      }
      categories[category].push(nodeType)
    })

    // Sort categories
    const sortedCategories = {}
    const categoryOrder = ["trigger", "data", "transform", "condition", "action", "output", "other"]

    categoryOrder.forEach((cat) => {
      if (categories[cat]) {
        sortedCategories[cat] = categories[cat].sort((a, b) => a.display_name.localeCompare(b.display_name))
      }
    })

    return sortedCategories
  }

  createCategoryElement(category, nodes) {
    const categoryDiv = document.createElement("div")
    categoryDiv.className = "node-category"
    categoryDiv.setAttribute("data-category", category)

    const header = document.createElement("div")
    header.className = "category-header"
    header.innerHTML = `
            <i class="fas ${this.getCategoryIcon(category)}"></i>
            <span>${this.formatCategoryName(category)}</span>
            <i class="fas fa-chevron-down toggle-icon"></i>
        `

    if (this.options.collapsible) {
      header.addEventListener("click", () => {
        categoryDiv.classList.toggle("collapsed")
      })
    }

    const nodesContainer = document.createElement("div")
    nodesContainer.className = "category-nodes"

    nodes.forEach((nodeType) => {
      const nodeElement = this.createNodeElement(nodeType)
      nodesContainer.appendChild(nodeElement)
    })

    categoryDiv.appendChild(header)
    categoryDiv.appendChild(nodesContainer)

    return categoryDiv
  }

  createNodeElement(nodeType) {
    const nodeDiv = document.createElement("div")
    nodeDiv.className = "palette-node"
    nodeDiv.draggable = true
    nodeDiv.setAttribute("data-node-type", nodeType.name)
    nodeDiv.title = nodeType.description || nodeType.display_name

    nodeDiv.innerHTML = `
            <div class="node-icon" style="background-color: ${nodeType.color}">
                <i class="fas ${nodeType.icon}"></i>
            </div>
            <span class="node-name">${nodeType.display_name}</span>
        `

    // Add drag events
    nodeDiv.addEventListener("dragstart", (e) => {
      e.dataTransfer.setData("text/plain", nodeType.name)
      e.dataTransfer.setData("application/json", JSON.stringify(nodeType))
      nodeDiv.classList.add("dragging")
    })

    nodeDiv.addEventListener("dragend", () => {
      nodeDiv.classList.remove("dragging")
    })

    return nodeDiv
  }

  getCategoryIcon(category) {
    const icons = {
      trigger: "fa-play-circle",
      data: "fa-database",
      transform: "fa-cogs",
      condition: "fa-code-branch",
      action: "fa-bolt",
      output: "fa-external-link-alt",
      other: "fa-cube",
    }
    return icons[category] || "fa-cube"
  }

  formatCategoryName(category) {
    const names = {
      trigger: "Triggers",
      data: "Data Sources",
      transform: "Transform",
      condition: "Conditions",
      action: "Actions",
      output: "Outputs",
      other: "Other",
    }
    return names[category] || category.charAt(0).toUpperCase() + category.slice(1)
  }

  filterNodes(searchTerm) {
    this.searchTerm = searchTerm.toLowerCase()

    if (!this.searchTerm) {
      this.filteredTypes = new Map(this.nodeTypes)
    } else {
      this.filteredTypes = new Map()
      this.nodeTypes.forEach((nodeType, key) => {
        if (
          nodeType.display_name.toLowerCase().includes(this.searchTerm) ||
          nodeType.name.toLowerCase().includes(this.searchTerm) ||
          (nodeType.description && nodeType.description.toLowerCase().includes(this.searchTerm)) ||
          nodeType.category.toLowerCase().includes(this.searchTerm)
        ) {
          this.filteredTypes.set(key, nodeType)
        }
      })
    }

    this.renderPalette()
  }

  getNodeType(name) {
    return this.nodeTypes.get(name)
  }

  getAllNodeTypes() {
    return Array.from(this.nodeTypes.values())
  }

  getNodeTypesByCategory(category) {
    return Array.from(this.nodeTypes.values()).filter((nodeType) => nodeType.category === category)
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
window.NodePalette = NodePalette
