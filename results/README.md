# Results Directory

This directory contains outputs from models, analyses, and experiments.

## Organization

### By Model Type
```
results/
├── stochastic/
│   ├── monte_carlo/
│   ├── stochastic_programming/
│   └── machine_learning/
├── deterministic/
│   ├── linear_programming/
│   ├── integer_programming/
│   └── heuristics/
├── comparisons/
│   └── model_comparison_studies/
└── reports/
    ├── figures/
    ├── tables/
    └── summaries/
```

### By Date/Experiment
```
results/
├── 2024-01/
├── 2024-02/
└── experiment_name_YYYY-MM-DD/
```

## File Naming Convention

Use descriptive, systematic naming:
```
YYYY-MM-DD_model-name_experiment-type_version.extension
```

Examples:
- `2024-01-15_monte-carlo_baseline_v1.csv`
- `2024-01-20_ip-model_sensitivity-analysis_final.xlsx`
- `2024-02-01_comparison_all-models_summary.pdf`

## Result Types

### Model Outputs
- **Solution files**: Optimal/best solutions found
- **Performance metrics**: Runtime, objective values, convergence
- **Log files**: Detailed execution logs
- **Configuration**: Parameters used for the run

### Analysis Results
- **Statistical summaries**: Descriptive statistics
- **Visualizations**: Charts, plots, diagrams
- **Comparison tables**: Model performance comparisons
- **Sensitivity analysis**: Parameter variation studies

### Reports
- **Summary reports**: High-level findings
- **Technical reports**: Detailed methodology and results
- **Figures**: Publication-ready graphics
- **Tables**: Formatted result tables

## Documentation Requirements

### For Each Result Set
Create a companion file documenting:
- **Purpose**: What experiment was conducted?
- **Model used**: Which model and version?
- **Parameters**: All parameter settings
- **Data**: Input data used
- **Date/Time**: When was it generated?
- **Author**: Who ran the experiment?
- **Interpretation**: What do the results mean?

### Example Result Documentation
Create `experiment_name_NOTES.md`:
```markdown
# Experiment: Monte Carlo Baseline Study

**Date:** 2024-01-15
**Author:** Team Member Name
**Model:** Monte Carlo Stowage Model v1.0

## Purpose
Initial baseline runs to establish model behavior and performance.

## Configuration
- Simulation runs: 10,000
- Containers: 100-500
- Ship type: Medium container vessel
- Uncertainty: ±10% weight variation

## Files Generated
- `monte-carlo_baseline_solutions.csv` - Best solutions found
- `monte-carlo_baseline_stats.json` - Performance statistics
- `monte-carlo_baseline_plots.png` - Convergence plots

## Key Findings
- Average runtime: 45 seconds
- Objective improvement: 12% over deterministic
- Solution quality stable after 5,000 iterations

## Next Steps
- Test with larger container sets
- Implement variance reduction techniques
```

## Data Formats

### Preferred Formats
- **CSV**: Tabular data, widely compatible
- **JSON**: Structured data, configuration files
- **Excel**: Complex tables with multiple sheets
- **PNG/PDF**: Figures and visualizations
- **HDF5**: Large numerical datasets

### Avoid
- Proprietary formats when possible
- Uncompressed large files
- Files without metadata
- Non-descriptive filenames

## Version Control

### What to Track
- Final results and summaries
- Important intermediate results
- Configuration files
- Analysis scripts

### What NOT to Track
- Temporary files
- Very large datasets (>100MB)
- Logs from failed runs
- Intermediate debugging outputs

Use `.gitignore` patterns:
```
results/temp/
*.log
*_debug_*
results/**/cache/
```

## Sharing Results

### Internal Sharing
- Organize results clearly
- Include documentation
- Use relative paths in analysis scripts
- Create summary presentations

### External Sharing
- Remove sensitive information
- Use standard formats
- Include methodology description
- Provide contact information

## Archiving

### Long-term Storage
- Archive old results periodically
- Maintain important benchmarks
- Document archival decisions
- Keep metadata accessible

### Cleanup
- Remove temporary files regularly
- Archive or delete outdated results
- Maintain reasonable repository size
- Keep only significant results

## Analysis Templates

### Performance Comparison Table
```markdown
| Model | Runtime (s) | Objective | Gap (%) | Memory (MB) |
|-------|-------------|-----------|---------|-------------|
| LP    | 12.3        | 1,245     | 0.0%    | 156         |
| MIP   | 234.7       | 1,189     | 4.5%    | 892         |
| MC    | 45.2        | 1,201     | 3.5%    | 234         |
```

### Statistical Summary
```json
{
  "experiment": "baseline_comparison",
  "date": "2024-01-15",
  "model": "monte_carlo_v1",
  "statistics": {
    "mean_objective": 1201.5,
    "std_objective": 23.4,
    "min_objective": 1167.8,
    "max_objective": 1234.1,
    "runtime_mean": 45.2,
    "runtime_std": 8.7
  }
}
```

## Best Practices

1. **Document immediately** - Don't wait to document results
2. **Use version control** - Track important results
3. **Be systematic** - Follow naming conventions
4. **Include metadata** - Always document parameters
5. **Archive regularly** - Don't let results accumulate indefinitely
6. **Share appropriately** - Make results accessible to team
7. **Validate results** - Check for reasonableness
8. **Backup important results** - Don't lose key findings