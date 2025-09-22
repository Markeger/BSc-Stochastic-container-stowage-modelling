# Deterministic Models

This directory contains deterministic models for container stowage optimization.

## Model Types

### Mathematical Programming
- Linear programming (LP)
- Integer programming (IP)  
- Mixed-integer programming (MIP)
- Constraint programming (CP)

### Heuristic Approaches
- Greedy algorithms
- Local search methods
- Metaheuristics (if deterministic variants)

### Exact Algorithms
- Branch and bound
- Dynamic programming
- Cutting plane methods

## Adding a New Deterministic Model

1. Create a new folder with a descriptive name:
   ```
   models/deterministic/your_model_name/
   ```

2. Follow the same structure as stochastic models:
   ```
   integer_programming_stowage/
   ├── README.md
   ├── ip_model.py (or .mod, .lp, etc.)
   ├── solver_config.json
   ├── example_run.py
   └── data_preprocessing.py
   ```

## Model Documentation Template

Each model should include:
- **Purpose**: What specific problem variant?
- **Formulation**: Mathematical model description
- **Solution Method**: Algorithm or solver used
- **Input Format**: Required data structure
- **Output Format**: Solution representation
- **Complexity**: Time/space complexity notes
- **Usage**: Step-by-step instructions

## Solver Integration

Common solvers that might be used:
- **Python**: PuLP, Gurobi, CPLEX, OR-Tools
- **R**: lpSolve, Rglpk, gurobi
- **MATLAB**: Optimization Toolbox, intlinprog
- **Julia**: JuMP.jl

Document which solver your model requires and how to install it.

## Best Practices

- Clearly state problem assumptions
- Include model validation tests
- Compare with known optimal solutions when possible
- Document computational requirements
- Include runtime analysis
- Provide performance benchmarks