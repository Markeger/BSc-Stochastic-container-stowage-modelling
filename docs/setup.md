# Environment Setup Guide

This guide will help you set up your development environment for the container stowage modelling project.

## Prerequisites

### Required Software
- **Git** - Version control
- **Python 3.8+** - Primary programming language
- **R** (optional) - For statistical analysis
- **MATLAB** (optional) - For specific models

### Recommended Tools
- **VS Code** or **PyCharm** - Code editor/IDE
- **Jupyter Notebook** - Interactive analysis
- **Git client** (GitKraken, SourceTree, or command line)

## Python Environment Setup

### Option 1: Using Conda (Recommended)
```bash
# Install Miniconda or Anaconda
# Create project environment
conda create -n container-stowage python=3.9
conda activate container-stowage

# Install common packages
conda install numpy pandas matplotlib seaborn jupyter
conda install scikit-learn scipy statsmodels
pip install cvxpy pulp  # Optimization libraries
```

### Option 2: Using pip and venv
```bash
# Create virtual environment
python -m venv container-stowage-env

# Activate environment
# On Windows:
container-stowage-env\Scripts\activate
# On macOS/Linux:
source container-stowage-env/bin/activate

# Install packages
pip install -r requirements.txt
```

### Requirements File
Create `requirements.txt` with:
```
numpy>=1.21.0
pandas>=1.3.0
matplotlib>=3.4.0
seaborn>=0.11.0
jupyter>=1.0.0
scikit-learn>=1.0.0
scipy>=1.7.0
cvxpy>=1.1.0
pulp>=2.5.0
```

## R Environment Setup (Optional)

### Install R Packages
```r
# Essential packages
install.packages(c("dplyr", "ggplot2", "readr", "tidyr"))

# Optimization packages
install.packages(c("lpSolve", "Rglpk", "ROI"))

# If you have Gurobi license
install.packages("gurobi", repos="http://www.gurobi.com")
```

## MATLAB Setup (Optional)

### Required Toolboxes
- Optimization Toolbox
- Statistics and Machine Learning Toolbox (optional)
- Global Optimization Toolbox (optional)

## Verification

### Test Python Setup
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import cvxpy as cp

print("All packages imported successfully!")

# Test optimization
x = cp.Variable()
problem = cp.Problem(cp.Minimize(x**2), [x >= 1])
problem.solve()
print(f"Optimization test result: {x.value}")
```

### Test Jupyter
```bash
jupyter notebook
# Should open browser with notebook interface
```

## Git Configuration

### Initial Setup
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Clone Repository
```bash
git clone https://github.com/Markeger/BSc---Stochastic-container-stowage-modelling.git
cd BSc---Stochastic-container-stowage-modelling
```

## IDE Configuration

### VS Code Extensions
- Python
- Jupyter
- GitLens
- Markdown All in One
- R (if using R)

### PyCharm Setup
- Enable Scientific Mode
- Configure Python interpreter
- Install VCS plugins

## Troubleshooting

### Common Issues

#### Import Errors
```bash
# Make sure environment is activated
conda activate container-stowage
# or
source container-stowage-env/bin/activate

# Reinstall problematic package
pip install --force-reinstall package-name
```

#### Permission Issues (Windows)
```bash
# Run as administrator or use:
python -m pip install --user package-name
```

#### CVXPY Solver Issues
```bash
# Install additional solvers
pip install cvxopt ecos scs
```

### Getting Help
1. Check package documentation
2. Search Stack Overflow
3. Ask team members
4. Create an issue in the repository

## Performance Optimization

### For Large Datasets
- Use `pandas` with `dtype` specifications
- Consider `dask` for very large data
- Use `numba` for numerical computations

### For Optimization Models
- Install commercial solvers (Gurobi, CPLEX) if available
- Use appropriate solver parameters
- Consider parallel processing

## Keeping Environment Updated

### Regular Updates
```bash
# Update conda environment
conda update --all

# Update pip packages
pip list --outdated
pip install --upgrade package-name
```

### Environment Backup
```bash
# Export environment
conda env export > environment.yml
# or
pip freeze > requirements.txt
```

## Next Steps

After setup:
1. Read the main README.md
2. Explore the repository structure
3. Run example notebooks
4. Start with a simple model
5. Ask questions if stuck!