# Scripts Directory

This directory contains utility scripts for data processing, model execution, and result analysis.

## Organization

### By Function
```
scripts/
├── data_processing/
│   ├── clean_data.py
│   ├── format_conversion.py
│   └── validation.py
├── model_execution/
│   ├── run_all_models.py
│   ├── batch_processing.py
│   └── parameter_sweeps.py
├── analysis/
│   ├── compare_results.py
│   ├── generate_plots.py
│   └── statistical_analysis.py
└── utilities/
    ├── file_helpers.py
    ├── config_loader.py
    └── logging_setup.py
```

## Script Categories

### Data Processing Scripts
- **Data cleaning**: Remove inconsistencies, handle missing values
- **Format conversion**: Convert between file formats
- **Data validation**: Check data quality and constraints
- **Preprocessing**: Prepare data for models

### Model Execution Scripts
- **Batch runners**: Execute multiple model runs
- **Parameter sweeps**: Test different parameter combinations
- **Benchmarking**: Performance testing scripts
- **Automation**: Scheduled or triggered runs

### Analysis Scripts
- **Result processing**: Parse and organize model outputs
- **Visualization**: Generate charts and plots
- **Statistical analysis**: Compute metrics and tests
- **Report generation**: Create summary reports

### Utility Scripts
- **Configuration**: Load and manage settings
- **File operations**: Common file handling tasks
- **Logging**: Set up logging for experiments
- **Helper functions**: Reusable code components

## Script Standards

### Python Script Template
```python
#!/usr/bin/env python3
"""
Script Name: script_name.py
Purpose: Brief description of what this script does
Author: Your Name
Date: YYYY-MM-DD
Usage: python script_name.py [arguments]
"""

import argparse
import logging
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.append(str(project_root))

def setup_logging():
    """Configure logging for the script."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def main():
    """Main function."""
    setup_logging()
    logger = logging.getLogger(__name__)
    
    # Your script logic here
    logger.info("Script started")
    
    # Example: Process arguments
    parser = argparse.ArgumentParser(description='Script description')
    parser.add_argument('--input', required=True, help='Input file path')
    parser.add_argument('--output', required=True, help='Output file path')
    args = parser.parse_args()
    
    # Your processing logic
    
    logger.info("Script completed successfully")

if __name__ == "__main__":
    main()
```

### R Script Template
```r
#!/usr/bin/env Rscript
# Script Name: script_name.R
# Purpose: Brief description
# Author: Your Name
# Date: YYYY-MM-DD

# Load required libraries
library(dplyr)
library(ggplot2)

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Script functions
main <- function() {
  cat("Script started\n")
  
  # Your R code here
  
  cat("Script completed\n")
}

# Run main function
if (!interactive()) {
  main()
}
```

## Common Scripts Examples

### Data Processing Example
```python
# scripts/data_processing/clean_container_data.py
import pandas as pd
import numpy as np

def clean_container_data(input_file, output_file):
    """Clean and validate container data."""
    df = pd.read_csv(input_file)
    
    # Remove duplicates
    df = df.drop_duplicates(subset=['container_id'])
    
    # Handle missing values
    df['weight'].fillna(df['weight'].median(), inplace=True)
    
    # Validate constraints
    df = df[df['weight'] > 0]
    df = df[df['weight'] <= 30000]  # Max container weight
    
    # Save cleaned data
    df.to_csv(output_file, index=False)
    print(f"Cleaned data saved to {output_file}")
    print(f"Original rows: {len(pd.read_csv(input_file))}")
    print(f"Cleaned rows: {len(df)}")
```

### Model Runner Example
```python
# scripts/model_execution/run_monte_carlo.py
import json
import subprocess
import time
from pathlib import Path

def run_monte_carlo_experiment(config_file):
    """Run Monte Carlo model with specified configuration."""
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    start_time = time.time()
    
    # Run the model
    cmd = [
        'python', 
        'models/stochastic/monte_carlo/model.py',
        '--config', config_file,
        '--output', config['output_dir']
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    runtime = time.time() - start_time
    
    # Log results
    log_data = {
        'config': config_file,
        'runtime': runtime,
        'success': result.returncode == 0,
        'output': result.stdout,
        'error': result.stderr
    }
    
    return log_data
```

### Analysis Example
```python
# scripts/analysis/compare_models.py
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def compare_model_performance(results_dir):
    """Compare performance across different models."""
    results = []
    
    # Load results from different models
    for model_dir in Path(results_dir).glob('*/'):
        if model_dir.is_dir():
            result_file = model_dir / 'performance.csv'
            if result_file.exists():
                df = pd.read_csv(result_file)
                df['model'] = model_dir.name
                results.append(df)
    
    # Combine all results
    combined = pd.concat(results, ignore_index=True)
    
    # Generate comparison plots
    plt.figure(figsize=(12, 8))
    
    # Runtime comparison
    plt.subplot(2, 2, 1)
    sns.boxplot(data=combined, x='model', y='runtime')
    plt.title('Runtime Comparison')
    plt.xticks(rotation=45)
    
    # Objective value comparison
    plt.subplot(2, 2, 2)
    sns.boxplot(data=combined, x='model', y='objective')
    plt.title('Objective Value Comparison')
    plt.xticks(rotation=45)
    
    plt.tight_layout()
    plt.savefig('model_comparison.png', dpi=300, bbox_inches='tight')
    
    return combined
```

## Configuration Management

### Config File Example
```json
{
  "experiment_name": "baseline_comparison",
  "models": {
    "monte_carlo": {
      "iterations": 10000,
      "seed": 42,
      "output_frequency": 1000
    },
    "deterministic": {
      "solver": "gurobi",
      "time_limit": 300,
      "gap_tolerance": 0.01
    }
  },
  "data": {
    "input_file": "data/input/containers_baseline.csv",
    "ship_config": "data/input/ship_specifications.json"
  },
  "output": {
    "directory": "results/baseline_experiment",
    "formats": ["csv", "json"],
    "plots": true
  }
}
```

### Config Loader Utility
```python
# scripts/utilities/config_loader.py
import json
import yaml
from pathlib import Path

class ConfigLoader:
    """Utility class for loading configuration files."""
    
    @staticmethod
    def load_json(config_path):
        """Load JSON configuration."""
        with open(config_path, 'r') as f:
            return json.load(f)
    
    @staticmethod
    def load_yaml(config_path):
        """Load YAML configuration."""
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    
    @staticmethod
    def validate_config(config, required_keys):
        """Validate that config contains required keys."""
        missing = [key for key in required_keys if key not in config]
        if missing:
            raise ValueError(f"Missing required config keys: {missing}")
        return True
```

## Best Practices

### Code Quality
- Use meaningful function and variable names
- Add docstrings to all functions
- Follow PEP 8 for Python scripts
- Include error handling
- Use logging instead of print statements

### Script Organization
- One main purpose per script
- Reusable functions in utility modules
- Clear command-line interfaces
- Configurable parameters
- Comprehensive help text

### Documentation
- Include usage examples in docstrings
- Document all parameters and return values
- Provide command-line help
- Include examples in comments

### Testing
- Test scripts with sample data
- Include error handling for edge cases
- Validate inputs and outputs
- Test with different parameter combinations

## Usage Examples

### Running Data Processing
```bash
# Clean container data
python scripts/data_processing/clean_container_data.py \
    --input data/input/raw_containers.csv \
    --output data/output/clean_containers.csv

# Convert format
python scripts/data_processing/format_conversion.py \
    --input data/input/data.xlsx \
    --output data/output/data.csv \
    --format csv
```

### Running Models
```bash
# Single model run
python scripts/model_execution/run_monte_carlo.py \
    --config configs/baseline.json

# Batch processing
python scripts/model_execution/batch_processing.py \
    --config-dir configs/experiments/ \
    --output-dir results/batch_run/
```

### Analysis
```bash
# Generate comparison plots
python scripts/analysis/compare_models.py \
    --results-dir results/ \
    --output comparison_report.pdf

# Statistical analysis
python scripts/analysis/statistical_analysis.py \
    --data results/combined_results.csv \
    --tests t-test,anova
```

Remember: Make scripts executable and test them thoroughly before sharing!