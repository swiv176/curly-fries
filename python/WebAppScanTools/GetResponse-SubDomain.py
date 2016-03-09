#!/usr/bin/python
import httplib


#Get list of users
fname = "/home/root/grey/subdomains.txt"
with open(fname) as f:
    content = f.read().splitlines()
host = "wework.com"

for sub in content:

        subhost = sub+'.'+host
        conn = httplib.HTTPSConnection(subhost) # Python 2
        conn.request("HEAD", '/')
        stat = str(conn.getresponse().status)
        if stat == "200":
            print(subhost, stat)
        print subhost,stat