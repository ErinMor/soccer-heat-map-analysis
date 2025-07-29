# Soccer Match Heat Map Analysis

## Overview
This project analyzes soccer match events to find correlations between activity levels and goal scoring using heat map visualizations in R.

## Data
- Match timeline data with event timestamps
- Event types: Shots, Corner Kicks, Substitutions, Yellow Cards

## Key Findings
- Goals occurred at minutes 72 and 76
- High activity periods (75-80 min) correlated with goal timing
- Peak event activity preceded both goals

## Files
- `soccer_analysis.R` - Complete R analysis code
- `soccer_match_data.xlsx` - Raw match data
- `soccer_heatmap_analysis.png` - Final visualization

## Tools Used
- R and RStudio
- Libraries: ggplot2, dplyr, patchwork, lubridate

## How to Run
1. Install R packages: `install.packages(c("ggplot2", "dplyr", "patchwork", "lubridate"))`
2. Run the complete script in `soccer_analysis.R`
