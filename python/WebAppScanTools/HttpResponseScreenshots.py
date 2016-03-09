#!/usr/bin/python

#This script uses a list of file paths and checks for a reaponse from the web server.
# If the servers responds with a 200, then the script takes a screen shot of the page for later review.


#import http.client #python 3
import httplib # python 2
from selenium import webdriver
import os

#location to store the data.  The scrip will create a sub-directory in this location.
data = 'C:\\Users\\myuser\Documents\\results\\'

#target domain Name
host = "google.com"

#Fuzz List Location
fname = "C:\\Users\\myuser\\Documents\\loginfuzz.txt"

#uncomment appropriate protocol
protocol = 'http://'
#protocol = 'https://'
#Get list

with open(fname) as f:
    content = f.read().splitlines()

folder = host.replace(' ','-')
scrn = data+folder+'\\'
os.mkdir(scrn)

for p in content:
        path = p
        if protocol =='http://':
           conn = httplib.HTTPConnection(host)
        elif protocol == 'https://':
           conn = httplib.HTTPSConnection(host)
        else:
          print "missing protocol"
          break

#begin scan
        conn.request("HEAD", path)
        stat = conn.getresponse().status
        print(host,path, "responded: ",stat)
        if stat == 200:
           url = protocol+host +path
           browser = webdriver.PhantomJS()
           browser .set_window_size(1280,720)
           browser.get(url)
           spl = p.replace('/', '-')
           scname = spl+ '.png'
           scpath = scrn + scname
           print(scpath)
           browser.save_screenshot(scpath)
           browser.quit()
