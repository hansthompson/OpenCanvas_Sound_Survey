
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(httr)
library(shiny)
library(lubridate)
library(ggplot2)
library(dplyr)
#input <- list(city = "Shanghai")


ids <- read.csv("sensor_ids.csv")

shinyServer(function(input, output) {

  output$station_names <- renderUI({
    selectInput('sensor_name', 'Sensor Name', as.character(filter(ids, city == input$city)$sensor_names))
  })

createplot <- reactive({
  api_id <- filter(ids, sensor_names == input$sensor_name)$sensor_ids
json <- GET(paste0("http://sensor-api.localdata.com/api/v1/sources/", api_id, "/entries.csv?count=1000&sort=desc"))
df <- content(json) %>%
  select(timestamp, sound)

df$timestamp <- ymd_hms(df$timestamp)
df$minutes <- df$timestamp - seconds(second(df$timestamp))
df$hours <- df$timestamp - seconds(second(df$timestamp)) - minutes(minute(df$timestamp))

sound_minute <- df %>%
  mutate(decibels = (sound * 0.0158) + 49.184) %>%
  group_by(minutes) %>%
  summarise(decibels = max(decibels)) 

plot_title <- paste("Max dB Each Minute From", min(sound_minute$minute), "to", max(sound_minute$minute))

ggplot(data = sound_minute, aes(x = decibels)) + geom_histogram(binwidth = input$binwidth) + 
  geom_vline(xintercept = 90, color = "red", linetype = "longdash") + annotate("text", x = 90, y =  10, label = "Using an angle grinder", color = "red") +
  geom_vline(xintercept = 75, color = "#FF8600", linetype = "longdash") + annotate("text", x = 75, y =  10, label = "Curbside on a busy road", color = "#FF8600") +
  geom_vline(xintercept = 60, color = "#009900", linetype = "longdash") + annotate("text", x = 60, y =  10, label = "Conversation at 1 meter", color = "#009900") + 
  xlab("Decibels") + ylab("Minutes of exposure") + ggtitle(plot_title)
})

output$distPlot <- renderPlot({
    print(createplot())
  })

})


