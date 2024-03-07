#load packages
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(ggrepel)


#design shiny app: 
shinyUI(fluidPage(
  
  titlePanel("Whiteaway vs Elgiganten"),
  
  img(src="./whiteaway.png",  height="10%", width="10%",  align = "center"),
  img(src="./elgiganten.png",  height="10%", width="10%",  align = "center"),
  
  HTML("<p>Refrigerator Price comparison between Whiteaway and Elgiganten </p>"),
  
  
  
  mainPanel(
    
    tabsetPanel(type = "tabs",
                
                tabPanel("Price Points ", htmlOutput("price_points_text"), plotOutput('plot',width = "150%",height = "600px")),
                
                tabPanel("Brand Availability", htmlOutput("brand_text"), DT::dataTableOutput("table1"))
                
    )
    
  ),
  
  tags$footer(
    style = "text-align: center; padding: 10px; background-color: #f5f5f5;",
    "Developed by: Erdem Emin Akcay | Email: erdememin@gmail.com"
  )
  
  
)

)