# -*- coding: utf-8 -*-
"""
Created on Wed Mar  6 21:09:04 2024

@author: Erdem Emin Akcay , erdememin@gmail.com
"""
from selenium import webdriver
from selenium.webdriver.common.by import By
import re
import pandas as pd
import requests
import time

#start chrome driver
driver = webdriver.Chrome()
whiteaway_url = "https://www.whiteaway.com/hvidevarer/koeleskab/fritstaaende-koeleskab/#/"

driver.get(whiteaway_url)

vue_data_script = driver.execute_script('return vueData;')

my_list = vue_data_script["listing"]

df = pd.DataFrame(my_list)

df_selected = df.loc[:, ['_1', '_14', '_3', '_7', '_9']].rename(columns={'_1': 'name', '_14': 'price', '_3': 'url', '_7': 'brand', '_9': 'product_type'})

whiteaway_url2 = "https://www.whiteaway.com/hvidevarer/koeleskab/integrerbare-koeleskab/#/"

driver.get(whiteaway_url2)

vue_data_script2 = driver.execute_script('return vueData;')

my_list2 = vue_data_script2["listing"]

df2 = pd.DataFrame(my_list2)

df2_selected = df2.loc[:, ['_1', '_14', '_3', '_7', '_9']].rename(columns={'_1': 'name', '_14': 'price', '_3': 'url', '_7': 'brand', '_9': 'product_type'})

whiteaway_url3 = "https://www.whiteaway.com/hvidevarer/koele-fryseskab/fritstaaende-koele-fryseskab/#/"

driver.get(whiteaway_url3)

vue_data_script3 = driver.execute_script('return vueData;')

my_list3 = vue_data_script3["listing"]

df3 = pd.DataFrame(my_list3)

df3_selected = df3.loc[:, ['_1', '_14', '_3', '_7', '_9']].rename(columns={'_1': 'name', '_14': 'price', '_3': 'url', '_7': 'brand', '_9': 'product_type'})

whiteaway_url4 = "https://www.whiteaway.com/hvidevarer/koele-fryseskab/integreret-koele-fryseskab/#/"

driver.get(whiteaway_url4)

vue_data_script4 = driver.execute_script('return vueData;')

my_list4 = vue_data_script4["listing"]

df4 = pd.DataFrame(my_list4)

df4_selected = df4.loc[:, ['_1', '_14', '_3', '_7', '_9']].rename(columns={'_1': 'name', '_14': 'price', '_3': 'url', '_7': 'brand', '_9': 'product_type'})

whiteaway_url5 = "https://www.whiteaway.com/hvidevarer/koele-fryseskab/koeleskab-med-fryser/#/"

driver.get(whiteaway_url5)

vue_data_script5 = driver.execute_script('return vueData;')

my_list5 = vue_data_script4["listing"]

df5 = pd.DataFrame(my_list5)

df5_selected = df5.loc[:, ['_1', '_14', '_3', '_7', '_9']].rename(columns={'_1': 'name', '_14': 'price', '_3': 'url', '_7': 'brand', '_9': 'product_type'})


whiteaway = pd.concat([df_selected, df2_selected, df3_selected, df4_selected, df5_selected], ignore_index=True)
whiteaway['website'] = 'Whiteaway'

whiteaway.to_csv("whiteaway_prices.csv")

def get_unique_links(driver, url, page_number):
    driver.get(url)

    num_scrolls = 10

    # Scroll down in a loop
    for _ in range(num_scrolls):
        # Scroll down by a certain pixel value (e.g., 500 pixels)
        scroll_value = 5000
        driver.execute_script(f"window.scrollBy(0, {scroll_value});")
        time.sleep(4)

    time.sleep(10)
    links = driver.find_elements(By.XPATH, '//a[@href]')
    link_urls = [link.get_attribute('href') for link in links]

    # Filter links based on the specified pattern
    filtered_links = [link for link in link_urls if 'https://www.elgiganten.dk/product/' in link]

    unique_links = list(set(filtered_links))
    unique_links_df = pd.DataFrame(unique_links, columns=['URL'])
    unique_links_df['Page'] = page_number
    return unique_links_df

# Initialize an empty DataFrame
all_links_df = pd.DataFrame(columns=['URL', 'Page'])

# Loop through 20 pages and collect unique links
for page_number in range(1, 21):
    elgiganten_url = f"https://www.elgiganten.dk/hvidevarer/koleskabe-fryseskabe/page-{page_number}"
    unique_links_page = get_unique_links(driver, elgiganten_url, page_number)

    # Append links and page number to the DataFrame
    all_links_df = pd.concat([all_links_df, unique_links_page], ignore_index=True)

all_links_df_clean = all_links_df.drop_duplicates(subset=['URL'])

elgiganten_df = pd.DataFrame(columns=['name', 'price',
                                       'url', 'brand',
                                       'product_type'])

#loop through all articles to get price, brand, name and product_type
for i in range(len(all_links_df_clean)):
    new_url = all_links_df_clean['URL'][i]
    driver.get(new_url)
    time.sleep(30)

    web_elements1 = driver.find_elements(By.XPATH, '//span[@class="ng-star-inserted"]')
    price = [elem.text for elem in web_elements1]
    filtered_price = [p for p in price if '.' in p]

    web_elements2 = driver.find_elements(By.XPATH, '//*[@class="pdp__icon ng-star-inserted"]')
    brand = [elem.get_attribute("alt") for elem in web_elements2]

    web_elements3 = driver.find_elements(By.XPATH, '//*[@class="breadcrumb__link kps-link ng-star-inserted"]')
    product_type = [elem.text for elem in web_elements3][2]

    web_elements4 = driver.find_elements(By.XPATH, '//meta[@property="og:title"]')
    name = [elem.get_attribute("content") for elem in web_elements4]

    # Create a temporary DataFrame for the current URL
    temp_df = pd.DataFrame({
        'name': name,
        'price': filtered_price[0],
        'url': new_url,
        'brand': brand,
        'product_type': product_type
    })
    
    # Concatenate the temporary DataFrame with the main DataFrame
    elgiganten_df = pd.concat([elgiganten_df, temp_df], ignore_index=True)
    
    
elgiganten_df['website'] = 'Elgiganten'
elgiganten_df.to_csv("elgiganten_prices.csv")

all_elsalg_links_df = pd.DataFrame(columns=['URL'])

for page_number in range(1, 17):
    elsalg_url = f"https://elsalg.dk/hvidevarer/koeleskabe#page={page_number}"
    driver.get(elsalg_url)
    time.sleep(5)
    web_elements_elsalg_1 = driver.find_elements(By.XPATH, '//div[@class="imgwraprod"]//a')
    elsalg_links = [elem.get_attribute("href") for elem in web_elements_elsalg_1]
    elsalg_links_df = pd.DataFrame(elsalg_links, columns=['URL'])
    all_elsalg_links_df = pd.concat([all_elsalg_links_df, elsalg_links_df], ignore_index=True)
    time.sleep(5)
    
 
all_elsalg_links_df_clean = all_elsalg_links_df.drop_duplicates(subset=['URL'])
    
elsalg_df = pd.DataFrame(columns=['name', 'price',
                                       'url', 'brand',
                                       'product_type'])

for i in range(len(all_elsalg_links_df_clean)):
    new_url = all_elsalg_links_df_clean['URL'][i]
    driver.get(new_url)
        
    web_elements1 = driver.find_elements(By.XPATH, '//span[@id="product-price"]')
    price = [elem.get_attribute("data-value") for elem in web_elements1]
    
    if not price:
        print(f"Skipping URL {new_url} because price is empty.")
        continue
    
    web_elements2 = driver.find_elements(By.XPATH, '//span[@class="last-breadcrumb"]')
    name = [elem.text for elem in web_elements2]
    
    web_elements3 = driver.find_element(By.XPATH, '//h3')
    product_type = web_elements3.text

    js_code_element = driver.find_element(By.XPATH, '//script[contains(text(), "raptor.trackEvent")]')
    js_code = js_code_element.get_attribute('innerHTML')

    match = re.search(r'raptor\.trackEvent\([^)]*,[^\']*\'([^\']*)\'\)', js_code)

    if match:
        brand = match.group(1)
    else:
        print("The brand value was not found.")

         
    # Create a temporary DataFrame for the current URL
    temp_df = pd.DataFrame({
        'name': name,
        'price': price,
        'url': new_url,
        'brand': brand,
        'product_type': product_type
    })
    
    # Concatenate the temporary DataFrame with the main DataFrame
    elsalg_df = pd.concat([elsalg_df, temp_df], ignore_index=True)
    time.sleep(5)

all_elsalg_links_df_new = pd.DataFrame(columns=['URL'])

for page_number in range(1, 25):
    elsalg_url = f"https://elsalg.dk/hvidevarer/koelefryseskabe#page={page_number}"
    driver.get(elsalg_url)
    time.sleep(5)
    web_elements_elsalg_1 = driver.find_elements(By.XPATH, '//div[@class="imgwraprod"]//a')
    elsalg_links = [elem.get_attribute("href") for elem in web_elements_elsalg_1]
    elsalg_links_df = pd.DataFrame(elsalg_links, columns=['URL'])
    all_elsalg_links_df_new = pd.concat([all_elsalg_links_df_new, elsalg_links_df], ignore_index=True)
    time.sleep(5)
    
 
all_elsalg_links_df_new_clean = all_elsalg_links_df_new.drop_duplicates(subset=['URL'])

for i in range(len(all_elsalg_links_df_new_clean)):
    new_url = all_elsalg_links_df_new_clean['URL'][i]
    driver.get(new_url)
        
    web_elements1 = driver.find_elements(By.XPATH, '//span[@id="product-price"]')
    price = [elem.get_attribute("data-value") for elem in web_elements1]
    
    if not price:
        print(f"Skipping URL {new_url} because price is empty.")
        continue
    
    web_elements2 = driver.find_elements(By.XPATH, '//span[@class="last-breadcrumb"]')
    name = [elem.text for elem in web_elements2]
    
    web_elements3 = driver.find_element(By.XPATH, '//h3')
    product_type = web_elements3.text

    js_code_element = driver.find_element(By.XPATH, '//script[contains(text(), "raptor.trackEvent")]')
    js_code = js_code_element.get_attribute('innerHTML')

    match = re.search(r'raptor\.trackEvent\([^)]*,[^\']*\'([^\']*)\'\)', js_code)

    if match:
        brand = match.group(1)
    else:
        print("The brand value was not found.")

         
    # Create a temporary DataFrame for the current URL
    temp_df = pd.DataFrame({
        'name': name,
        'price': price,
        'url': new_url,
        'brand': brand,
        'product_type': product_type
    })
    
    # Concatenate the temporary DataFrame with the main DataFrame
    elsalg_df = pd.concat([elsalg_df, temp_df], ignore_index=True)
    time.sleep(5)
    
elsalg_df['website'] = 'Elsalg'
elsalg_df.to_csv("elsalg_prices.csv")