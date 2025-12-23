# Contributing to the Project

Welcome! This guide will help you contribute effectively to our bachelor's project on stochastic container stowage modelling.

## Getting Started

### First Time Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/Markeger/BSc---Stochastic-container-stowage-modelling.git
   cd BSc---Stochastic-container-stowage-modelling
   ```

2. **Set up your environment**
   - Follow the setup guide in `docs/setup.md`
   - Install required dependencies
   - Test your installation

3. **Understand the project structure**
   - Read the main README.md
   - Browse the directory structure
   - Look at example models

## Workflow

### Before Starting Work

1. **Check existing issues and discussions**
   - Look for related work
   - Avoid duplicating efforts
   - Ask questions if unsure

2. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b model/your-model-name
   # or  
   git checkout -b bugfix/issue-description
   ```

3. **Plan your work**
   - Break down into small tasks
   - Estimate time requirements
   - Consider dependencies

### While Working

1. **Follow the project structure**
   - Put files in appropriate directories
   - Follow naming conventions
   - Include proper documentation

2. **Write good code**
   - Use clear, descriptive names
   - Add comments for complex logic
   - Follow language best practices
   - Include error handling

3. **Document your work**
   - Update README files
   - Add inline code comments
   - Document assumptions and limitations
   - Include usage examples

4. **Test your changes**
   - Test with sample data
   - Verify expected outputs
   - Check for edge cases
   - Test integration with existing code

### Finishing Work

1. **Review your changes**
   ```bash
   git status
   git diff
   ```

2. **Commit with clear messages**
   ```bash
   git add .
   git commit -m "Add Monte Carlo stowage model with uncertainty handling"
   ```

3. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a pull request**
   - Use descriptive title and description
   - Reference related issues
   - Request reviews from team members
   - Address feedback promptly

## Code Standards

### Python Code
- Follow PEP 8 style guide
- Use type hints where helpful
- Include docstrings for functions and classes
- Use meaningful variable names
- Keep functions focused and small

### R Code
- Follow tidyverse style guide
- Use consistent naming (snake_case)
- Include comments for complex operations
- Structure code logically

### MATLAB Code
- Use clear variable names
- Include function documentation
- Structure code with sections
- Use consistent indentation

## Documentation Standards

### README Files
- Include purpose and overview
- Provide clear usage instructions
- List dependencies and requirements
- Include examples
- Document limitations and assumptions

### Code Comments
- Explain WHY, not just WHAT
- Use comments for complex algorithms
- Document assumptions and constraints
- Include references to literature

### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Be descriptive but concise
- Reference issues when relevant
- Use conventional commit format when helpful

## Model Development Guidelines

### New Models
1. **Create model directory**
   ```
   models/[stochastic|deterministic]/your_model_name/
   ```

2. **Include required files**
   - `README.md` - Model description and usage
   - Main implementation files
   - `config.json` or similar for parameters
   - `example_run.*` - Usage example
   - `requirements.txt` (for Python)

3. **Follow model structure**
   - Clear separation of concerns
   - Configurable parameters
   - Proper error handling
   - Result validation

4. **Document thoroughly**
   - Mathematical formulation
   - Algorithm description
   - Parameter explanations
   - Usage instructions
   - Performance characteristics

### Data Handling
- Use descriptive filenames
- Document data sources
- Include data validation
- Handle missing values appropriately
- Use standard formats when possible

### Results and Analysis
- Save results with timestamps
- Include configuration information
- Generate reproducible outputs
- Document interpretation
- Compare with baselines

## Review Process

### For Reviewers
- Check code quality and style
- Verify documentation completeness
- Test functionality if possible
- Provide constructive feedback
- Approve when ready

### For Authors
- Respond to feedback promptly
- Make requested changes
- Test after modifications
- Update documentation as needed
- Notify reviewers when ready

## Common Issues and Solutions

### Git Issues
**Problem**: Merge conflicts
**Solution**: 
```bash
git fetch origin
git rebase origin/main
# Resolve conflicts manually
git add .
git rebase --continue
```

**Problem**: Accidentally committed to main
**Solution**:
```bash
git checkout -b feature/emergency-branch
git checkout main
git reset --hard HEAD~1
```

### Code Issues
**Problem**: Import errors
**Solution**: Check Python path and virtual environment

**Problem**: Missing dependencies
**Solution**: Update requirements.txt and reinstall

**Problem**: Model not converging
**Solution**: Check parameters, add logging, test with simpler data

### Documentation Issues
**Problem**: Unclear instructions
**Solution**: Add more examples and step-by-step guidance

**Problem**: Missing information
**Solution**: Include all necessary details for reproduction

## Getting Help

### Internal Help
1. Check existing documentation
2. Search previous issues and discussions
3. Ask team members
4. Create an issue for persistent problems

### External Resources
- GitHub documentation
- Programming language documentation
- Optimization solver documentation
- Academic literature and papers

## Quality Checklist

Before submitting a pull request, verify:

- [ ] Code follows project style guidelines
- [ ] All functions have appropriate documentation
- [ ] README files are updated
- [ ] Examples work as described
- [ ] No unnecessary files are included
- [ ] Commit messages are clear and descriptive
- [ ] Changes are tested and working
- [ ] Dependencies are documented
- [ ] Related issues are referenced

## Communication

### Team Communication
- Use clear, professional language
- Be respectful and constructive
- Ask questions when unsure
- Share knowledge and insights
- Collaborate effectively

### Issue Reporting
- Use descriptive titles
- Include steps to reproduce
- Provide error messages and logs
- Suggest possible solutions
- Tag relevant team members

### Pull Request Communication
- Explain the purpose of changes
- Highlight important modifications
- Address reviewer feedback professionally
- Update based on suggestions
- Confirm when ready for re-review

## Project Goals

Remember our main objectives:
- Create high-quality models for container stowage
- Share knowledge and learn together
- Produce reproducible research
- Maintain clean, organized repository
- Support each other's learning

Thank you for contributing to our project! 🚢📦