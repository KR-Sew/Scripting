#!/bin/bash

loopCount=3
name="msdocs"

for i in $(seq 1 $loopCount)
do
    loopName="loop $i for $name"
    echo $loopName
done