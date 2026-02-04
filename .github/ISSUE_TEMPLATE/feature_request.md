---
name: Feature request
about: Suggest an idea for this project.
title: ''
labels: ''
assignees: ''

---

name: 🚀 Feature Request
description: Suggest an idea for this project.
title: "[Feature]: "
labels: ["enhancement"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for suggesting a new feature! Please explain *why* this is needed.
  - type: textarea
    id: problem
    attributes:
      label: Is your feature request related to a problem?
      description: A clear and concise description of what the problem is.
      placeholder: "I'm always frustrated when I have to manually update version numbers..."
    validations:
      required: false
  - type: textarea
    id: solution
    attributes:
      label: Describe the solution you'd like
      description: A clear description of what you want to happen.
    validations:
      required: true
  - type: textarea
    id: impact
    attributes:
      label: Architectural Impact
      description: Does this feature require breaking changes or new dependencies?
      placeholder: "This requires adding 'auto_route' which might conflict with..."
    validations:
      required: false
