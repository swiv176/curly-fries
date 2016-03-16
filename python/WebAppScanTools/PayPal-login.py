#!/usr/bin/python
from time import gmtime, strftime, sleep
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC 
from selenium.webdriver.common.by import By


browser = webdriver.Firefox()
today = strftime("%Y-%m-%d")


url = 'https://www.paypal.com/signin/?country.x=US&locale.x=en_US'
browser.get(url)
user = ''
passw = ''



username = browser.find_elements_by_xpath('//*[@id="email"]')

passw = browser.find_elements_by_xpath('//*[@id="password"]')

sleep(3)

username[0].click()
username[0].send_keys(user)

passw[0].click()
sleep(1)
passw[0].send_keys(passw)

Login = browser.find_elements_by_xpath('//*[@id="btnLogin"]')

Login[0].click()

sleep(10)

logout = browser.find_elements_by_xpath('//*[@id="navMenu"]/ul[2]/li[4]/a')
logout[0].click()

sleep(2)
browser.quit()
