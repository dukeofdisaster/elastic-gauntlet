#!/bin/bash
# USAGE:
#   - generates 10 CEF messages to standardout
#   - decrements NOW_EPOCH to simulate time delta
NOW_EPOCH=`date +%s`

CEF_MSG="CEF:0|CyberArk|PTA|11.3|1|Suspected credentials theft|8|suser=mike2@prod1.domain.com shost=prod1.domain.com src=1.1.1.1 duser=andy@dev1.domain.com dhost=dev1.domain.com dst=2.2.2.2 cs1Label=ExtraData cs1=None cs2Label=EventID cs2=52b06812ec3500ed864c461e deviceCustomDate1Label=detectionDate deviceCustomDate1=1388577900000 cs3Label=PTAlink cs3=https://1.1.1.1/incidents/52b06812ec3500ed864c461e cs4Label=ExternalLink cs4=None"
for name in elliot whiterose darlene leon oliva philprice dipierro angela oliviacortez tyrell; do
    NOW_EPOCH=$(($NOW_EPOCH-1))
    UPDATE1=`echo $CEF_MSG | sed "s/1388577900000/$NOW_EPOCH/g"`
    UPDATE2=`echo $UPDATE1 | sed "s/mike2@prod1.domain.com/$name@evilcorp.com/g"`
    echo $UPDATE2
done

