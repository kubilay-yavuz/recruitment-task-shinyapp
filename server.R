library("shiny")
library("shiny.semantic")
library("shinythemes")
library("geosphere")
library(leaflet.minicharts)
library(leaflet)
library("leaflet.providers")
library("data.table")
library("ggplot2")


function(input, output, session) {
  # buraya renderUI gelecek
  euclid <- function(x1, x2) {
    return (sqrt(rowSums((x1 - x2) ^ 2)))
  }
  observeEvent(input$portMenu, {
    if(input$portMenu!="All"){
      updateSelectizeInput(session,
                           "vesselTypeMenu",
                           label = "Select vessel type",
                           choices = c(unique(ships.data[PORT == input$portMenu, ship_type])))
    }
    else{
      updateSelectizeInput(session,
                           "vesselTypeMenu",
                           label = "Select vessel type",
                           choices = c("All types",
                                       unique(ships.data[, ship_type])))
    }
  })
  observeEvent(input$vesselTypeMenu, {
    if (input$vesselTypeMenu != "All types") {
      updateSelectizeInput(session,
                           "vesselNameMenu",
                           label = "Select vessel name",
                           choices = c("",
                                       unique(ships.data[ship_type == input$vesselTypeMenu, SHIPNAME])))
      print("basd")
      
    }
    else{
      updateSelectizeInput(session,
                           "vesselNameMenu",
                           label = "Select vessel name",
                           choices = c("",
                                       unique(ships.data[, SHIPNAME])))
      print("aa")
      
    }
    
  })
  observeEvent(input$vesselNameMenu, {
    print(input$vesselNameMenu)
    if (input$vesselNameMenu != "") {
      selectedVesselDf <- ships.data[SHIPNAME == input$vesselNameMenu]
      selectedVesselDf$LATShifted <- shift(selectedVesselDf$LAT, 1)
      selectedVesselDf$LONShifted <- shift(selectedVesselDf$LON, 1)
      selectedVesselDf$distanceBetween <-
        euclid(selectedVesselDf[, c("LAT", "LON")],
               selectedVesselDf[, c("LATShifted", "LONShifted")])
      selectedVesselDf <-
        selectedVesselDf[order(-distanceBetween,-DATETIME),]
      lonLats <-
        selectedVesselDf[, c("LAT", "LON", "LATShifted", "LONShifted")][1]
      distanceBet <-
        distm(c(lonLats$LON, lonLats$LAT),
              c(lonLats$LONShifted, lonLats$LATShifted),
              fun = distHaversine)
      print(lonLats)
      print(distanceBet[1])
      output$distance <- renderText({ paste("The max distance sailed by the vessel",input$vesselNameMenu,"is", round(distanceBet[1],2),"meters") })
      
      leafletProxy("distPlot", data = lonLats) %>%
        clearMarkers() %>%
        addAwesomeMarkers(lng = lonLats$LON, lat = lonLats$LAT, popup = "Start",
                          icon =  awesomeIcons(
                            icon = "ship",
                            iconColor = "#ffffff",
                            library = "fa",
                            markerColor = "cadetblue"
                          )) %>% 
        addAwesomeMarkers(lng = lonLats$LONShifted, lat = lonLats$LATShifted, popup = "End",
                          icon = awesomeIcons(
                            icon = "anchor",
                            iconColor = "#ffffff",
                            library = "fa",
                            markerColor = "red"
                          )) %>% 
        # clearShapes() %>%
        # addCircles(
        #   lonLats$LON,
        #   lonLats$LAT,
        #   radius = 190,
        #   stroke = FALSE,
        #   fillOpacity = 0.4,
        #   color = "blue"
        # ) %>%
        # addCircles(
        #   lonLats$LONShifted,
      #   lonLats$LATShifted,
      #   radius = 190,
      #   stroke = FALSE,
      #   fillOpacity = 0.4,
      #   color = "red"
      # ) %>%
      # setView(lng = (lonLats$LON+lonLats$LONShifted)/2, lat = (lonLats$LAT+lonLats$LATShifted)/2, zoom = 12)
      fitBounds(
        lng1 = min(c(lonLats$LON, lonLats$LONShifted)),
        lat1 = min(c(lonLats$LAT, lonLats$LATShifted)),
        lng2 = max(c(lonLats$LON, lonLats$LONShifted)),
        lat2 = max(c(lonLats$LAT, lonLats$LATShifted))
      )
    }
    else{
      output$distance <- renderText({ "Please select a vessel to see the max distance" })
      
    }
  })
  output$distPlot <- renderLeaflet({
    # qpal <- colorQuantile("RdYlBu", c(1,2), n = 2)
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
      # addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
      #          attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      fitBounds(
        min(ships.data$LON),
        min(ships.data$LAT),
        max(ships.data$LON),
        max(ships.data$LAT)
      )#%>%
    # addLegend("bottomright", pal = qpal, values = c(1,2),
    #         title = "<small>Deaths per 100,000</small>")
  })
}