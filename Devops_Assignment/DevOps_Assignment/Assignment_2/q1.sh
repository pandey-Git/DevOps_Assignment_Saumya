#!/bin/bash

folder=$1

file=$(ls -t $folder | head -1)

echo "Latest file: $file"

cp $folder/$file $folder/copy_$file

cat $folder/$file | tr ' ' '\n' | sort | uniq -c | sort -nr | head -1
