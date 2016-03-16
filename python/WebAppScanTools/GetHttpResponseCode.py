#!/usr/bin/python
#import http.client  # For Python 3
import httplib #For Python 2

#Get list of users
fname = "/home/fuzz.txt"
with open(fname) as f:
    content = f.read().splitlines()
host = "www.example.com"

for path in content:
        #conn = http.client.HTTPConnection(host) # Python 3
        conn = httplib.HTTPSConnection(host) # Python 2
        conn.request("HEAD", path)
        stat = str(conn.getresponse().status)
        if stat == "200":
            url = host + path
            print(stat, url)


