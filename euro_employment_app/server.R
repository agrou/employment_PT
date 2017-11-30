# Define server logic 
shinyServer(function(input, output) {
  
  output$GenderUi <- renderUI({
          selectizeInput("GenderId", "",
                         c("Women", "Men"), selected = "Total")
  })
 
   output$CountryUi <- renderUI({
           selectizeInput("CountryId", "Country",
                          levels(as.factor(euro_clean2$label)), 
                          selected = "Portugal",
                          multiple = TRUE, size = 5)
   })
   
   
   output$MapGenderUi <- renderUI({
           selectizeInput("MapId", "Gender",
                          c("Women", "Men", "Total"),
                          selected = "Total")
   })
   
   output$MapYearUi <- renderUI({
           selectizeInput("YearId", "Map year",
                          c(1983:2016),
                          selected = 2016)
  })
   
   output$dateRangeUi <- renderUI({
           sliderInput("dateRange", 
                       label = h4("Year range:"), 
                       min = 2002, max = 2016, 
                       value = c(2002, 2016), sep = ""
           )
   })
  
   employ_range <- reactive({
           if(is.null(input$subsetID)){
                   return(NULL)
           }
           employ_long %>% 
                   dplyr::filter(Year >= input$dateRange[1],
                                 Year <= input$dateRange[2] &
                                Age %in% input$ageGroup) 
   })
   
  output$employData <- renderDataTable({
          
          if(input$subsetID == "Gender" && input$GenderId == "Women"){
                employ_range() %>% dplyr::filter(Gender %in% "Women")  
          } else if(input$subsetID == "Gender" && input$GenderId == "Men"){
                  employ_range() %>% dplyr::filter(Gender %in% "Men")
          } else if(input$subsetID == "Difference"){
                  employ_range()
          } else if(input$subsetID == "Map"){
                 
                  euro_filter <- euro_clean2 %>% 
                          dplyr::filter(
                                  Year %in% input$YearId & 
                                  label %in% input$CountryId & 
                                  Age %in% input$ageGroup & 
                                  Gender %in% input$MapId) %>%
                          #mutate(cat = cut_to_classes(Values)) %>%
                          inner_join(df60, ., by = c("NUTS_ID" = "Countries")) %>% 
                          # use a proper coordinate reference syste (CRS): epsg projection 3035 - etrs89 / etrs-laea
                          st_transform("+init=epsg:3035") %>%
                          as_tibble() %>% 
                          select(Year, Age, Gender, Country = label, Values) #%>%
                          #spread(label, Values)
                  
                  euro_filter
                  
                }else {
                  employ_Total <- employ_range() %>% dplyr::filter(Gender %in% "Total") 
                  employ_Total
          }
          
   }, options = list(
          orderClasses = TRUE,
          pageLength = 5,
          lengthMenu = c(5, 10, 15, 20)
          )
           )
  
  output$Plot <- renderPlot({
        
          if(is.null(employ_range())){
                  return()
          }
          else if(input$subsetID == "Difference"){
                  plot_dif <- employ_range() %>%
                          split( .$Age) %>% 
                          purrr::map(~ ggplot(data = ., aes(x = Year, fill = Gender, col = Gender)) +
                          geom_line(aes(y = Difference)) +
                          geom_ribbon(aes(ymax = Difference, ymin = 0), alpha = 0.2) +
                          #facet_wrap(~Gender) +
                          theme_economist_white() +
                          labs(title = "Portugal vs Europe (28 countries)",
                               subtitle = "% Employment difference (PT-EU28) over time, by sex ",
                               y = "% Difference", x = ""))
                  plot_dif
         
          
          }else if(input$subsetID == "Map"){
                  
                  euro_map <- euro_clean2 %>%
                          dplyr::filter(
                                  Year %in% input$YearId &
                                  #label %in% input$CountryId,
                                  Age %in% input$ageGroup &
                                  Gender %in% input$MapId) %>%
                          mutate(cat = cut_to_classes(Values)) %>%
                          inner_join(df60, ., by = c("NUTS_ID" = "Countries")) %>%
                          # use a proper coordinate reference syste (CRS): epsg projection 3035 - etrs89 / etrs-laea
                          st_transform("+init=epsg:3035")
                  
                  data("Europe")
                  
                  tmTotal <- tm_shape(Europe) +
                          tm_fill("lightgrey") +
                          tm_polygons("MAP_COLORS", palette = "Pastel2") +
                          tm_shape(euro_map) +
                          tm_polygons("cat", 
                                      palette = "Greens", 
                                      border.col = "white", 
                                      title = "Employment (%) \n in ")
                  tmTotal
          } else {
                  
                  employ_plot <- employ_geo %>% 
                          dplyr::filter(Year >= input$dateRange[1],
                                        Year <= input$dateRange[2] &
                                 Age %in% input$ageGroup) %>%
                          split( .$Age) %>% 
                          # plot for each age group
                          purrr::map(~ ggplot(data = ., aes(x = Year, y = Values, fill = Gender, col = Gender)) + 
                                             geom_line(aes(colour = Gender)) + 
                                             theme_economist_white() + 
                                             labs(title = as.character(unique(.$Age)), 
                                                  x = "Time", y = "Values") +
                                             facet_wrap(~Countries))
                  employ_plot
          }
         

  })
  
  
}
)
