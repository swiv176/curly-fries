
import os
import json
from collections import OrderedDict


jfile = 'G:\\results\\2016-02-25_d7a22284-f49f-4650-82a2-8a6efab43abb.json'

with open(jfile) as data_file:
   content = json.load(data_file)


print json.dumps(content,sort_keys=True,indent=4)