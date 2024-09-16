#! /bin/bash

dirs="en fr"

for d in $dirs; do
    find $d -name "*.result" -exec rm {} \;
    find $d -name "*.error" -exec rm {} \;
done
