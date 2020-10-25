getwd()
setwd("C:/Users/Sthesk/Desktop/appsilon/recruitment-task-shinyapp/")

# install.packages("shiny.semantic")
# install.packages("geosphere")
# install.packages("leaflet.minicharts")
# install.packages("leaflet")
# install.packages("shiny", version = '0.14.2.9001')
# install.packages("leaflet.providers")
# install.packages("shinythemes")
library("shiny")
library("shiny.semantic")
library("shinythemes")
library("geosphere")
library(leaflet.minicharts)
library(leaflet)
library("leaflet.providers")
library("data.table")
library("ggplot2")

# options(shiny.custom.semantic = "styles/")

ships.data <- fread("ships_data/ships.csv")
ships.data[SHIPNAME == ". PRINCE OF WAVES", SHIPNAME := "PRINCE OF WAVES"]
ships.data[SHIPNAME == ".WLA-311", SHIPNAME := "WLA-311"]
ships.data <- ships.data[order(SHIPNAME, DATETIME),]


runApp()
