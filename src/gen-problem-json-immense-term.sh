#!/bin/bash
# USAGE:
#   - this simulates a log file which is otherwise well structured but contains an immense term.
#   - such logs can break ingest
#   - CHATGPT PROMPT: Give me 20 Mr. Robot quotes as en example JSON object; the json object should include an ISO8601 timestamp in UTC time zone, a string field named "dudestring", an integer field named "dudeint", and all the Mr. Robot quotes should be contained in the field "hello_friend" as one string, not an array. 

NOW_EPOCH=`date +%s`
MSG_HEADER="{\"timestamp\":$NOW_EPOCH,\"dude\":1,\"dudestr\":\"hello friend\"
