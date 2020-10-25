library("shiny")
library("shiny.semantic")
library("shinythemes")
library("geosphere")
library(leaflet.minicharts)
library(leaflet)
library("leaflet.providers")
library("data.table")
library("ggplot2")


ui <- semanticPage(
  titlePanel("Appsilon Recruitment Task"),
  sidebarLayout(position = "right",sidebarPanel(
    selectizeInput(
      inputId = "portMenu",
      label = "Select ports",
      choices = c("All", unique(ships.data$PORT)),
      selected = character(0),
      multiple = F
    ),
    selectizeInput(
      inputId = "vesselTypeMenu",
      label = "Select vessel type",
      choices = c("All types", unique(ships.data$ship_type)),
      selected = character(0),
      multiple = F
    ),
    selectizeInput(
      inputId = "vesselNameMenu",
      label = "Select vessel name",
      choices = c("", unique(ships.data$SHIPNAME)),
      selected = character(0),
      multiple = F
    ),
    sliderInput(inputId="timeDiff", label="Select time difference (minutes)",min=1,max=100,value = 30)
  ),
  mainPanel(
    leafletOutput(
      outputId = "distPlot",
      width = "700px",
      height = "300px"
    ),
    textOutput(outputId = "distance")
  )
  )
)
