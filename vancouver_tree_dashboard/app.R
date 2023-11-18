#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# install.packages(c("shiny", "DT", "ggplot2", "dplyr", "tidyverse", "remote"))
# remotes::install_github("UBC-MDS/datateachr")

library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(datateachr)

# UI for application that draws a histogram
ui <- fluidPage(
  includeCSS("www/styles.css"),
  titlePanel("Vancouver Trees Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("speciesInput", "Select Species:",
                  choices = unique(vancouver_trees$species_name),
                  selected = NULL, multiple = TRUE),
      selectInput("groupInput", "Group by:",
                  choices = c("None", "std_street", "neighbourhood_name"),
                  selected = "None"),

      selectInput("xAxis", "X-Axis:", choices = NULL),
      selectInput("yAxis", "Y-Axis:", choices = NULL),

      # Multiple column selection
      selectInput("columnsSelected", "Choose columns to display:",
                  choices = NULL, multiple = TRUE),
      downloadButton("downloadData", "Download Data"),
      textOutput("resultsText"),
      tags$img(src = "vancouver_trees.png", height = '300px', width = '520px'),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Table", id = "table-tab",
                 DT::dataTableOutput("table"),
                 uiOutput("plotTitle"),  # Dynamic title output
                 plotOutput("plot")
        )
      )
    )
  )
)



# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # Filter and group data
  filteredGroupedData <- reactive({
    data <- vancouver_trees
    if (length(input$speciesInput) > 0) {
      data <- data[data$species_name %in% input$speciesInput, ]
    }
    if (input$groupInput != "None") {
      data <- data %>% group_by_(input$groupInput) %>%
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

  observe({
    # Assuming 'filtered_data' is your filtered dataset
    filtered_data <- filteredGroupedData()

    # Update the choices in the selectInput
    updateSelectInput(session, inputId = "columnsSelected",
                             choices = names(filtered_data),
                             selected = names(filtered_data))
  })

  observe({
    # Assuming 'filtered_data' is your filtered dataset
    filtered_data <- filteredGroupedData()

    # Update the choices in the selectInput for xAxis and yAxis
    updateSelectInput(session, inputId = "xAxis",
                      choices = names(filtered_data),
                      selected = NULL)
    updateSelectInput(session, inputId = "yAxis",
                      choices = names(filtered_data),
                      selected = NULL)
  })

  # Render dynamic title for the plot
  output$plotTitle <- renderUI({
    if (!is.null(input$xAxis) && !is.null(input$yAxis) && input$xAxis != "" && input$yAxis != "") {
      h3(paste("Data Visualization -", input$xAxis, "vs", input$yAxis))
    } else {
      h3("Data Visualization")
    }
  })

  # Render Table
  output$table <- DT::renderDataTable({
    # data <- filteredGroupedData() %>% select(all_of(input$columnInput))
    filtered_data <- filteredGroupedData()
    # Select only the columns chosen by the user
    if (!is.null(input$columnsSelected)) {
      filtered_data <- filtered_data[, input$columnsSelected, drop = FALSE]
    }

    DT::datatable(filtered_data)
  })

  # Render Plot
  output$plot <- renderPlot({
    # Check if both xAxis and yAxis inputs are selected
    if (is.null(input$xAxis) || is.null(input$yAxis) || input$xAxis == "" || input$yAxis == "") {
      # Display an error message if xAxis or yAxis is not selected
      showNotification("Please select both X-Axis and Y-Axis for the plot.", type = "error")
      return(NULL)
    } else {
      # Get filtered data
      data <- filteredGroupedData()

      # Limit the number of x-axis values to 30
      top_x_values <- data[[input$xAxis]] %>% unique() %>% head(30)
      data <- data[data[[input$xAxis]] %in% top_x_values, ]

      # Create the plot
      p <- ggplot(data, aes_string(x = input$xAxis, y = input$yAxis)) +
        geom_bar(stat = "identity") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) # Adjust text angle and size
      return(p)
    }
  })

  # Show number of results
  output$resultsText <- renderText({
    paste("Number of record found:", nrow(filteredGroupedData()))
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
