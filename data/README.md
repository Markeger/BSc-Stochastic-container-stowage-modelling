# Data Directory

This directory contains all data files for the container stowage modelling project.

## Structure

### `/input/` - Raw Input Data
Store original, unprocessed data files here:
- Container specifications
- Ship configuration data
- Port layouts and constraints
- Historical stowage data
- Demand forecasts
- Weather/environmental data

### `/output/` - Processed Data
Store cleaned and processed data files here:
- Preprocessed datasets
- Feature-engineered data
- Standardized formats
- Model-ready datasets

## Data Organization

### File Naming Convention
Use descriptive, consistent naming:
```
YYYY-MM-DD_data-type_source_version.extension
```

Examples:
- `2024-01-15_container-specs_port-rotterdam_v1.csv`
- `2024-01-20_ship-config_maersk-triple-e_final.json`
- `2024-02-01_stowage-history_hamburg_processed.xlsx`

### Supported Formats
- **Spreadsheets**: `.csv`, `.xlsx`, `.ods`
- **Data**: `.json`, `.xml`, `.parquet`
- **Text**: `.txt`, `.md`
- **Images**: `.png`, `.jpg` (for ship layouts, etc.)
- **Archives**: `.zip`, `.tar.gz` (for large datasets)

## Data Documentation

### Required Information
For each dataset, document:
1. **Source**: Where did the data come from?
2. **Date**: When was it collected/generated?
3. **Format**: Structure and column descriptions
4. **Units**: Measurement units for numerical data
5. **Quality**: Known issues or limitations
6. **Usage**: Which models use this data?

### Create Data Cards
For important datasets, create a data card:
```
data/input/dataset_name_DATA_CARD.md
```

## Data Management Best Practices

### Version Control
- Keep original files unchanged in `/input/`
- Version processed files clearly
- Document processing steps
- Use scripts for reproducible processing

### Size Considerations
- Keep files under 100MB when possible
- Use `.gitignore` for very large files
- Consider external storage for big datasets
- Compress when appropriate

### Privacy and Security
- No personal or confidential data
- Check data sharing permissions
- Remove sensitive information
- Document data sources and licenses

## Example Data Processing Workflow

1. **Raw data** → `data/input/`
2. **Process with script** → `scripts/process_data.py`
3. **Cleaned data** → `data/output/`
4. **Use in models** → `models/*/`
5. **Generate results** → `results/`

## Common Data Types

### Container Data
- Container ID, type, size
- Weight, dimensions
- Cargo type, destination
- Special requirements

### Ship Data
- Ship specifications
- Bay/stack configurations
- Stability constraints
- Loading equipment

### Port Data
- Terminal layouts
- Crane capabilities
- Storage areas
- Traffic patterns

### Environmental Data
- Weather conditions
- Sea states
- Port congestion
- Seasonal patterns