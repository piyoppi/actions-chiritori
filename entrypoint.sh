#!/bin/sh

BASEDIR="$1"
FILEPATTERN="$2"
TIME_LIMITED_TAG_NAME="$3"
REMOVAL_MARKER_TAG_NAME="$4"
REMOVAL_MARKER_TARGET_CONFIG="$5"
DELIMITER_START="$6"
DELIMITER_END="$7"
ENCODING="$8"
RUN_MODE="$9"
TARGET_FILE_MODE="${10}"
REPORT_MODE="${11}"
BASE_SHA="${12}"
HEAD_SHA="${13}"

DIFF_REF="$BASE_SHA..$HEAD_SHA"

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

find_line() {
  line_start=$1
  line_end=$2

  shift 2

  while true; do
    line=$1

    if [ -z $line ]; then
      echo "none"
      break
    fi

    shift 1

    is_report=''
    diff_start=`echo $line | cut -d, -f1`
    diff_len=`echo $line | cut -d, -f2`
    diff_end=`expr $diff_start + $diff_len`

    if [ $line_start -ge $diff_start -a $line_start -lt $diff_end ]; then
      break
    fi

    if [ $line_end -ge $diff_start -a $line_end -lt $diff_end ]; then
      break
    fi
  done

  echo $@
}

print() {
  chiritori_cmd=$1
  file=$2

  if [ "$REPORT_MODE" = "annotation" ]; then
    chiritori_cmd="$chiritori_cmd --list-json"
    results=`eval "$chiritori_cmd | jq -c '.[] | {line_range, current_status}'"`

    if [ "$TARGET_FILE_MODE" = "diff" ]; then
      lines=`git diff --unified=0 $DIFF_REF -- $file | grep '^@@' | sed -E 's/@@ -([0-9]+).* \+([0-9]+)(,[0-9]+)?.*/\2\3/'`
    fi

    for result in $results; do
      line_start=`echo $result | jq '.line_range[0]'`
      line_end=`echo $result | jq '.line_range[1]'`
      current_status=`echo $result | jq '.current_status'`
      lines_next=`find_line $line_start $line_end $lines`

      message="Removal-Marker Detected."
      if [ "$current_status" = '"Ready"' ]; then
        level="warning"
      else
        level="notice"
      fi

      if [ "$TARGET_FILE_MODE" = "diff" ]; then
        if [ "$lines" != "$lines_next" -a "$lines_next" != "none" ]; then
          lines=$lines_next
          echo "::$level file=$file,line=$line_start,col=0::$message"
        fi
      else
        echo "::$level file=$file,line=$line_start,col=0::$message"
      fi

    done
  else
    eval $chiritori_cmd
  fi
}

if [ -n "$GITHUB_WORKSPACE" ]; then
	git config --global --add safe.directory $GITHUB_WORKSPACE
fi

if [ "$TARGET_FILE_MODE" = "diff" ]; then
  FILES=`git diff --name-only $DIFF_REF -- "$BASEDIR/$FILEPATTERN" | xargs grep -l $TIME_LIMITED_TAG_NAME | sort | uniq`
else
  FILES=`find $BASEDIR -name $FILEPATTERN | xargs grep -l $TIME_LIMITED_TAG_NAME | sort | uniq`
fi

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
    print "$chiritori_cmd" $file
  fi

  if [ "$RUN_MODE" = "list-all" ]; then
    chiritori_cmd="$chiritori_cmd --list-all"
    print "$chiritori_cmd" $file
  fi

  rm $file.tmp
done
