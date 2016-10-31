FILESIZE=134217728
let CHANGESIZE=16777216

UNI_TARGET='phao3@bingsuns.binghamton.edu:~'
UNI_PASSWD=Pengzhan2015USA

LAB_TARGET='moslab@10.42.0.1:~/Desktop/server'
LAB_PASSWD=1
temp=16384
for i in `seq 1 4`;
do
	dd if=/dev/urandom of=$FILESIZE.dat bs=8192 count=$temp status=none
	sshpass -p $LAB_PASSWD ./rsync $FILESIZE.dat $LAB_TARGET
	#echo $FILESIZE
	dd if=/dev/urandom of=$CHANGESIZE.dat bs=1024 count=$temp status=none
	cat $FILESIZE.dat $CHANGESIZE.dat > temp.dat
	sshpass -p $LAB_PASSWD ./rsync temp.dat $LAB_TARGET/$FILESIZE.dat
    
    let temp=$temp*2
	let FILESIZE=$FILESIZE*2
done
date

