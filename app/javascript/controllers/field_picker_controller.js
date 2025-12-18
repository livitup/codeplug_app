import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="field-picker"
export default class extends Controller {
  static targets = [
    "sourceFields",
    "layoutBuilder",
    "layoutDefinition",
    "csvPreview",
    "jsonPreview",
    "searchInput"
  ]

  static values = {
    fields: Array
  }

  connect() {
    this.initializeSortable()
    this.renderSourceFields()
    this.loadExistingLayout()
    this.updatePreview()
  }

  initializeSortable() {
    // Make the layout builder sortable and droppable
    this.layoutSortable = Sortable.create(this.layoutBuilderTarget, {
      animation: 150,
      handle: ".drag-handle",
      group: {
        name: "layout",
        pull: false,
        put: ["source"]
      },
      onAdd: this.handleFieldAdded.bind(this),
      onEnd: this.handleReorder.bind(this)
    })
  }

  renderSourceFields() {
    const groups = this.fieldsValue
    let html = ""

    groups.forEach(group => {
      html += `
        <div class="field-group mb-3">
          <h6 class="field-group-header text-muted mb-2">${group.name}</h6>
          <div class="field-list" data-group="${group.name}">
      `

      group.fields.forEach(field => {
        html += this.createSourceFieldHtml(field, group.name)
      })

      html += `
          </div>
        </div>
      `
    })

    this.sourceFieldsTarget.innerHTML = html

    // Make each field group draggable
    this.sourceFieldsTarget.querySelectorAll(".field-list").forEach(list => {
      Sortable.create(list, {
        animation: 150,
        sort: false,
        group: {
          name: "source",
          pull: "clone",
          put: false
        },
        onStart: (evt) => {
          evt.item.classList.add("dragging")
        },
        onEnd: (evt) => {
          evt.item.classList.remove("dragging")
        }
      })
    })
  }

  createSourceFieldHtml(field, groupName) {
    return `
      <div class="source-field list-group-item list-group-item-action py-2 px-3"
           data-label="${field.label}"
           data-maps-to="${field.maps_to}"
           data-group="${groupName}">
        <i class="bi bi-grip-vertical me-2 text-muted"></i>
        <span class="field-label">${field.label}</span>
        <small class="text-muted ms-2">${field.maps_to}</small>
      </div>
    `
  }

  loadExistingLayout() {
    const existingJson = this.layoutDefinitionTarget.value.trim()
    if (!existingJson) return

    try {
      const layout = JSON.parse(existingJson)
      if (layout.columns && Array.isArray(layout.columns)) {
        layout.columns.forEach(column => {
          this.addFieldToLayout(column.header, column.maps_to)
        })
      }
    } catch (e) {
      console.error("Failed to parse existing layout:", e)
    }
  }

  handleFieldAdded(event) {
    const item = event.item
    const label = item.dataset.label
    const mapsTo = item.dataset.mapsTo

    // Replace the cloned source field with a layout field
    const layoutField = this.createLayoutFieldElement(label, mapsTo)
    item.replaceWith(layoutField)

    this.updatePreview()
  }

  handleReorder() {
    this.updatePreview()
  }

  addFieldToLayout(header, mapsTo) {
    const layoutField = this.createLayoutFieldElement(header, mapsTo)
    this.layoutBuilderTarget.appendChild(layoutField)
  }

  createLayoutFieldElement(header, mapsTo) {
    const div = document.createElement("div")
    div.className = "layout-field list-group-item d-flex align-items-center py-2"
    div.dataset.mapsTo = mapsTo

    div.innerHTML = `
      <span class="drag-handle me-2 text-muted" style="cursor: grab;">
        <i class="bi bi-grip-vertical"></i>
      </span>
      <input type="text"
             class="form-control form-control-sm me-2 header-input"
             value="${this.escapeHtml(header)}"
             placeholder="CSV Header"
             data-action="input->field-picker#updatePreview">
      <small class="text-muted me-auto">${mapsTo}</small>
      <button type="button"
              class="btn btn-sm btn-outline-danger"
              data-action="click->field-picker#removeField">
        <i class="bi bi-x-lg"></i>
      </button>
    `

    return div
  }

  removeField(event) {
    const field = event.target.closest(".layout-field")
    if (field) {
      field.remove()
      this.updatePreview()
    }
  }

  updatePreview() {
    const columns = this.getColumns()

    // Update hidden input with JSON
    this.layoutDefinitionTarget.value = JSON.stringify({ columns }, null, 2)

    // Update CSV preview
    if (this.hasCsvPreviewTarget) {
      const headers = columns.map(col => {
        const header = col.header
        return header.includes(",") ? `"${header}"` : header
      })
      this.csvPreviewTarget.textContent = headers.join(",")
    }

    // Update JSON preview
    if (this.hasJsonPreviewTarget) {
      this.jsonPreviewTarget.textContent = JSON.stringify({ columns }, null, 2)
    }

    // Check for duplicates and show warnings
    this.checkDuplicates(columns)
  }

  getColumns() {
    const columns = []
    this.layoutBuilderTarget.querySelectorAll(".layout-field").forEach(field => {
      const headerInput = field.querySelector(".header-input")
      columns.push({
        header: headerInput ? headerInput.value : "",
        maps_to: field.dataset.mapsTo
      })
    })
    return columns
  }

  checkDuplicates(columns) {
    const headerCounts = {}
    columns.forEach(col => {
      const header = col.header.toLowerCase()
      headerCounts[header] = (headerCounts[header] || 0) + 1
    })

    // Clear previous warnings
    this.layoutBuilderTarget.querySelectorAll(".layout-field").forEach(field => {
      field.classList.remove("border-warning")
      const existingWarning = field.querySelector(".duplicate-warning")
      if (existingWarning) existingWarning.remove()
    })

    // Add warnings for duplicates
    this.layoutBuilderTarget.querySelectorAll(".layout-field").forEach(field => {
      const headerInput = field.querySelector(".header-input")
      if (headerInput) {
        const header = headerInput.value.toLowerCase()
        if (headerCounts[header] > 1) {
          field.classList.add("border-warning")
          const warning = document.createElement("span")
          warning.className = "duplicate-warning badge bg-warning text-dark ms-2 me-2"
          warning.textContent = "Duplicate"
          headerInput.after(warning)
        }
      }
    })
  }

  search(event) {
    const query = event.target.value.toLowerCase()

    this.sourceFieldsTarget.querySelectorAll(".source-field").forEach(field => {
      const label = field.dataset.label.toLowerCase()
      const mapsTo = field.dataset.mapsTo.toLowerCase()

      if (label.includes(query) || mapsTo.includes(query)) {
        field.style.display = ""
      } else {
        field.style.display = "none"
      }
    })

    // Show/hide group headers based on visible fields
    this.sourceFieldsTarget.querySelectorAll(".field-group").forEach(group => {
      const visibleFields = group.querySelectorAll(".source-field:not([style*='display: none'])")
      const header = group.querySelector(".field-group-header")
      if (header) {
        header.style.display = visibleFields.length > 0 ? "" : "none"
      }
    })
  }

  toggleJsonPreview(event) {
    const preview = this.jsonPreviewTarget.closest(".json-preview-container")
    if (preview) {
      preview.classList.toggle("d-none")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    if (this.layoutSortable) {
      this.layoutSortable.destroy()
    }
  }
}
