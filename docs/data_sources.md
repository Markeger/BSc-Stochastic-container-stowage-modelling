# Data Sources Documentation

This document tracks all data sources used in the project.

## Container Data

### Source 1: Port of Rotterdam Historical Data
- **File**: `data/input/rotterdam_containers_2023.csv`
- **Source**: Port of Rotterdam Authority
- **Date Collected**: 2023-12-15
- **Description**: Historical container arrival and specifications
- **Fields**: 
  - container_id, weight, length, width, height
  - cargo_type, destination, arrival_time
  - special_requirements, priority_level
- **Quality Notes**: 
  - 5% missing weight values (estimated)
  - Some containers have estimated dimensions
- **Usage**: Training data for stochastic models
- **License**: Academic use only

### Source 2: Simulated Container Dataset
- **File**: `data/input/simulated_containers_varied.csv`
- **Source**: Generated using data_generator.py
- **Date Created**: 2024-01-10
- **Description**: Synthetic container data for testing
- **Fields**: container_id, weight, dimensions, type
- **Quality Notes**: Clean synthetic data, no missing values
- **Usage**: Model validation and testing
- **License**: Open for project use

## Ship Configuration Data

### Source 1: Standard Container Ship Specifications
- **File**: `data/input/ship_specs_medium_vessel.json`
- **Source**: Maritime Engineering Handbook
- **Date**: 2024-01-05
- **Description**: Generic medium-sized container ship layout
- **Fields**: 
  - bay_layout, slot_coordinates, weight_limits
  - crane_positions, access_constraints
- **Quality Notes**: Simplified representation
- **Usage**: Base case for all models
- **License**: Public domain

## Environmental Data

### Source 1: Weather Patterns
- **File**: `data/input/weather_data_north_sea.csv`
- **Source**: European Marine Weather Service
- **Date Range**: 2020-2023
- **Description**: Historical weather data for North Sea routes
- **Fields**: date, wind_speed, wave_height, visibility
- **Quality Notes**: 2% missing values, interpolated
- **Usage**: Stochastic weather modeling
- **License**: Academic research license

## Benchmark Data

### Source 1: Literature Benchmark Instances
- **Directory**: `data/input/benchmarks/`
- **Source**: Maritime optimization literature
- **Date**: Various (2018-2023)
- **Description**: Standard test instances from published papers
- **Format**: Various (CSV, JSON, XML)
- **Quality Notes**: Verified against published results
- **Usage**: Model validation and comparison
- **License**: Research use as cited

## Data Processing Notes

### Data Cleaning Steps
1. **Container Data**: 
   - Removed duplicates based on container_id
   - Filled missing weights with median values
   - Validated weight ranges (1-35 tons)
   - Standardized dimension units to meters

2. **Ship Data**:
   - Converted coordinates to standard format
   - Validated slot capacity constraints
   - Added derived fields (bay_capacity, total_slots)

3. **Weather Data**:
   - Interpolated missing values using linear interpolation
   - Converted units to metric system
   - Filtered extreme outliers (>3 standard deviations)

### Known Issues
- Container weight estimates may have ±5% error
- Ship configuration simplified for computational tractability
- Weather data limited to specific geographic region
- Some benchmark instances use different constraint definitions

## Usage Guidelines

### Data Access
- All input data is read-only in the repository
- Use scripts in `scripts/data_processing/` for modifications
- Store processed versions in `data/output/`
- Document any transformations in processing scripts

### Quality Control
- Validate data ranges before using in models
- Check for missing or invalid values
- Compare processed data with original sources
- Document assumptions and limitations

### Updates
- Check data sources periodically for updates
- Version control important datasets
- Maintain backward compatibility when possible
- Update documentation when data changes

## Contact Information

For questions about specific datasets:
- Container data: [Port Authority Contact]
- Ship specifications: [Maritime Engineering Reference]
- Weather data: [Weather Service API]
- Benchmark instances: [Literature Citations]

## Data Cards

For detailed information about each dataset, see individual data cards in:
- `data/input/[dataset_name]_DATA_CARD.md`

These contain detailed metadata, quality assessments, and usage guidelines for each major dataset.