# Vancouver Tree Checker App

**Live Demo**: Explore the Vancouver Tree Checker App [here](https://lurkstalker.shinyapps.io/vancouver_tree_dashboard/).

## Overview

The Vancouver Tree Checker App is a dynamic, user-friendly tool designed for anyone interested in exploring and analyzing data about Vancouver's urban trees. Whether you're a researcher, student, or just a curious citizen, this app provides an engaging way to visualize and understand the city's tree population.

## Key Features

1.  **Species Filters**: Dive into the diversity of Vancouver's trees. Filter records by species, with support for multiple selections to tailor your exploration.

2.  **Group By Functionality**: Discover patterns and trends by grouping tree data by street or neighborhood. View key statistics like tree count, unique species, average diameter, and more.

3.  **Customizable Plots**: Create your own visual story. Choose your axes and plot types to visualize the data in a way that speaks to you.

4.  **Dynamic Table Customization**: Tailor the data table to your needs. Select the columns that matter to you for a personalized view.

5.  **Downloadable Data**: Take your analysis further. Download your custom-filtered dataset as a .csv file for deeper exploration or sharing.

## Dataset Source

This app utilizes the `vancouver_trees` dataset from the [UBC-MDS/datateachr Vancouver R package](https://rdrr.io/github/UBC-MDS/datateachr/man/vancouver_trees.html), featuring comprehensive information on public trees in Vancouver. The dataset is updated weekly, ensuring fresh and relevant data for users.

Install the `UBC-MDS/datateachr` package with:

``` r
install.packages("remotes")
remotes::install_github("UBC-MDS/datateachr")
```

The data is publicly available and easily accessible through the R package, aligning with principles of transparency and reproducibility.

## Getting Started

Run the Vancouver Tree Checker App in your local environment:

1.  **Clone the Repository**: Get the code on your machine by cloning this repository.
2.  **Install Dependencies**: Set up your environment by running the following in your R console:

``` r
  install.packages(c("shiny", "DT", "ggplot2", "dplyr", "tidyverse", "remote"))
  remotes::install_github("UBC-MDS/datateachr")
```

3.  **Launch the App**: Open app.R in RStudio and hit the "Run App" button to start exploring.

Dive into the world of Vancouver's urban forestry with this intuitive and powerful tool. Happy exploring!
