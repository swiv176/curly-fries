
import json
from collections import OrderedDict
import uuid
from datetime import date, datetime, time
import os
# Create Json File

#Filename
jsonid = str(uuid.uuid4())
scantime =  str(date.today())
jsonfilename = str(scantime+'_'+jsonid+'.json')

catalog = OrderedDict([('catalogid',jsonid),
    ('catalogdate',scantime),
    ('data',{})
    ])

savefile = 'G:\\results\\' + jsonfilename

path = 'D:\\Artifacts'

myfiles = os.listdir(path)

#for each
for root, dirs, files in os.walk(path):
   #src = root.split('\\')
   #print (len(src) -1) *'--', os.path.basename(root)
   for f in files:
      b = os.path.basename(f)
      basename = os.path.splitext(b) [0]
      extension = os.path.splitext(b) [1]
      fileuid = str(uuid.uuid4())
      item = OrderedDict([('filename',str(os.path.splitext(b) [0])),
           ('extension',str(os.path.splitext(b) [1])),
           ('filesize',''),
           ('lastwrittendate',scantime),
           ('creationdate', 'date'),
           ('sourcefilepath',os.path.join(root, f)),
           ('sourcesystemname', 'mysystemname'),
           ('checksum',''),
           ('destfilepath','destpath'),
           ('date',scantime)
           ])
      catalog['data'][fileuid] = item

#print catalog
#print json.dumps(catalog,indent=4,sort_keys=False, separators=(',', ': '))

with open(savefile, 'w') as outfile:
    json.dump(catalog,outfile)