#!/bin/bash

if [[ -z $pass ]]
then
    read -sp 'PASSWORD: ' pass
    echo
    read -sp 'CONFIRM: ' pass2
    echo

    if ! [[ $pass = $pass2 ]]
    then
        echo 'ERROR: passwords do not match'
        exit 1
    fi
fi

PATH=/opt/vc/bin:$PATH
pin=0
pout=1
beep=2
tmout=60
delay=10
dir=output
mkdir -p $dir

gpio mode $pin input
gpio mode $pout output
gpio mode $beep output

while gpio wfi $pin rising
do
    gpio write $pout 1
    jpg=$dir/$(date +%s).jpg
    msg="[$(date +%FT%T)] $jpg"
    echo "$msg"
    raspistill -vf -t 1 -q 10 -w 800 -h 600 -o $jpg
    openssl des3 -salt -in $jpg -out $jpg.enc -pass "pass:$pass"
    #rm -f $jpg
    ln -f $jpg ${dir}/latest.jpg
    git add $dir
    git commit -qm "$msg"
    if ! timeout -k1 $tmout git push -q
    then
        gpio write $beep 1
        sleep 0.2
        gpio write $beep 0
    fi
    gpio write $pout 0
    sleep $delay
done

