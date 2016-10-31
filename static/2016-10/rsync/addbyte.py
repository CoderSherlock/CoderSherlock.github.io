import sys
from subprocess import call
import os
import time
import math
import random



# print time.localtime()
hostfile = open(sys.argv[1],'r')
# print "cp -f "+sys.argv[1]+" "+sys.argv[3]
# call(["cp","-f",sys.argv[1],sys.argv[3]])
guestfile = open(sys.argv[2],'r')
targetfile = open(sys.argv[3],'w+')
hostsize = os.path.getsize(sys.argv[1])
guestsize = os.path.getsize(sys.argv[2])

# print hostsize
"""
print mean
if mean!=0:
    for i in range(0,guestsize):
        guestfile.seek(i)
        target.seek(mean*i)
        #print str(mean*i)+":"+target.read(1)+"\t"+str(i)+":"+guestfile.read(1)
        temp = target.read(1)+guestfile.read(1)
        target.seek(mean*i)
        target.write(temp)

print guestfile,target
"""
mean = 1
c_sz = [12, 24,47,94,188,375,729,1024,1449,2048,2897,4096,5794,8192]
ndx = int(math.log(float(hostsize)/8192,2))
dist = int(float(hostsize)/c_sz[ndx] + 0.5)
# print dist

if mean!=0:
    guest = guestfile.read()
    target = hostfile.read()
    byte_ndx = 0
    flt_byte = 0
    for i in range(0,c_sz[ndx]):
        # loc = random.randint(i*dist+flt_byte, (i+1)*dist+flt_byte)
        loc = 10+i*dist+flt_byte
        # print loc, guest[byte_ndx]
        target = target[:loc]+guest[byte_ndx]+target[loc:]
        flt_byte += 1
        byte_ndx = (byte_ndx+1)%guestsize
target = target[:-3]+"X"+target[-3:]

targetfile.write(target)
hostfile.close()
guestfile.close()
targetfile.close()
# print time.localtime()
