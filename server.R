#load packages
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)
library(ggrepel)
library(tidyr)

whiteaway <- read.csv("whiteaway_prices.csv")
elgiganten <- read.csv("elgiganten_prices.csv")
elgiganten$website <- "Elgiganten"

elgiganten$price <- as.numeric(gsub(".-", "", elgiganten$price))

elgiganten <- elgiganten %>% filter(product_type != "Køletaske og køleboks" & price >= 200) 

data <- rbind(whiteaway, elgiganten)





#create tables
function(input, output) {

  
  output$brand_text <- renderText({ 
    
    
    
    paste0("<B> Brand availability in different websites </B>")
    
    
  }) 
    
  output$table1 <- DT::renderDataTable({
      
    data_total <- data %>% group_by(brand) %>% summarise(Number_of_products = n()) %>% mutate(website = "Total")
    
    data_brand <- data %>% 
      group_by(website, brand) %>%
      summarise(Number_of_products = n()) %>% rbind(data_total) %>%
      pivot_wider(names_from = website, values_from = Number_of_products,  values_fill = 0) %>%
      arrange(desc(Total)) %>% select(-Total)
     
    datatable(data_brand, options = list(dom = 'tpi'), filter = list(position = "bottom"))
    
    
  })
  
  output$price_points_text <- renderText({ 
    
    paste0("<B> This graph shows different price points per Website in Refrigerator Category </B>")
    
  }) 
  
  output$plot <- renderPlot({
    
    highest_elgiganten <- data %>% filter(website == "Elgiganten") %>% filter(price == max(price)) %>% slice(1)
    lowest_elgiganten <- data %>% filter(website == "Elgiganten") %>% filter(price == min(price)) %>% slice(1)
    
    highest_whiteaway <- data %>% filter(website == "Whiteaway") %>% filter(price == max(price)) %>% slice(1)
    lowest_whiteaway <- data %>% filter(website == "Whiteaway") %>% filter(price == min(price)) %>% slice(1)
    
    gg <- ggplot(data, aes(x = website, y = price, fill = website)) +  
      geom_violin(alpha = 0.7) +
      geom_text_repel(data = highest_elgiganten, aes(x = website, y = price, 
                                                  label = paste0(website, "'s highest price is ",
                                                                 price)),
                      color = "red", size = 2.5 , vjust = 1.5) + 
      geom_text_repel(data = highest_whiteaway, aes(x = website, y = price, 
                                                   label = paste0(website, "'s highest price is ",
                                                                  price)),
                    color = "blue", size = 2.5 , vjust = 1.5) +
      geom_text_repel(data = lowest_elgiganten, aes(x = website, y = price, 
                                                     label = paste0(website, "'s lowest price is ",
                                                                    price)),
                      color = "red", size = 2.5 , vjust = 2) + 
      geom_text_repel(data = lowest_whiteaway, aes(x = website, y = price, 
                                                    label = paste0(website, "'s lowest price is ",
                                                                   price)),
                      color = "blue", size = 2.5 , vjust = 2) +
      labs(title = "Price points of different Websites",
           x = "Website",
           y = "Price") +
      theme_minimal() +
      theme(legend.position = "none")
     
   gg 
   
  })
  
 
  

  
}