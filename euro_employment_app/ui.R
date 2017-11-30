# 
# agrou
# 20 July 2017
#
# This is a shiny app for data visualization from eurostat package
# 
#    http://shiny.rstudio.com/
#

# Load required libraries for the shiny app
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(sf) #to convert objects for map visualizations
library(tmap)
library(eurostat)
library(stringr)


# Load the data before running the ShinyApp
load("employ_long.RData", envir = .GlobalEnv)
load("employ_geo.RData", envir = .GlobalEnv)
#load("euro_total.RData", envir = .GlobalEnv)
load("df60.RData", envir = .GlobalEnv)
load("euro_clean2.RData", envir = .GlobalEnv)


# Define UI for application that draws a histogram
shinyUI(dashboardPage(
    
  # Application title
  dashboardHeader(title = h3("Employment data in Europe"),
                  titleWidth = 350),
  
  dashboardSidebar(
          width = 350,

          sidebarMenu(
                  
                  # Select data by
                  selectInput("subsetID", h4("Select by"),
                  c("All",
                    "Gender",
                    "Difference",
                    "Map"),
                  selected = "Total"),
                  
                  # Which gender to show
                  conditionalPanel(
                          "input.subsetID == 'Gender'",
                          uiOutput("GenderUi")
                  ),
                  
                  conditionalPanel(
                          "input.subsetID == 'All'",
                          uiOutput("CompareCountryUi")
                  ),
                  
                  # Select countries to show on the Map table
                   conditionalPanel(
                           "input.subsetID == 'Map'",
                           uiOutput("CountryUi")
                   ),
                  
                  
                  # Select gender to show on the Map table and Map plot
                  conditionalPanel(
                          "input.subsetID == 'Map'",
                          uiOutput("MapGenderUi")
                  ),
                  
                  # select year to show on the Map table and Map plot
                  conditionalPanel(
                          "input.subsetID == 'Map'",
                          uiOutput("MapYearUi")
                  ),
                  
                  # select age to show on the table and plot
                  selectInput(inputId = "ageGroup",
                               label = "Age Groups:",
                               choices = levels(as.factor(euro_clean2$Age)),
                              multiple = FALSE, selected = "20-64"),
                  br(),
                  
                  # Date range input
                  conditionalPanel(
                          "input.subsetID != 'Map'",
                          uiOutput("dateRangeUi")
                  ),
                  # sliderInput("dateRange", label = h4("Year range:"),
                  #                min = 2002, max = 2016, value = c(2002, 2016)
                  #                ),
                  # br(),
                  
                  menuItem(h4(strong("References")), tabName = "dashboard", icon = icon(""),
                  p(
                        a("Data source",
                          href = "http://ec.europa.eu/eurostat/data/database")),
                        p(a("Eurostat R package",
                          href = "https://github.com/rOpenGov/eurostat/")),
                        p(a("Europe 2020 indicators",
                          href = "http://ec.europa.eu/eurostat/statistics-explained/index.php/Europe_2020_indicators_-_employment"))
                  
          ))
          
                

  ),

    dashboardBody(
      
       box(plotOutput("Plot"), collapsible = TRUE, width = 14),
       
       br(), br(),
       
       dataTableOutput("employData")
    )
  )
)

