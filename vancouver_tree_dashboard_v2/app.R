#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# install.packages(c("shiny", "DT", "ggplot2", "dplyr", "tidyverse", "remote", "leaflet"))
# remotes::install_github("UBC-MDS/datateachr")

# The code for the Shiny app is well-structured, but to enhance its readability and functionality, I'll add some comments and suggest a few improvements:

### Improvements in Code Structure and Comments

# Load necessary libraries
library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(datateachr)

# Define UI for the Shiny application
ui <- fluidPage(
  includeCSS("www/styles.css"),
  titlePanel("Vancouver Trees Dashboard V2"),

  # Sidebar layout for input controls
  sidebarLayout(
    sidebarPanel(
      # Input for selecting tree species
      selectInput("speciesInput", "Select Species:",
        choices = unique(vancouver_trees$species_name),
        selected = NULL, multiple = TRUE
      ),

      # Input for grouping data
      selectInput("groupInput", "Group by:",
        choices = c("None", "std_street", "neighbourhood_name"),
        selected = "None"
      ),

      # Slider for selecting diameter range
      sliderInput("diameterRange", "Diameter Range:",
        min = min(vancouver_trees$diameter, na.rm = TRUE),
        max = max(vancouver_trees$diameter, na.rm = TRUE),
        value = c(0, 50)
      ),

      # Slider for selecting height range
      sliderInput("heightRange", "Height Range:",
        min = min(vancouver_trees$height_range_id, na.rm = TRUE),
        max = max(vancouver_trees$height_range_id, na.rm = TRUE),
        value = c(4, 6)
      ),

      # Conditional panel for date range input
      conditionalPanel(
        condition = "input.groupInput == 'None'",
        dateRangeInput("dateRange", "Date Range:",
          start = min(vancouver_trees$date_planted, na.rm = TRUE),
          end = max(vancouver_trees$date_planted, na.rm = TRUE),
          min = min(vancouver_trees$date_planted, na.rm = TRUE),
          max = max(vancouver_trees$date_planted, na.rm = TRUE)
        )
      ),

      # Input for selecting X and Y axes for plotting
      selectInput("xAxis", "X-Axis:", choices = NULL),
      selectInput("yAxis", "Y-Axis:", choices = NULL),

      # Multiple column selection for data display
      selectInput("columnsSelected", "Choose columns to display:",
        choices = NULL, multiple = TRUE
      ),

      # Button to download data
      downloadButton("downloadData", "Download Data"),

      # Output for displaying the number of records found
      textOutput("resultsText"),

      # Image display
      tags$img(src = "vancouver_trees.png", height = "300px", width = "520px"),
    ),

    # Main panel for displaying data table and plot
    mainPanel(
      tabsetPanel(
        tabPanel("Table",
          id = "table-tab",
          DT::dataTableOutput("table"),
          uiOutput("plotTitle"), # Dynamic title for plot
          plotOutput("plot") # Output for plot display
        )
      )
    )
  )
)

# Server logic for the Shiny application
server <- function(input, output, session) {
  # Reactive expression for filtering and grouping data
  filteredGroupedData <- reactive({
    data <- vancouver_trees

    # Filter data based on selected species
    if (length(input$speciesInput) > 0) {
      data <- data[data$species_name %in% input$speciesInput, ]
    }

    # Group data based on selected group option and compute summary statistics
    if (input$groupInput != "None") {
      data <- data %>%
        group_by_(input$groupInput) %>%
        summarise(
          numbre_of_trees = n(),
          species_count = n_distinct(species_name, na.rm = TRUE),
          avg_diameter = mean(diameter, na.rm = TRUE),
          max_diameter = max(diameter, na.rm = TRUE),
          avg_height_id = mean(height_range_id, na.rm = TRUE),
          max_height = max(height_range_id, na.rm = TRUE),
        )
    }
    data
  })

  # Observe changes in groupInput and update diameterRange and heightRange sliders
  observe({
    filtered_data <- filteredGroupedData()

    # Update slider settings based on group selection
    if (input$groupInput == "None") {
      # Default settings for sliders when no grouping is selected
      updateSliderInput(session, "diameterRange", "Diameter Range:",
        min = min(vancouver_trees$diameter, na.rm = TRUE),
        max = max(vancouver_trees$diameter, na.rm = TRUE),
        value = c(0, 50)
      )
      updateSliderInput(session, "heightRange", "Height Range:",
        min = min(vancouver_trees$height_range_id, na.rm = TRUE),
        max = max(vancouver_trees$height_range_id, na.rm = TRUE),
        value = c(4, 6)
      )
    } else if (input$groupInput %in% c("std_street", "neighbourhood_name")) {
      # Adjust slider settings based on grouped data
      minAvgDiameter <- floor(min(filtered_data$avg_diameter, na.rm = TRUE))
      maxAvgDiameter <- ceiling(max(filtered_data$avg_diameter, na.rm = TRUE))
      minAvgHeightId <- floor(min(filtered_data$avg_height_id, na.rm = TRUE))
      maxAvgHeightId <- ceiling(max(filtered_data$avg_height_id, na.rm = TRUE))
      stepDiameter <- (maxAvgDiameter - minAvgDiameter) / 20
      stepHeight <- (maxAvgHeightId - minAvgHeightId) / 20
      updateSliderInput(session, "diameterRange", "Average Diameter Range:",
        min = minAvgDiameter, max = maxAvgDiameter,
        value = c(minAvgDiameter, min(minAvgDiameter + 1, maxAvgDiameter)),
        step = stepDiameter
      )
      updateSliderInput(session, "heightRange", "Average Height Range:",
        min = minAvgHeightId, max = maxAvgHeightId,
        value = c(minAvgHeightId, min(minAvgHeightId + 1, maxAvgHeightId)),
        step = stepHeight
      )
    }
  })

  # Update choices in selectInput based on filtered data
  observe({
    filtered_data <- filteredGroupedData()
    updateSelectInput(session, "columnsSelected", choices = names(filtered_data), selected = names(filtered_data))
    updateSelectInput(session, "xAxis", choices = names(filtered_data), selected = NULL)
    updateSelectInput(session, "yAxis", choices = names(filtered_data), selected = NULL)
  })

  # Render dynamic title for plot based on X and Y axis selections
  output$plotTitle <- renderUI({
    if (!is.null(input$xAxis) && !is.null(input$yAxis) && input$xAxis != "" && input$yAxis != "") {
      h3(paste("Data Visualization -", input$xAxis, "vs", input$yAxis))
    } else {
      h3("Data Visualization")
    }
  })

  # Render DataTable based on selected columns and additional filters
  output$table <- DT::renderDataTable({
    filtered_data <- filteredGroupedData()

    # Function to apply diameter and height filters
    applyFilters <- function(data) {
      if (!is.null(input$diameterRange)) {
        diameter_col <- ifelse(input$groupInput == "None", "diameter", "avg_diameter")
        data <- data %>% filter(!!sym(diameter_col) >= input$diameterRange[1] & !!sym(diameter_col) <= input$diameterRange[2])
      }
      if (!is.null(input$heightRange)) {
        height_col <- ifelse(input$groupInput == "None", "height_range_id", "avg_height_id")
        data <- data %>% filter(!!sym(height_col) >= input$heightRange[1] & !!sym(height_col) <= input$heightRange[2])
      }
      data
    }

    # Apply date range filter for 'None' groupInput
    if (input$groupInput == "None" && !is.null(input$dateRange)) {
      filtered_data <- filtered_data %>% filter(date_planted >= input$dateRange[1] & date_planted <= input$dateRange[2])
    }

    # Apply diameter and height filters
    filtered_data <- applyFilters(filtered_data)

    # Select only the columns chosen by the user
    if (!is.null(input$columnsSelected)) {
      filtered_data <- filtered_data[, input$columnsSelected, drop = FALSE]
    }

    # Return the DataTable
    DT::datatable(filtered_data)
  })

  # Output to show number of records found
  output$resultsText <- renderText({
    paste("Number of record found:", nrow(filteredGroupedData()))
  })


  # Render plot based on selected X and Y axes
  output$plot <- renderPlot({
    # Check if both xAxis and yAxis inputs are selected
    if (is.null(input$xAxis) || is.null(input$yAxis) || input$xAxis == "" || input$yAxis == "") {
      # Display an error message if xAxis or yAxis is not selected
      showNotification("Please select both X-Axis and Y-Axis for the plot.", type = "error")
      return(NULL)
    } else {
      # Get filtered data
      data <- filteredGroupedData()

      # Limit the number of x-axis values to 30 or the total number of unique values if less than 30
      top_x_values <- data[[input$xAxis]] %>%
        unique() %>%
        head(min(30, length(unique(data[[input$xAxis]]))))

      # Filter data based on top x-axis values if they exist
      if (length(top_x_values) > 0) {
        # Ensure that the column specified by input$xAxis exists in the data
        if (input$xAxis %in% names(data)) {
          # Filter the data
          data <- data[data[[input$xAxis]] %in% top_x_values, ]
          # Create the plot
          p <- ggplot(data, aes_string(x = input$xAxis, y = input$yAxis)) +
            geom_bar(stat = "identity") +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) # Adjust text angle and size
          return(p)

        } else {
          # If the column does not exist, handle this case (e.g., return empty data or show a message)
          data <- data.frame() # or any other appropriate action
          # Optionally, show a notification in the Shiny app
          showNotification("Selected X-Axis column does not exist in the data.", type = "error")
        }
      } else {
        # If input$xAxis is NULL or empty, or if top_x_values is empty, handle this case
        data <- data.frame() # or any other appropriate action
        # Optionally, show a notification in the Shiny app
        showNotification("No valid X-Axis selection or no data available for the selected X-Axis.", type = "error")
      }
    }
  })

  # Download handler
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("vancouver-trees-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filteredGroupedData(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
