#!/bin/bash
#
# USAGE:
#   - generate a valid json object that's composed of .records[] ; many cloud providers batch their logs like
#   like these where records of size N constittutes N messages. 
#   - BEST CASE: there's a pre-canned module for this that allows you to expand 1 .records[N] event into the N messages that it should be
#   - WORST CASE: the message has to be split
RECORD_HEADER='{"records":['
RECORD_FOOTER=']}'
NOW_EPOCH=`date +%s`
for i in {1..10} ; do 
    if [ $i -eq 10 ]; then
        RECORD_HEADER+="{\"timestamp\":$NOW_EPOCH,\"dude\":1,\"dudebool\":false,\"dude_arr\":[\"hello\",\"world\"]}"
    else
        RECORD_HEADER+="{\"timestamp\":$NOW_EPOCH,\"dude\":1,\"dudebool\":false,\"dude_arr\":[\"hello\",\"world\"]},"
    fi
done
RECORD_HEADER+=$RECORD_FOOTER
echo $RECORD_HEADER
