#!/bin/sh

FILEPATTERN="$1"
TAGNAME="$2"
DELIMITER_START="$3"
DELIMITER_END="$4"
ENCODING="$5"

FILES=`find . -name $1 | xargs grep -l $2 | sort | uniq`

for file in $FILES; do
  echo "Processing $file"

  cp $file $file.tmp
  echo '' > $file.tmp

  cp $file $file.bak

  if [ -z "$ENCODING" ]; then
    chiritori --filename=$file --time-limited-tag-name="$TAGNAME" --delimiter-start="$DELIMITER_START" --delimiter-end="$DELIMITER_END" > $file.tmp
  else
    iconv -f $ENCODING -t UTF-8 $file | \
    chiritori --time-limited-tag-name="$TAGNAME" --delimiter-start="$DELIMITER_START" --delimiter-end="$DELIMITER_END" > $file.tmp
  fi

  mv $file.tmp $file
done
