#! /bin/bash

dirs="en fr"

for d in $dirs; do
    for i in $(ls $d/*.catala_$d); do
        echo "Processing '$i'"
        (catala-format $i > $i.result 2> $i.error) \
            || echo "Error in $i.error"
        [ -s $i.error ] || rm $i.error;
        if [ -s $i.error ] && [[ "$1" = "-v" ]]; then
            cat $i.error;
        fi
    done
done
