
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Open Canvas Sound Sensor Survey"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput('city', 'City', c("Bangalore", "Boston", "Geneva", "Rio de Janeiro", "San Francisco", 
                                    "Shanghai", "Singapore")),
      uiOutput('station_names'),
      numericInput("binwidth", label = "Bin Width", value = 1)
      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
