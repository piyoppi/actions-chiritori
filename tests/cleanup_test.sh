#!/bin/sh

FILES="index.eucjp.php index.html index.js"

for file in $FILES; do
  if [ -f $file.bak ]; then
    mv $file.bak $file
  fi
done

rm -rf ./tmp/
mkdir ./tmp
