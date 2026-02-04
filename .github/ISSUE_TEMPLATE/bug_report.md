---
name: Bug report
about: Create a report to help us improve the architecture.
title: ''
labels: ''
assignees: ''

---

name: 🐛 Bug Report
description: Create a report to help us improve the architecture.
title: "[Bug]: "
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  - type: textarea
    id: description
    attributes:
      label: Describe the bug
      description: A clear and concise description of what the bug is.
      placeholder: "I found an issue in the Flavor configuration logic..."
    validations:
      required: true
  - type: textarea
    id: reproduce
    attributes:
      label: Steps to Reproduce
      description: How can we reproduce this issue?
      placeholder: |
        1. Go to '...'
        2. Run command '...'
        3. See error
    validations:
      required: true
  - type: textarea
    id: environment
    attributes:
      label: Environment Details
      description: Crucial for debugging.
      value: |
        - Flutter Version: 
        - Device / Emulator: 
        - OS Version: 
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Logs / StackTrace
      render: shell
