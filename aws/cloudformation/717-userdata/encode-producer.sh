#!/bin/bash
# NOTE: if you're on a mac this requires 
KERNEL=`uname`
if [[ "$KERNEL" == "Linux" ]];then
    echo KERNEL IS $KERNEL
    #### assume back? 
    cat producer-001.sh |base64 -w 0 > producer-001.sh.b64
else
    #### assume back? 
    cat producer-001.sh |base64 > producer-001.sh.b64
fi
