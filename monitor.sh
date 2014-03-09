#!/bin/bash

read -sp 'PASSWORD: ' pass
echo
read -sp 'CONFIRM: ' pass2
echo

if ! [[ $pass = $pass2 ]]
then
    echo 'ERROR: passwords do not match'
    exit 1
fi

PATH=/opt/vc/bin:$PATH
pin=0
pout=1
tmout=10
delay=10
dir=output
mkdir -p $dir

gpio mode $pin input
gpio mode $pout output

while gpio wfi $pin rising
do
    gpio write $pout 1
    jpg=$dir/$(date +%s).jpg
    msg="[$(date +%FT%T)] $jpg"
    echo "$msg"
    raspistill -t 1 -q 10 -w 800 -h 600 -o $jpg
    openssl des3 -salt -in $jpg -out $jpg.enc -pass "pass:$pass"
    #rm -f $jpg
    ln -f $jpg ${dir}/latest.jpg
    git add $dir
    git commit -qm "$msg"
    timeout -k1 $tmout git push -q
    gpio write $pout 0
    sleep $delay
done

