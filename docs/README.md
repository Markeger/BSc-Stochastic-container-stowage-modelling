# Documentation

This directory contains all project documentation beyond code comments.

## Documentation Structure

### Project Documentation
- `project_overview.md` - High-level project description
- `requirements.md` - Functional and technical requirements
- `methodology.md` - Research approach and methods
- `timeline.md` - Project milestones and deadlines

### Technical Documentation
- `setup.md` - Environment setup instructions
- `data_sources.md` - Data sources and descriptions
- `model_comparison.md` - Comparison of different approaches
- `api_reference.md` - Code interfaces and functions

### Reports and Papers
- `interim_reports/` - Progress reports
- `final_report/` - Bachelor thesis draft
- `presentations/` - Slides and presentation materials
- `references/` - Literature and citations

## Writing Guidelines

### Markdown Standards
- Use clear, descriptive headers
- Include table of contents for long documents
- Use code blocks for technical content
- Add images and diagrams when helpful

### Technical Writing Tips
1. **Be clear and concise**
2. **Define acronyms and technical terms**
3. **Use active voice**
4. **Include examples**
5. **Structure content logically**

### Formatting Examples

#### Headers
```markdown
# Main Title
## Section
### Subsection
#### Detail Level
```

#### Code References
```markdown
See the model implementation in `models/stochastic/monte_carlo/model.py`
```

#### Mathematical Notation
Use LaTeX for equations:
```markdown
The objective function is:
$$\min \sum_{i=1}^{n} c_i x_i$$
```

#### Tables
```markdown
| Model Type | Complexity | Runtime |
|------------|------------|---------|
| LP         | Low        | Fast    |
| MIP        | High       | Slow    |
```

## Document Templates

### Model Documentation Template
```markdown
# Model Name

## Overview
Brief description of the model and its purpose.

## Problem Formulation
Mathematical formulation or algorithmic description.

## Implementation
- Language: Python/R/MATLAB
- Dependencies: List required packages
- Files: List of implementation files

## Usage
Step-by-step instructions for running the model.

## Results
Expected outputs and interpretation.

## Validation
How the model was tested and validated.

## Limitations
Known constraints and assumptions.

## References
Relevant literature and sources.
```

### Progress Report Template
```markdown
# Progress Report - Week XX

## Completed Tasks
- Task 1: Description and outcomes
- Task 2: Description and outcomes

## Current Work
- Ongoing activity 1
- Ongoing activity 2

## Challenges
- Challenge 1 and proposed solution
- Challenge 2 and proposed solution

## Next Steps
- Planned activity 1
- Planned activity 2

## Timeline Update
Any changes to project timeline.
```

## Version Control for Documents

### File Naming
- Use versions: `v1.0`, `v1.1`, `final`
- Include dates: `2024-01-15`
- Be descriptive: `interim_report_models_comparison_v2.md`

### Collaborative Writing
1. Use branches for major edits
2. Track changes in commit messages
3. Review documents before merging
4. Keep a changelog for important documents

## Useful Tools

### Markdown Editors
- **VS Code** with Markdown extensions
- **Typora** for WYSIWYG editing
- **Mark Text** for real-time preview
- **GitHub web interface** for quick edits

### Reference Management
- **Zotero** for academic citations
- **Mendeley** for paper organization
- **BibTeX** for LaTeX integration

### Diagramming
- **Mermaid** for flowcharts and diagrams
- **Draw.io** for complex diagrams
- **PlantUML** for UML diagrams
- **TikZ** for mathematical diagrams

## Best Practices

### Regular Updates
- Update documentation as code changes
- Keep README files current
- Review and revise periodically
- Archive outdated versions

### Accessibility
- Use clear language
- Provide context and background
- Include glossary for technical terms
- Add alt text for images

### Quality Control
- Spell check all documents
- Review for clarity and completeness
- Ensure consistency in terminology
- Get feedback from team members