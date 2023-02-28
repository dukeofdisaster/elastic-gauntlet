#!/bin/bash
# NOTE: if you're on a mac this requires 
KERNEL=`uname`
if [[ "$KERNEL" == "Linux" ]];then
    echo KERNEL IS $KERNEL
    #### assume back? 
    cat consumer.sh |base64 -w 0 > consumer.sh.b64
else
    #### assume back? 
    cat consumer.sh |base64 > consumer.sh.b64
fi
