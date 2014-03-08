#!/bin/bash

pin=0
pout=1
dir=output
mkdir -p $dir

while gpio wfi $pin rising
do
    gpio write $pout 1
    jpg=$(date +%s).jpg
    msg="[$(date +%FT%T)] $jpg"
    echo "$msg"
    raspistill -o $dir/$jpg
    git add $dir
    git commit -m "$msg"
    git push
    gpio write $pout 0
    sleep 10
done

