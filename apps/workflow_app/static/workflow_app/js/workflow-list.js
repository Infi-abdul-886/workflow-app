/**
 * Workflow List JavaScript - Handles workflow list interactions
 */
class WorkflowList {
  constructor() {
    this.init()
  }

  init() {
    this.setupEventListeners()
    this.setupSearch()
    this.setupFilters()
  }

  setupEventListeners() {
    // Workflow action buttons
    document.querySelectorAll(".workflow-action").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault()
        const action = e.target.dataset.action
        const workflowId = e.target.dataset.workflowId
        this.handleWorkflowAction(action, workflowId)
      })
    })

    // Bulk actions
    document.getElementById("select-all")?.addEventListener("change", (e) => {
      this.toggleSelectAll(e.target.checked)
    })

    document.querySelectorAll(".workflow-checkbox").forEach((checkbox) => {
      checkbox.addEventListener("change", () => {
        this.updateBulkActions()
      })
    })

    // Bulk action buttons
    document.getElementById("bulk-activate")?.addEventListener("click", () => {
      this.bulkAction("activate")
    })

    document.getElementById("bulk-deactivate")?.addEventListener("click", () => {
      this.bulkAction("deactivate")
    })

    document.getElementById("bulk-delete")?.addEventListener("click", () => {
      this.bulkAction("delete")
    })

    // View toggle
    document.querySelectorAll(".view-toggle").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        this.toggleView(e.target.dataset.view)
      })
    })

    // Sort options
    document.getElementById("sort-select")?.addEventListener("change", (e) => {
      this.sortWorkflows(e.target.value)
    })
  }

  setupSearch() {
    const searchInput = document.getElementById("workflow-search")
    if (!searchInput) return

    let searchTimeout
    searchInput.addEventListener("input", (e) => {
      clearTimeout(searchTimeout)
      searchTimeout = setTimeout(() => {
        this.filterWorkflows(e.target.value)
      }, 300)
    })
  }

  setupFilters() {
    // Status filter
    document.querySelectorAll(".status-filter").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        this.filterByStatus(e.target.dataset.status)
      })
    })

    // Date range filter
    document.getElementById("date-from")?.addEventListener("change", () => {
      this.applyDateFilter()
    })

    document.getElementById("date-to")?.addEventListener("change", () => {
      this.applyDateFilter()
    })

    // Clear filters
    document.getElementById("clear-filters")?.addEventListener("click", () => {
      this.clearFilters()
    })
  }

  async handleWorkflowAction(action, workflowId) {
    try {
      let endpoint, method, message

      switch (action) {
        case "activate":
          endpoint = `/api/workflows/${workflowId}/activate/`
          method = "POST"
          message = "Workflow activated successfully"
          break
        case "deactivate":
          endpoint = `/api/workflows/${workflowId}/deactivate/`
          method = "POST"
          message = "Workflow deactivated successfully"
          break
        case "duplicate":
          endpoint = `/api/workflows/${workflowId}/duplicate/`
          method = "POST"
          message = "Workflow duplicated successfully"
          break
        case "delete":
          if (!confirm("Are you sure you want to delete this workflow?")) return
          endpoint = `/api/workflows/${workflowId}/`
          method = "DELETE"
          message = "Workflow deleted successfully"
          break
        case "export":
          this.exportWorkflow(workflowId)
          return
        default:
          return
      }

      const response = await fetch(endpoint, {
        method: method,
        headers: {
          "X-CSRFToken": this.getCsrfToken(),
          "Content-Type": "application/json",
        },
      })

      if (response.ok) {
        this.showNotification(message, "success")

        if (action === "delete") {
          // Remove card from DOM
          const card = document.querySelector(`[data-workflow-id="${workflowId}"]`)
          if (card) {
            card.style.animation = "fadeOut 0.3s ease"
            setTimeout(() => card.remove(), 300)
          }
        } else if (action === "duplicate") {
          // Reload page to show new workflow
          setTimeout(() => window.location.reload(), 1000)
        } else {
          // Update status in DOM
          this.updateWorkflowStatus(workflowId, action === "activate" ? "active" : "inactive")
        }
      } else {
        throw new Error(`Failed to ${action} workflow`)
      }
    } catch (error) {
      console.error(`${action} error:`, error)
      this.showNotification(`Failed to ${action} workflow`, "error")
    }
  }

  async exportWorkflow(workflowId) {
    try {
      const response = await fetch(`/api/workflows/${workflowId}/export/`, {
        headers: {
          "X-CSRFToken": this.getCsrfToken(),
        },
      })

      if (response.ok) {
        const data = await response.json()
        const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
        const url = URL.createObjectURL(blob)

        const a = document.createElement("a")
        a.href = url
        a.download = `workflow-${workflowId}.json`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)

        this.showNotification("Workflow exported successfully", "success")
      } else {
        throw new Error("Failed to export workflow")
      }
    } catch (error) {
      console.error("Export error:", error)
      this.showNotification("Failed to export workflow", "error")
    }
  }

  toggleSelectAll(checked) {
    document.querySelectorAll(".workflow-checkbox").forEach((checkbox) => {
      checkbox.checked = checked
    })
    this.updateBulkActions()
  }

  updateBulkActions() {
    const selectedCount = document.querySelectorAll(".workflow-checkbox:checked").length
    const bulkActions = document.getElementById("bulk-actions")

    if (bulkActions) {
      bulkActions.style.display = selectedCount > 0 ? "flex" : "none"
    }

    const selectedCountElement = document.getElementById("selected-count")
    if (selectedCountElement) {
      selectedCountElement.textContent = selectedCount
    }
  }

  async bulkAction(action) {
    const selectedWorkflows = Array.from(document.querySelectorAll(".workflow-checkbox:checked")).map(
      (checkbox) => checkbox.dataset.workflowId,
    )

    if (selectedWorkflows.length === 0) return

    if (action === "delete" && !confirm(`Are you sure you want to delete ${selectedWorkflows.length} workflows?`)) {
      return
    }

    try {
      const promises = selectedWorkflows.map((workflowId) => this.handleWorkflowAction(action, workflowId))

      await Promise.all(promises)

      // Clear selections
      this.toggleSelectAll(false)
    } catch (error) {
      console.error("Bulk action error:", error)
      this.showNotification(`Failed to ${action} selected workflows`, "error")
    }
  }

  filterWorkflows(searchTerm) {
    const term = searchTerm.toLowerCase()
    document.querySelectorAll(".workflow-card").forEach((card) => {
      const title = card.querySelector(".workflow-title")?.textContent.toLowerCase() || ""
      const description = card.querySelector(".workflow-description")?.textContent.toLowerCase() || ""
      const tags = card.querySelector(".workflow-tags")?.textContent.toLowerCase() || ""

      const matches = title.includes(term) || description.includes(term) || tags.includes(term)
      card.style.display = matches ? "block" : "none"
    })

    this.updateResultsCount()
  }

  filterByStatus(status) {
    // Update active filter button
    document.querySelectorAll(".status-filter").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.status === status)
    })

    // Apply filter
    document.querySelectorAll(".workflow-card").forEach((card) => {
      const cardStatus = card.dataset.status
      const shouldShow = status === "all" || cardStatus === status
      card.style.display = shouldShow ? "block" : "none"
    })

    this.updateResultsCount()
  }

  applyDateFilter() {
    const dateFrom = document.getElementById("date-from")?.value
    const dateTo = document.getElementById("date-to")?.value

    if (!dateFrom && !dateTo) return

    document.querySelectorAll(".workflow-card").forEach((card) => {
      const cardDate = new Date(card.dataset.updatedAt)
      let shouldShow = true

      if (dateFrom) {
        const fromDate = new Date(dateFrom)
        shouldShow = shouldShow && cardDate >= fromDate
      }

      if (dateTo) {
        const toDate = new Date(dateTo)
        toDate.setHours(23, 59, 59, 999) // End of day
        shouldShow = shouldShow && cardDate <= toDate
      }

      card.style.display = shouldShow ? "block" : "none"
    })

    this.updateResultsCount()
  }

  clearFilters() {
    // Clear search
    const searchInput = document.getElementById("workflow-search")
    if (searchInput) searchInput.value = ""

    // Clear date filters
    const dateFrom = document.getElementById("date-from")
    const dateTo = document.getElementById("date-to")
    if (dateFrom) dateFrom.value = ""
    if (dateTo) dateTo.value = ""

    // Reset status filter
    document.querySelectorAll(".status-filter").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.status === "all")
    })

    // Show all workflows
    document.querySelectorAll(".workflow-card").forEach((card) => {
      card.style.display = "block"
    })

    this.updateResultsCount()
  }

  sortWorkflows(sortBy) {
    const container = document.getElementById("workflows-container")
    if (!container) return

    const cards = Array.from(container.querySelectorAll(".workflow-card"))

    cards.sort((a, b) => {
      switch (sortBy) {
        case "name":
          return a
            .querySelector(".workflow-title")
            .textContent.localeCompare(b.querySelector(".workflow-title").textContent)
        case "updated":
          return new Date(b.dataset.updatedAt) - new Date(a.dataset.updatedAt)
        case "created":
          return new Date(b.dataset.createdAt) - new Date(a.dataset.createdAt)
        case "executions":
          return Number.parseInt(b.dataset.executionCount || "0") - Number.parseInt(a.dataset.executionCount || "0")
        default:
          return 0
      }
    })

    // Re-append sorted cards
    cards.forEach((card) => container.appendChild(card))
  }

  toggleView(view) {
    // Update active view button
    document.querySelectorAll(".view-toggle").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.view === view)
    })

    // Update container class
    const container = document.getElementById("workflows-container")
    if (container) {
      container.className = `workflows-${view}`
    }
  }

  updateWorkflowStatus(workflowId, newStatus) {
    const card = document.querySelector(`[data-workflow-id="${workflowId}"]`)
    if (!card) return

    // Update status badge
    const statusBadge = card.querySelector(".status-badge")
    if (statusBadge) {
      statusBadge.className = `status-badge status-${newStatus}`
      statusBadge.textContent = newStatus.charAt(0).toUpperCase() + newStatus.slice(1)
    }

    // Update card data attribute
    card.dataset.status = newStatus

    // Update action buttons
    const activateBtn = card.querySelector('[data-action="activate"]')
    const deactivateBtn = card.querySelector('[data-action="deactivate"]')

    if (activateBtn) activateBtn.style.display = newStatus === "active" ? "none" : "inline-flex"
    if (deactivateBtn) deactivateBtn.style.display = newStatus === "active" ? "inline-flex" : "none"
  }

  updateResultsCount() {
    const visibleCards = document.querySelectorAll(
      '.workflow-card[style*="block"], .workflow-card:not([style*="none"])',
    ).length
    const totalCards = document.querySelectorAll(".workflow-card").length

    const resultsCount = document.getElementById("results-count")
    if (resultsCount) {
      resultsCount.textContent = `Showing ${visibleCards} of ${totalCards} workflows`
    }
  }

  getCsrfToken() {
    return (
      document.querySelector("[name=csrfmiddlewaretoken]")?.value ||
      document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")
    )
  }

  showNotification(message, type = "info") {
    const notification = document.createElement("div")
    notification.className = `notification notification-${type}`
    notification.textContent = message
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
        `

    const colors = {
      success: "#10b981",
      error: "#ef4444",
      warning: "#f59e0b",
      info: "#3b82f6",
    }

    notification.style.backgroundColor = colors[type] || colors.info
    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}

// Add CSS animations
const style = document.createElement("style")
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes fadeOut {
        from {
            opacity: 1;
            transform: scale(1);
        }
        to {
            opacity: 0;
            transform: scale(0.95);
        }
    }
`
document.head.appendChild(style)

// Initialize when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
  window.workflowList = new WorkflowList()
})
