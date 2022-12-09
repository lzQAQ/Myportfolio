#### ECON 6210 R Shiny Web Forecasting App Project
#### Group Member: Li Zhang, YiJun Zhang 
#### Date: Dec7, 2022


library(shiny)
library(fpp2)
library(readxl)

delay_data <- read_excel("/Users/zhangli/Desktop/Econ Final Assignment/delay_data.xlsx")

df = delay_data

df = ts(df, start=2014, frequency=12)

Bloor_Danforth <- df[,2]
Sheppard <- df[,3]
Scarborough <- df[,4]
Yonge_University <- df[,5]

ui <- fluidPage(
  pageWithSidebar(
  
  # Application title
  headerPanel("TTC Subway Delay Forecasting"),
  
  # Sidebar with controls to select the dataset and forecast ahead duration
  sidebarPanel(
    # Select variable
    selectInput("variable", "Variable:",
                list("Bloor_Danforth" = "Bloor_Danforth", 
                     "Sheppard" = "Sheppard",
                     "Scarborough" = "Scarborough",
                     'Yonge_University' = 'Yonge_University')),
    
    sliderInput("ahead","Number of periods for forecasting:",
                min = 1, max = 20,     step= 1, value = 4),
    
    
    submitButton("Update View")
  ),

  
        # Show a plot of the generated distribution
        mainPanel(
          h3(textOutput("caption")),
          
          tabsetPanel(
            tabPanel("Timeseries plot", plotOutput("tsPlot")),
            tabPanel("Arima Forecast", plotOutput("arimaForecastPlot"), tableOutput("arimaForecastTable")),
            tabPanel("Exponential Smoothing (ETS) Forecast", plotOutput("etsForecastPlot"), tableOutput("etsForecastTable")), 
            tabPanel("TBATS Forecast", plotOutput("tbatsForecastPlot"), tableOutput("tbatsForecastTable")),
            tabPanel("STL", plotOutput("STLForecastPlot"),tableOutput("STLForecastTable")),
            tabPanel("Holt", plotOutput("HoltForecastPlot"),tableOutput("HoltForecastTable")),
            tabPanel("Average forecasts", tableOutput("averageForecastTable"))
            
        )
    )))


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  getDataset <- reactive({
    if (input$variable=="Bloor_Danforth")
    {
      return(Bloor_Danforth)
    }
    else if (input$variable=="Sheppard")
    {
      return(Sheppard)
    }
    else if (input$variable=="Scarborough")
    {
      return(Scarborough)
    }
    else
    {
      return(Yonge_University)
    }
  })
  
  output$caption <- renderText({
    paste("Dataset: ", input$variable)
  })
  
  ## TS Plot
  output$tsPlot <- renderPlot({
    y <- getDataset()
    p1 = autoplot(y) + ylab("# of mins")
    p2 = ggAcf(y)
    gridExtra::grid.arrange(p1, p2, nrow=2)
  })
  
  ##Arima Info
  output$arimaForecastPlot <- renderPlot({
    fit <- auto.arima(getDataset())
    plot(forecast(fit, h=input$ahead))
  })
  
  output$arimaForecastTable <- renderTable({
    fit <- auto.arima(getDataset())
    forecast(fit, h=input$ahead)
  })
  
  ##ETS Info
  output$etsForecastPlot <- renderPlot({
    fit <- ets(getDataset())
    plot(forecast(fit, h=input$ahead))
  })
  
  output$etsForecastTable <- renderTable({
    fit <- ets(getDataset())
    forecast(fit, h=input$ahead)
  })
  
  ##Tbat Info
  output$tbatsForecastPlot <- renderPlot({
    fit <- tbats(getDataset())
    plot(forecast(fit, h=input$ahead))
  })
  
  output$tbatsForecastTable <- renderTable({
    fit <- tbats(getDataset())
    forecast(fit, h=input$ahead)
    
  })
  
  ##STL Info
  output$STLForecastPlot <- renderPlot({
    fit <- stl(getDataset(),t.window=13, s.window="periodic", robust=TRUE) 
    
    fit %>% seasadj() %>% naive(h=input$ahead) %>%
      autoplot() + ylab("Mins_delay") 
  })
  
  output$STLForecastTable <- renderTable({
    fit <- stl(getDataset(),t.window=13, s.window="periodic", robust=TRUE) 
    forecast(fit,method="naive",h=input$ahead)

  })
  
  ## Holt Info
  output$HoltForecastPlot <- renderPlot({
    fc <- holt(getDataset(), h=input$ahead)
    autoplot(fc) + ylab("Mins_delay") 
    
  })
  
  output$HoltForecastTable <- renderTable({
    fit <- holt(getDataset(), h=input$ahead)
    fit
  })
  
  output$averageForecastTable <- renderTable({
    
    fit1 <- ets(getDataset())
    fc1 = forecast(fit1, h=input$ahead)
    
    fit2 = auto.arima(getDataset())
    fc2 = forecast(fit2, h=input$ahead)
    
    fit3 <- tbats(getDataset())
    fc3 = forecast(fit3, h=input$ahead)
    
    fit4 <- stl(getDataset(),t.window=13, s.window="periodic", robust=TRUE) 
    fc4 <- forecast(fit4,method="naive",h=input$ahead)
    
    fit5 <- holt(getDataset(), h=input$ahead)
    
    fc = (fc1$mean + fc2$mean + fc3$mean+ fc4$mean+ fit5$mean)/5
    fc
  })
  

}


shinyApp(ui = ui, server = server)
