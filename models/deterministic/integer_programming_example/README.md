# Integer Programming Stowage Model Example

**Author:** [Your Name]  
**Date:** 2024-01-15  
**Version:** 1.0  

## Overview

This is an example integer programming model for deterministic container stowage optimization. It demonstrates the basic structure for deterministic models in this project.

## Problem Description

The model optimizes container placement considering:
- Container-to-slot assignments
- Weight distribution constraints
- Stability requirements
- Access and retrieval ordering

## Mathematical Formulation

### Decision Variables
- `x[i,j]` = 1 if container i is assigned to slot j, 0 otherwise

### Objective Function
Minimize total handling cost:
```
minimize Σ(i,j) cost[i,j] * x[i,j]
```

### Constraints
1. **Assignment**: Each container assigned to exactly one slot
2. **Capacity**: Each slot holds at most one container
3. **Weight**: Total weight per bay within limits
4. **Stability**: Center of gravity constraints

## Files

- `model.py` - Main IP model implementation
- `config.json` - Model parameters
- `example_run.py` - Example usage
- `data_generator.py` - Generate test instances

## Dependencies

```bash
pip install numpy pandas cvxpy gurobipy  # or pulp for open-source
```

## Usage

### Basic Usage
```python
from ip_model import IntegerProgrammingStowage

# Load data and configuration
model = IntegerProgrammingStowage('config.json')
model.load_data('data/containers.csv', 'data/ship_config.json')

# Solve
solution = model.solve()

# Results
print(f"Optimal objective: {solution.objective}")
print(f"Runtime: {solution.runtime:.2f} seconds")
```

### Command Line
```bash
python example_run.py --config config.json --data data/ --output results/
```

## Configuration

The `config.json` file contains:
```json
{
  "solver": {
    "name": "GUROBI",
    "time_limit": 300,
    "gap_tolerance": 0.01,
    "threads": 4
  },
  "model": {
    "include_stability": true,
    "weight_tolerance": 0.05
  }
}
```

## Results

The model produces:
- **Optimal assignment**: Container-to-slot mapping
- **Objective value**: Total cost
- **Solution statistics**: Gap, runtime, iterations
- **Validation**: Constraint satisfaction check

## Performance

Typical performance on standard instances:
- Small (50 containers): < 1 second
- Medium (200 containers): < 30 seconds  
- Large (500 containers): < 300 seconds

## Validation

Model validated using:
- Known optimal solutions from literature
- Constraint satisfaction verification
- Sensitivity analysis on parameters

## Limitations

- Assumes static container set
- Does not consider dynamic arrivals
- Simplified stability constraints
- Single objective optimization

## Extensions

Possible extensions:
1. Multi-objective optimization
2. Robust optimization variants
3. Time-indexed formulations
4. Integration with crane scheduling

## References

- Brown, P. (2023). "Integer Programming for Container Stowage." Maritime Operations Research.
- Davis, K. (2022). "Optimization Models in Port Logistics." Transportation Science.