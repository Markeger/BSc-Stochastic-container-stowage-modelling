# BSc - Stochastic Container Stowage Modelling

Welcome to our Bachelor's project repository for **Stochastic Container Stowage Modelling and Optimization**! 

This repository is designed to be simple and easy to use for sharing data, models, and results among team members.

## 📁 Repository Structure

```
BSc---Stochastic-container-stowage-modelling/
├── models/
│   ├── stochastic/          # Stochastic models and algorithms
│   └── deterministic/       # Deterministic models (2-3 models)
├── data/
│   ├── input/              # Raw input data files
│   └── output/             # Processed data files
├── notebooks/              # Jupyter notebooks for analysis and exploration
├── scripts/                # Utility scripts and data processing
├── docs/                   # Project documentation
├── results/                # Model outputs and analysis results
├── README.md              # This file
└── .gitignore             # Git ignore rules
```

## 🚀 Getting Started

### For New Team Members

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Markeger/BSc---Stochastic-container-stowage-modelling.git
   cd BSc---Stochastic-container-stowage-modelling
   ```

2. **Set up your environment:**
   - Install required software (Python, R, MATLAB, etc.)
   - See `docs/setup.md` for detailed instructions

3. **Before making changes:**
   - Create a new branch: `git checkout -b your-feature-branch`
   - Work on your changes
   - Commit and push your branch
   - Create a pull request

## 📊 Working with Models

### Stochastic Models
- Place all stochastic models in `models/stochastic/`
- Each model should have its own folder with a descriptive name
- Include a README.md in each model folder explaining the approach

### Deterministic Models  
- Place deterministic models in `models/deterministic/`
- Follow the same structure as stochastic models

### Example Model Structure
```
models/stochastic/monte_carlo_stowage/
├── README.md              # Model description and usage
├── model.py              # Main model implementation
├── config.json           # Model parameters
└── example_run.py        # Example of how to run the model
```

## 📈 Data Management

### Input Data
- Place raw data files in `data/input/`
- Use descriptive filenames
- Document data sources in `docs/data_sources.md`

### Output Data
- Store processed/cleaned data in `data/output/`
- Include metadata about processing steps

## 📝 Documentation

- Keep project documentation in `docs/`
- Document your models thoroughly
- Update this README when adding new components

## 🤝 Collaboration Guidelines

1. **Always work on a branch** - never commit directly to main
2. **Write clear commit messages** - describe what you changed and why
3. **Update documentation** - keep README files current
4. **Test your code** - make sure models run before committing
5. **Use descriptive names** - for files, folders, and variables

## 📋 Common Tasks

### Adding a New Model
1. Create folder in appropriate directory (`models/stochastic/` or `models/deterministic/`)
2. Add model files and documentation
3. Update this README if needed
4. Test the model
5. Commit and create pull request

### Sharing Results
1. Save outputs in `results/` with descriptive names
2. Include date and model version in filename
3. Add summary in `results/README.md`

### Adding Data
1. Place in appropriate `data/` subfolder
2. Document source and format
3. Update `docs/data_sources.md`

## 🆘 Need Help?

- Check the `docs/` folder for detailed guides
- Ask team members via issues or discussions
- Keep it simple - this structure is designed to be intuitive!

## 📞 Contact

For questions about this repository structure or the project, contact the team leads.

---
*This repository structure is designed to be simple and grow with your project. Feel free to suggest improvements!*
