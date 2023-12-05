# Vancouver Tree Checker App

Explore the Vancouver Tree Checker App in its two versions: - [Vancouver Tree Checker App (Original Version)](https://lurkstalker.shinyapps.io/vancouver_tree_dashboard/) - [Vancouver Tree Checker V2 App (Enhanced Version)](https://lurkstalker.shinyapps.io/vancouver_tree_dashboard_v2/)

## Overview

The Vancouver Tree Checker App provides a dynamic and interactive way to explore and analyze data on Vancouver's urban trees. Designed for researchers, students, and tree enthusiasts, this user-friendly app allows users to engage with the city's tree population through various visualization and filtering tools.

## Key Features

1.  **Species Filters**: Explore the diversity of tree species in Vancouver. Select one or multiple species to focus your analysis.

2.  **Group By Functionality**: Analyze tree data by grouping based on streets or neighborhoods. Gain insights into tree count, unique species, average diameter, and other key metrics.

3.  **Diameter and Height Range Filters**: Apply filters to analyze trees by their diameter and height. The filtering logic dynamically adjusts based on the selected grouping, allowing for a more nuanced analysis.

4.  **Date Range Filter**: Investigate the trees based on their planting date, offering a historical perspective on urban forestry.

5.  **Customizable Plots**: Create bespoke visualizations by selecting axes and plot types, enabling a tailored data storytelling experience.

6.  **Dynamic Table Customization**: Customize the data table display by selecting specific columns, ensuring a focused and relevant data view.

7.  **Downloadable Data**: Export your filtered dataset as a .csv file for in-depth offline analysis or sharing.

## Dataset Source

The app utilizes the `vancouver_trees` dataset from the [UBC-MDS/datateachr Vancouver R package](https://rdrr.io/github/UBC-MDS/datateachr/man/vancouver_trees.html). This dataset provides comprehensive, up-to-date information on public trees in Vancouver.

To install the `UBC-MDS/datateachr` package:

``` r
install.packages("remotes")
remotes::install_github("UBC-MDS/datateachr")
```

The dataset is publicly accessible and updated weekly, promoting transparency and reproducibility.

## Getting Started

### Running the App Locally

1.  **Clone the Repository**: Start by cloning this repository to your local machine.

2.  **Install Dependencies**: Install the necessary R packages with the following commands:

    ``` r
    install.packages(c("shiny", "DT", "ggplot2", "dplyr", "tidyverse", "remote"))
    remotes::install_github("UBC-MDS/datateachr")
    ```

3.  **Launch the App**: Open `app.R` in RStudio and click "Run App" to begin exploring.

4.  **App Versions**: Note that there are two versions of the app -- the original and the V2 with enhanced functionality.

Happy exploring Vancouver's urban forestry with this intuitive and powerful tool!
