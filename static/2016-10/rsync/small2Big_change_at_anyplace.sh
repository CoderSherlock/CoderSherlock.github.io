FILESIZE=8192
let CHANGESIZE=1024

UNI_TARGET='phao3@bingsuns.binghamton.edu:~'
UNI_PASSWD=Pengzhan2015USA

LAB_TARGET='moslab@10.42.0.1:~/Desktop/server'
LAB_PASSWD=1

LOC_TARGET='..'

temp=1
for i in `seq 1 14`;
do
	dd if=/dev/urandom of=$FILESIZE.dat bs=8192 count=$temp status=none
	sshpass -p $LAB_PASSWD ./rsync $FILESIZE.dat $LAB_TARGET
    # ./rsync -v -v $FILESIZE.dat $LOC_TARGET --no-whole-file
	# echo $FILESIZE
	dd if=/dev/urandom of=$CHANGESIZE.dat bs=$CHANGESIZE count=1 status=none
	# cat $CHANGESIZE.dat $FILESIZE.dat > temp.dat
    python ../addbyte.py $FILESIZE.dat $CHANGESIZE.dat temp.dat
    # cp -f $FILESIZE.dat temp.dat
	sshpass -p $LAB_PASSWD ./rsync temp.dat $LAB_TARGET/$FILESIZE.dat
    # ./rsync temp.dat $LOC_TARGET/$FILESIZE.dat --no-whole-file

    
    let temp=$temp*2
	let FILESIZE=$FILESIZE*2
done
date

