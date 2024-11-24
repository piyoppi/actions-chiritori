#!/bin/sh

FILEPATTERN="$1"
TIME_LIMITED_TAG_NAME="$2"
REMOVAL_MARKER_TAG_NAME="$3"
REMOVAL_MARKER_TARGET_CONFIG="$4"
DELIMITER_START="$5"
DELIMITER_END="$6"
ENCODING="$7"
RUN_MODE="$8"

FILES=`find . -name $1 | xargs grep -l $2 | sort | uniq`

for file in $FILES; do
  echo "Processing $file"

  cp $file $file.tmp
  echo '' > $file.tmp

  cp $file $file.bak

  if [ -n "$ENCODING" ]; then
    input=$(iconv -f $ENCODING -t UTF-8 $file)
  else
    input=$(cat $file)
  fi

  chiritori_cmd="chiritori \\
    --filename=$file \\
    --time-limited-tag-name=\"$TIME_LIMITED_TAG_NAME\" \\
    --removal-marker-tag-name=\"$REMOVAL_MARKER_TAG_NAME\" \\
    --delimiter-start=\"$DELIMITER_START\" \\
    --delimiter-end=\"$DELIMITER_END\""

  if [ -n "$REMOVAL_MARKER_TARGET_CONFIG" ]; then
    chiritori_cmd="$chiritori_cmd \\
    --removal-marker-target-config=\"$REMOVAL_MARKER_TARGET_CONFIG\""
  fi

  if [ "$RUN_MODE" = "list" ]; then
    chiritori_cmd="$chiritori_cmd --list
  fi

  if [ "$RUN_MODE" = "list-all" ]; then
    chiritori_cmd="$chiritori_cmd --list-all
  fi

  echo "$input" | eval $chiritori_cmd > $file.tmp

  if [ -n "$ENCODING" ]; then
    iconv -f UTF-8 -t $ENCODING $file.tmp > $file.tmp2
    mv $file.tmp2 $file.tmp
  fi

  mv $file.tmp $file
done
