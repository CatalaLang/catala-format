#! /bin/bash

dirs="en fr"

check(){
    echo -n "Checking '$1': "
    original=$(md5sum $1.result | cut  -d ' ' -f1)
    catala-format $1 > /tmp/res 2> /tmp/error
    if [[ $? -ne 0 ]]; then
        echo
        cat /tmp/error
        echo "#### ERROR IN $1 ####"
        exit 1
    fi
    new=$(md5sum /tmp/res | cut  -d ' ' -f1)
    if [ "$original" = "$new" ]; then
        echo "nothing changed"
    else
        echo "#### CHANGED ####"
        cp /tmp/res $1.changed
        if [ "$2" = "commit" ]; then
            cp $1.changed $1.result
        fi
    fi
}

if [[ $# -gt 0 ]]; then
    d=$(dirname $1)
    check $@
else
    for d in $dirs; do
        for i in $(ls $d/*.catala_$d); do
            check $i
        done
    done
fi
