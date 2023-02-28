#/bin/bash
# USAGE:
#   - multiline logs suck but they are inevitable
#   - this generates multiline messages

NOW_EPOCH=`date +%s`
for i in {1..10}; do
    IMOD=`expr $i % 2`
    if [ $IMOD -eq 0 ];then
        printf "$NOW_EPOCH - MY_BIZ_CRITICAL_POWERSHELL_SCRIPT - WARNING\n"
        printf "\t\tMY_SCRIPT-v2003.ps1 may not have ran correctly.\n" 
        printf "\t\tI hope someone logs in in the morning and reads this log\n"
    else
        printf "$NOW_EPOCH - MY_BIZ_CRITICAL_POWERSHELL_SCRIPT - INFO\n"
        printf "\t\tMY_SCRIPT-v2003.ps1 ran correctly.\n" 
        printf "\t\tI hope someone logs in in the morning and reads this log\n"
    fi
done
