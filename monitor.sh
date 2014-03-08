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

pin=0
pout=1
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
    rm -f $jpg
    git add $dir
    git commit -qm "$msg"
    git push -q
    gpio write $pout 0
    sleep 10
done

