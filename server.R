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
elsalg <- read.csv("elsalg_prices.csv")


elgiganten$price <- as.numeric(gsub(".-", "", elgiganten$price))

elgiganten <- elgiganten %>% filter(product_type != "Køletaske og køleboks" & price >= 200) 

elsalg$price <- as.numeric(gsub(",", ".", elsalg$price))

data <- rbind(whiteaway, elgiganten, elsalg) %>% mutate(brand = if_else(brand == "LiebHerr",
                                                                        "Liebherr", brand)) %>%
                                                 mutate(brand = if_else(brand == "GRAM",
                                                 "Gram", brand)) %>%
                                                 mutate(brand = if_else(brand == "SMEG" | brand == "smeg",
                                                 "Smeg", brand)) %>%
                                                 filter(brand != "")



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
    
    datatable(data_brand, options = list(dom = 'tpi'), filter = list(position = "bottom")) %>%
      formatStyle(
        columns = names(data_brand)[-1],  
        backgroundColor = styleEqual(0, "pink")
      )
    
    
  })
  
  output$price_points_text <- renderText({ 
    
    paste0("<B> This graph shows different price points per Website in Refrigerator Category </B>")
    
  }) 
  
  output$plot <- renderPlot({
    
    highest_elgiganten <- data %>% filter(website == "Elgiganten") %>% filter(price == max(price)) %>% slice(1)
    lowest_elgiganten <- data %>% filter(website == "Elgiganten") %>% filter(price == min(price)) %>% slice(1)
    median_elgiganten <- data %>% filter(website == "Elgiganten") %>% group_by(website) %>% summarise(price = median(price))
    
    highest_whiteaway <- data %>% filter(website == "Whiteaway") %>% filter(price == max(price)) %>% slice(1)
    lowest_whiteaway <- data %>% filter(website == "Whiteaway") %>% filter(price == min(price)) %>% slice(1)
    median_whiteaway <- data %>% filter(website == "Whiteaway") %>% group_by(website) %>% summarise(price = median(price))
    
    highest_elsalg <- data %>% filter(website == "Elsalg") %>% filter(price == max(price)) %>% slice(1)
    lowest_elsalg <- data %>% filter(website == "Elsalg") %>% filter(price == min(price)) %>% slice(1)
    median_elsalg <- data %>% filter(website == "Elsalg") %>% group_by(website) %>% summarise(price = median(price))
    
    gg <- ggplot(data, aes(x = website, y = price, fill = website)) +  
      geom_violin(alpha = 0.7) +
      geom_text_repel(data = highest_elgiganten, aes(x = website, y = price, 
                                                  label = paste0(website, "'s highest price is ",
                                                                 price)),
                      color = "red", size = 4 , vjust = -1.5) + 
      geom_text_repel(data = highest_whiteaway, aes(x = website, y = price, 
                                                   label = paste0(website, "'s highest price is ",
                                                                  price)),
                    color = "blue", size = 4 , vjust = -1.5) +
      geom_text_repel(data = highest_elsalg, aes(x = website, y = price, 
                                                    label = paste0(website, "'s highest price is ",
                                                                   price)),
                      color = "darkgreen", size = 4 , vjust = -1.5) +
      geom_text_repel(data = lowest_elgiganten, aes(x = website, y = price, 
                                                     label = paste0(website, "'s lowest price is ",
                                                                    price)),
                      color = "red", size = 4 , vjust = 2) + 
      geom_text_repel(data = lowest_whiteaway, aes(x = website, y = price, 
                                                    label = paste0(website, "'s lowest price is ",
                                                                   price)),
                      color = "blue", size = 4 , vjust = 2) +
      geom_text_repel(data = lowest_elsalg, aes(x = website, y = price, 
                                                   label = paste0(website, "'s lowest price is ",
                                                                  price)),
                      color = "darkgreen", size = 4 , vjust = 2) +
      geom_text_repel(data = median_elgiganten, aes(x = website, y = price, 
                                                     label = paste0(website, "'s median price is ",
                                                                    price)),
                      color = "red", size = 4 , vjust = -1.5) +
      geom_text_repel(data = median_whiteaway, aes(x = website, y = price, 
                                                    label = paste0(website, "'s median price is ",
                                                                   price)),
                      color = "blue", size = 4 , vjust = -1.5) +
      geom_text_repel(data = median_elsalg, aes(x = website, y = price, 
                                                   label = paste0(website, "'s median price is ",
                                                                  price)),
                      color = "darkgreen", size = 4 , vjust = -1.5) +
      labs(title = "Price points of different Websites",
           x = "Website",
           y = "Price") +
      theme_minimal() +
      theme(legend.position = "none") +
      theme(axis.text.x = element_text(face = "bold", size = 12))
    
     
   gg 
   
  })
  
  output$bracket_text <- renderText({ 
    
    
    
    paste0("<B> Number of articles within different price brackets </B>")
    
    
  }) 
  
  output$table2 <- DT::renderDataTable({
    
    data_with_price_group <- data %>%
                               mutate(price_group = cut(price,
                               breaks = c(-Inf, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000, Inf),
                               labels = c("<500", "500-1000", "1000-1500", "1500-2000", "2000-2500", "2500-3000", "3000-3500", "3500-4000", "4000-4500", "4500-5000", "5000-5500", "5500-6000", "6000-6500", "6500-7000", "7000-7500", "7500-8000", "8000-8500", "8500-9000", "9000-9500", "9500-10000", ">10000"),
                               include.lowest = TRUE))   %>% 
      group_by(website, price_group) %>%
      summarise(Number_of_products = n()) %>%
      pivot_wider(names_from = website, values_from = Number_of_products,  values_fill = 0)
    
    datatable(data_with_price_group, options = list(dom = 'tpi'), filter = list(position = "bottom")) %>%
      formatStyle(
        columns = names(data_brand)[-1],  
        backgroundColor = styleEqual(0, "pink")
      )
    
    
  })
  
 
}