#load packages
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(ggrepel)


#design shiny app: 
shinyUI(fluidPage(
  
  titlePanel("Whiteaway vs Elgiganten vs Elsalg"),
  
  img(src="./whiteaway.png",  height="8%", width="8%",  align = "center"),
  img(src="./elgiganten.png",  height="8%", width="8%",  align = "center"),
  img(src="./elsalg1.png",  height="8%", width="8%",  align = "center"),
  
  HTML("<p>Refrigerator Price comparison between Whiteaway, Elgiganten and Elsalg </p>"),
  
  
  
  mainPanel(
    
    tabsetPanel(type = "tabs",
                
                tabPanel("Price Points ", htmlOutput("price_points_text"), plotOutput('plot',width = "150%",height = "600px")),
                
                tabPanel("Brand Availability", htmlOutput("brand_text"), DT::dataTableOutput("table1")),
                
                tabPanel("Number of Articles within Price Brackets", htmlOutput("bracket_text"), DT::dataTableOutput("table2")),
                
    )
    
  ),
  
  tags$footer(
    style = "text-align: center; padding: 10px; background-color: #f5f5f5;",
    "Developed by: Erdem Emin Akcay | Email: erdememin@gmail.com"
  )
  
  
)

)