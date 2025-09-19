/**
 * Main Workflow Editor - Integrates all components
 */
class WorkflowEditorMain {
  constructor(options = {}) {
    this.options = {
      workflowId: null,
      workflowData: { nodes: [], connections: [] },
      csrfToken: null,
      apiBaseUrl: "/api/workflows/",
      autoSave: true,
      ...options,
    }

    // Use the main WorkflowEditor
    this.editor = new WorkflowEditor(this.options)

    // State
    this.isDirty = false
    this.isLoading = false
    this.currentWorkflow = null

    this.init()
  }

  init() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Back button
    document.getElementById("back-btn")?.addEventListener("click", () => {
      if (this.editor.isDirty) {
        if (confirm("You have unsaved changes. Are you sure you want to leave?")) {
          this.goBack()
        }
      } else {
        this.goBack()
      }
    })

    // Keyboard shortcuts
    document.addEventListener("keydown", (e) => {
      if (e.ctrlKey || e.metaKey) {
        switch (e.key) {
          case "s":
            e.preventDefault()
            this.editor.saveWorkflow()
            break
          case "Enter":
            if (e.shiftKey) {
              e.preventDefault()
              this.editor.testWorkflow()
            }
            break
        }
      }
    })

    // Prevent page unload with unsaved changes
    window.addEventListener("beforeunload", (e) => {
      if (this.editor.isDirty) {
        e.preventDefault()
        e.returnValue = "You have unsaved changes. Are you sure you want to leave?"
        return e.returnValue
      }
    })
  }

  // Navigation
  goBack() {
    if (this.options.workflowId) {
      window.location.href = `/workflow/${this.options.workflowId}/`
    } else {
      window.location.href = "/workflow/"
    }
  }
}

// Export for global use
window.WorkflowEditorMain = WorkflowEditorMain
