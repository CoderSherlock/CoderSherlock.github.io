import sys
from subprocess import call
import os
import time
import math
import random

hostfile = open(sys.argv[1],'r')
guestfile = open(sys.argv[2],'r')
targetfile = open(sys.argv[3],'w+')

guest = guestfile.read()
target = hostfile.read()
byte_ndx = 0
flt_byte = 0
for i in range(0,len(guest)):
    loc=random.randint(0,len(target)-1)
    target = target[:loc]+guest[i]+target[loc:]

targetfile.write(target)
hostfile.close()
guestfile.close()
targetfile.close()
