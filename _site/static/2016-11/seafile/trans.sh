#### THIS IS A SMALL TRANS SCRIPT ####

PREFIX=$1
echo $PREFIX
STARTSIZE=1024*8

let FILESIZE=$STARTSIZE/2

for i in `seq 1 6`;
do
let FILESIZE=$FILESIZE*4
let CHANGESIZE=1024

dd if=/dev/urandom of=$PREFIX.$FILESIZE.dat bs=$FILESIZE count=1
cp $PREFIX.$FILESIZE.dat ./FUCK/$PREFIX.$FILESIZE.dat
sleep 15s
dd if=/dev/urandom of=$CHANGESIZE.dat bs=$CHANGESIZE count=1
cat $CHANGESIZE.dat $PREFIX.$FILESIZE.dat > $PREFIX.$FILESIZE.m.dat 
#python ./addbyte.py $PREFIX.$FILESIZE.dat $CHANGESIZE.dat $PREFIX.$FILESIZE.m.dat
cp $PREFIX.$FILESIZE.m.dat ./FUCK/$PREFIX.$FILESIZE.dat
sleep 15s

done
