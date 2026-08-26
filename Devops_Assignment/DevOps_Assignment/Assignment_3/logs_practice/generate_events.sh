#!/bin/bash
for i in {1..20}; do
    if [ $((i%3)) -eq 0 ]; then
        echo "FAIL Event $i"
    else
        echo "OK Event $i"
    fi
done > events.log

head -5 events.log
tail -5 events.log
head -n -3 events.log
tail -n +15 events.log
head -10 events.log | tail -1
grep 'FAIL' events.log | tail -3
lines=$(wc -l < events.log)
tail -n $((lines/4)) events.log
