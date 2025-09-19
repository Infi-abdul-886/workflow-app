import { Chart } from "@/components/ui/chart"
/**
 * Dashboard JavaScript - Handles dashboard interactions and charts
 */
class Dashboard {
  constructor() {
    this.charts = {}
    this.init()
  }

  init() {
    this.setupEventListeners()
    this.initializeCharts()
    this.loadRecentActivity()
    this.setupAutoRefresh()
  }

  setupEventListeners() {
    // Quick action buttons
    document.getElementById("create-workflow-btn")?.addEventListener("click", () => {
      window.location.href = "/workflow/editor/"
    })

    // Filter buttons
    document.querySelectorAll(".filter-btn").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        this.filterWorkflows(e.target.dataset.filter)
      })
    })

    // Refresh button
    document.getElementById("refresh-dashboard")?.addEventListener("click", () => {
      this.refreshDashboard()
    })

    // Workflow action buttons
    document.querySelectorAll(".workflow-action").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const action = e.target.dataset.action
        const workflowId = e.target.dataset.workflowId
        this.handleWorkflowAction(action, workflowId)
      })
    })
  }

  initializeCharts() {
    this.initExecutionTrendChart()
    this.initStatusDistributionChart()
    this.initPerformanceChart()
  }

  initExecutionTrendChart() {
    const ctx = document.getElementById("execution-trend-chart")
    if (!ctx) return

    const data = JSON.parse(ctx.dataset.chartData || "[]")

    this.charts.executionTrend = new Chart(ctx, {
      type: "line",
      data: {
        labels: data.map((d) => d.day),
        datasets: [
          {
            label: "Successful",
            data: data.map((d) => d.successful),
            borderColor: "#10b981",
            backgroundColor: "rgba(16, 185, 129, 0.1)",
            tension: 0.4,
          },
          {
            label: "Failed",
            data: data.map((d) => d.failed),
            borderColor: "#ef4444",
            backgroundColor: "rgba(239, 68, 68, 0.1)",
            tension: 0.4,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: "top",
          },
          title: {
            display: true,
            text: "Execution Trends (Last 7 Days)",
          },
        },
        scales: {
          y: {
            beginAtZero: true,
          },
        },
      },
    })
  }

  initStatusDistributionChart() {
    const ctx = document.getElementById("status-distribution-chart")
    if (!ctx) return

    const successful = Number.parseInt(ctx.dataset.successful || "0")
    const failed = Number.parseInt(ctx.dataset.failed || "0")
    const running = Number.parseInt(ctx.dataset.running || "0")

    this.charts.statusDistribution = new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: ["Successful", "Failed", "Running"],
        datasets: [
          {
            data: [successful, failed, running],
            backgroundColor: ["#10b981", "#ef4444", "#f59e0b"],
            borderWidth: 2,
            borderColor: "#ffffff",
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: "bottom",
          },
          title: {
            display: true,
            text: "Execution Status Distribution",
          },
        },
      },
    })
  }

  initPerformanceChart() {
    const ctx = document.getElementById("performance-chart")
    if (!ctx) return

    const data = JSON.parse(ctx.dataset.chartData || "[]")

    this.charts.performance = new Chart(ctx, {
      type: "bar",
      data: {
        labels: data.map((d) => d.name),
        datasets: [
          {
            label: "Avg Execution Time (s)",
            data: data.map((d) => d.avg_time),
            backgroundColor: "#3b82f6",
            borderColor: "#2563eb",
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false,
          },
          title: {
            display: true,
            text: "Top Workflows by Performance",
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Seconds",
            },
          },
        },
      },
    })
  }

  async loadRecentActivity() {
    try {
      const response = await fetch("/workflow/api/dashboard/recent-activity/")
      const data = await response.json()

      this.updateRecentExecutions(data.executions)
      this.updateRecentWorkflows(data.workflows)
    } catch (error) {
      console.error("Failed to load recent activity:", error)
    }
  }

  updateRecentExecutions(executions) {
    const container = document.getElementById("recent-executions")
    if (!container) return

    container.innerHTML = executions
      .map(
        (execution) => `
            <div class="activity-item">
                <div class="activity-icon status-${execution.status}">
                    <i class="fas fa-${this.getExecutionIcon(execution.status)}"></i>
                </div>
                <div class="activity-content">
                    <div class="activity-title">${execution.workflow_name}</div>
                    <div class="activity-meta">
                        ${execution.status} • ${this.formatTimeAgo(execution.started_at)}
                    </div>
                </div>
                <div class="activity-actions">
                    <button class="btn-icon" onclick="viewExecution('${execution.id}')" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>
        `,
      )
      .join("")
  }

  updateRecentWorkflows(workflows) {
    const container = document.getElementById("recent-workflows")
    if (!container) return

    container.innerHTML = workflows
      .map(
        (workflow) => `
            <div class="activity-item">
                <div class="activity-icon status-${workflow.status}">
                    <i class="fas fa-project-diagram"></i>
                </div>
                <div class="activity-content">
                    <div class="activity-title">${workflow.name}</div>
                    <div class="activity-meta">
                        ${workflow.status} • Updated ${this.formatTimeAgo(workflow.updated_at)}
                    </div>
                </div>
                <div class="activity-actions">
                    <button class="btn-icon" onclick="editWorkflow('${workflow.id}')" title="Edit">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-icon" onclick="runWorkflow('${workflow.id}')" title="Run">
                        <i class="fas fa-play"></i>
                    </button>
                </div>
            </div>
        `,
      )
      .join("")
  }

  getExecutionIcon(status) {
    const icons = {
      success: "check-circle",
      failed: "times-circle",
      running: "spinner fa-spin",
      queued: "clock",
      cancelled: "ban",
    }
    return icons[status] || "question-circle"
  }

  formatTimeAgo(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const diffInSeconds = Math.floor((now - date) / 1000)

    if (diffInSeconds < 60) return "just now"
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
    return `${Math.floor(diffInSeconds / 86400)}d ago`
  }

  filterWorkflows(filter) {
    // Update active filter button
    document.querySelectorAll(".filter-btn").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.filter === filter)
    })

    // Apply filter to workflow cards
    document.querySelectorAll(".workflow-card").forEach((card) => {
      const status = card.dataset.status
      const shouldShow = filter === "all" || status === filter
      card.style.display = shouldShow ? "block" : "none"
    })

    // Update counts
    this.updateFilterCounts()
  }

  updateFilterCounts() {
    const filters = ["all", "active", "draft", "inactive"]
    filters.forEach((filter) => {
      const btn = document.querySelector(`[data-filter="${filter}"]`)
      if (!btn) return

      let count
      if (filter === "all") {
        count = document.querySelectorAll(".workflow-card").length
      } else {
        count = document.querySelectorAll(`.workflow-card[data-status="${filter}"]`).length
      }

      const badge = btn.querySelector(".filter-count")
      if (badge) {
        badge.textContent = count
      }
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
          if (card) card.remove()
        } else {
          // Refresh the page to show updated status
          setTimeout(() => window.location.reload(), 1000)
        }
      } else {
        throw new Error(`Failed to ${action} workflow`)
      }
    } catch (error) {
      console.error(`${action} error:`, error)
      this.showNotification(`Failed to ${action} workflow`, "error")
    }
  }

  async refreshDashboard() {
    try {
      this.showLoading("Refreshing dashboard...")

      // Reload recent activity
      await this.loadRecentActivity()

      // Refresh charts data
      const response = await fetch("/workflow/api/dashboard/stats/")
      const stats = await response.json()

      this.updateStats(stats)
      this.updateCharts(stats)

      this.showNotification("Dashboard refreshed", "success")
    } catch (error) {
      console.error("Refresh error:", error)
      this.showNotification("Failed to refresh dashboard", "error")
    } finally {
      this.hideLoading()
    }
  }

  updateStats(stats) {
    // Update stat cards
    const statElements = {
      "total-workflows": stats.total_workflows,
      "active-workflows": stats.active_workflows,
      "total-executions": stats.total_executions,
      "success-rate": `${stats.success_rate}%`,
    }

    Object.entries(statElements).forEach(([id, value]) => {
      const element = document.getElementById(id)
      if (element) {
        element.textContent = value
      }
    })
  }

  updateCharts(stats) {
    // Update execution trend chart
    if (this.charts.executionTrend && stats.daily_executions) {
      this.charts.executionTrend.data.labels = stats.daily_executions.map((d) => d.day)
      this.charts.executionTrend.data.datasets[0].data = stats.daily_executions.map((d) => d.successful)
      this.charts.executionTrend.data.datasets[1].data = stats.daily_executions.map((d) => d.failed)
      this.charts.executionTrend.update()
    }

    // Update status distribution chart
    if (this.charts.statusDistribution) {
      this.charts.statusDistribution.data.datasets[0].data = [
        stats.successful_executions,
        stats.failed_executions,
        stats.running_executions,
      ]
      this.charts.statusDistribution.update()
    }
  }

  setupAutoRefresh() {
    // Auto-refresh every 30 seconds
    setInterval(() => {
      this.loadRecentActivity()
    }, 30000)
  }

  getCsrfToken() {
    return (
      document.querySelector("[name=csrfmiddlewaretoken]")?.value ||
      document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")
    )
  }

  showLoading(message = "Loading...") {
    const overlay = document.getElementById("loading-overlay")
    if (overlay) {
      const spinner = overlay.querySelector(".loading-spinner p")
      if (spinner) spinner.textContent = message
      overlay.style.display = "flex"
    }
  }

  hideLoading() {
    const overlay = document.getElementById("loading-overlay")
    if (overlay) {
      overlay.style.display = "none"
    }
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

// Global functions for template usage
let dashboard // Declare the dashboard variable

function editWorkflow(workflowId) {
  window.location.href = `/workflow/${workflowId}/edit/`
}

function runWorkflow(workflowId) {
  fetch(`/api/workflows/${workflowId}/execute/`, {
    method: "POST",
    headers: {
      "X-CSRFToken": dashboard.getCsrfToken(),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ test: false }),
  })
    .then((response) => response.json())
    .then((data) => {
      dashboard.showNotification("Workflow execution started", "success")
    })
    .catch((error) => {
      console.error("Run error:", error)
      dashboard.showNotification("Failed to run workflow", "error")
    })
}

function viewExecution(executionId) {
  window.location.href = `/workflow/executions/${executionId}/`
}

function viewWorkflow(workflowId) {
  window.location.href = `/workflow/${workflowId}/`
}

// Initialize dashboard when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
  dashboard = new Dashboard() // Assign the new Dashboard instance to the dashboard variable
})
