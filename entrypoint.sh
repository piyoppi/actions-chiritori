#!/bin/sh

FILEPATTERN="$1"
TIME_LIMITED_TAG_NAME="$2"
REMOVAL_MARKER_TAG_NAME="$3"
REMOVAL_MARKER_TARGET_CONFIG="$4"
DELIMITER_START="$5"
DELIMITER_END="$6"
ENCODING="$7"
RUN_MODE="$8"

cleanup_code() {
  chiritori_cmd=$1
  file=$2
  encoding=$3

  eval $chiritori_cmd > $file.out

  if [ -n "$ENCODING" ]; then
    iconv -f UTF-8 -t $ENCODING $file.out > $file.out2
    mv $file.out2 $file
    rm $file.out
  else
    mv $file.out $file
  fi
}

print() {
  chiritori_cmd=$1

  eval $chiritori_cmd
}

FILES=`find . -name $1 | xargs grep -l $2 | sort | uniq`

for file in $FILES; do
  echo "Processing $file"

  cp $file $file.bak

  if [ -n "$ENCODING" ]; then
    iconv -f $ENCODING -t UTF-8 $file > $file.tmp
  else
    cp $file $file.tmp
  fi

  chiritori_cmd="chiritori \
    --filename=$file.tmp \
    --time-limited-tag-name=\"$TIME_LIMITED_TAG_NAME\" \
    --removal-marker-tag-name=\"$REMOVAL_MARKER_TAG_NAME\" \
    --delimiter-start=\"$DELIMITER_START\" \
    --delimiter-end=\"$DELIMITER_END\""

  if [ -n "$REMOVAL_MARKER_TARGET_CONFIG" ]; then
    chiritori_cmd="$chiritori_cmd --removal-marker-target-config=\"$REMOVAL_MARKER_TARGET_CONFIG\""
  fi

  if [ "$RUN_MODE" = "remove" ]; then
    cleanup_code "$chiritori_cmd" $file $ENCODING
  fi

  if [ "$RUN_MODE" = "list" ]; then
    chiritori_cmd="$chiritori_cmd --list"
    print "$chiritori_cmd"
  fi

  if [ "$RUN_MODE" = "list-all" ]; then
    chiritori_cmd="$chiritori_cmd --list-all"
    print "$chiritori_cmd"
  fi

  rm $file.tmp
done
