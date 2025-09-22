# Notebooks Directory

This directory contains Jupyter notebooks for data analysis, model exploration, and result visualization.

## Organization

Organize notebooks by purpose and keep them focused:

### `/exploratory/` - Data Exploration
- Initial data analysis
- Data quality assessment
- Pattern identification
- Statistical summaries

### `/modeling/` - Model Development
- Model prototyping
- Parameter tuning
- Algorithm comparison
- Validation studies

### `/results/` - Result Analysis
- Performance evaluation
- Visualization of results
- Comparative analysis
- Report generation

## Notebook Naming Convention

Use descriptive, sequential naming:
```
NN_purpose_description_date.ipynb
```

Examples:
- `01_data_exploration_container_specs_2024-01.ipynb`
- `02_stochastic_model_monte_carlo_initial.ipynb`
- `03_results_comparison_deterministic_vs_stochastic.ipynb`

## Notebook Structure

### Standard Template
Each notebook should include:

1. **Title and Overview**
   ```markdown
   # Notebook Title
   **Date:** YYYY-MM-DD
   **Author:** Your Name
   **Purpose:** Brief description
   ```

2. **Imports and Setup**
   ```python
   import pandas as pd
   import numpy as np
   import matplotlib.pyplot as plt
   # ... other imports
   
   # Configuration
   plt.style.use('seaborn')
   pd.set_option('display.max_columns', None)
   ```

3. **Data Loading**
   ```python
   # Load data with clear documentation
   data = pd.read_csv('../data/input/filename.csv')
   print(f"Data shape: {data.shape}")
   data.head()
   ```

4. **Analysis Sections**
   - Clear markdown headers
   - Explanatory text
   - Well-commented code
   - Meaningful visualizations

5. **Conclusions**
   ```markdown
   ## Key Findings
   - Finding 1
   - Finding 2
   
   ## Next Steps
   - Action 1
   - Action 2
   ```

## Best Practices

### Code Quality
- Use meaningful variable names
- Add comments for complex logic
- Follow PEP 8 style guide
- Keep cells focused and short

### Documentation
- Explain your thinking process
- Document assumptions
- Describe methodology
- Interpret results clearly

### Reproducibility
- Set random seeds where applicable
- Use relative paths for data
- List all dependencies
- Include environment information

### Visualization
- Use clear, informative titles
- Label axes properly
- Choose appropriate chart types
- Include legends when needed
- Use consistent color schemes

## Environment Setup

### Required Packages
Common packages for this project:
```python
# Data manipulation
pandas
numpy
scipy

# Visualization
matplotlib
seaborn
plotly

# Machine learning
scikit-learn
tensorflow/pytorch (if needed)

# Optimization
cvxpy
pulp
gurobipy (if available)

# Statistical analysis
statsmodels
```

### Installing Packages
```bash
pip install -r requirements.txt
# or
conda env create -f environment.yml
```

## Version Control with Notebooks

### Before Committing
1. Clear all outputs: `Cell > All Output > Clear`
2. Restart kernel to ensure clean state
3. Run all cells to verify reproducibility
4. Check file size (avoid large outputs)

### Alternatives
- Use `.py` files for stable code
- Convert notebooks: `jupyter nbconvert --to python notebook.ipynb`
- Use version control tools like `nbstripout`

## Sharing Results

### Export Options
- **HTML**: For sharing with non-technical stakeholders
- **PDF**: For formal reports
- **Python**: For code reuse
- **Slides**: For presentations

### Commands
```bash
jupyter nbconvert --to html notebook.ipynb
jupyter nbconvert --to pdf notebook.ipynb
jupyter nbconvert --to slides notebook.ipynb
```