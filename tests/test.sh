#!/bin/sh

assert_file() {
  title=$1
  expected_file=$2
  actual_file=$3

  if [ $(diff $expected_file $actual_file | wc -l) -eq 0 ]; then
    echo "$title [32mPASSED[0m"
  else
    echo "$title [31mFAILED[0m"
    exit 255
  fi
}

cleanup_test() {
  rm -rf ./tmp/
  mkdir ./tmp
}

setup_test() {
  FILES="index.eucjp.php index.html index.js"

  for file in $FILES; do
    cp files/$file tmp/$file
  done
}

cleanup_test

# --------------------------------------------------------------------------------------------
# Test Encoding Conversion

setup_test

../entrypoint.sh './tmp' '*.php' 'time-limited' 'removal-marker' '' '# <' '> #' 'euc-jp' 'remove' '' '' '' '' > /dev/null

assert_file "Test Encoding Conversion" expected/index.eucjp.php.expected tmp/index.eucjp.php

cleanup_test

# --------------------------------------------------------------------------------------------
# Test index.html (default charset (UTF-8))

setup_test

../entrypoint.sh './tmp' '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'remove' '' '' '' '' > /dev/null

assert_file "Test index.html (default charset (UTF-8))" expected/index.html.expected tmp/index.html

cleanup_test

# --------------------------------------------------------------------------------------------
# Test list-all index.html

setup_test

../entrypoint.sh './tmp' '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list-all' '' '' '' '' > ./tmp/tmp-index.html.list-all.actual

assert_file "Test list-all index.html" expected/index.html.list-all.expected ./tmp/tmp-index.html.list-all.actual

cleanup_test

# --------------------------------------------------------------------------------------------
# Test list index.html

setup_test

../entrypoint.sh './tmp' '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list' '' '' '' '' > ./tmp/tmp-index.html.list.actual

assert_file "Test list index.html" expected/index.html.list.expected ./tmp/tmp-index.html.list.actual

cleanup_test

# --------------------------------------------------------------------------------------------
# Test index.js

setup_test

echo 'awesome-feature' > ./tmp/target-config

../entrypoint.sh './tmp' '*.js' 'time-limited-code' 'removal-marker-tag' './tmp/target-config' '// --' '-- //' '' 'remove' '' '' '' '' > /dev/null

assert_file "Test index.js" expected/index.js.expected tmp/index.js

cleanup_test

# --------------------------------------------------------------------------------------------
# Test annotation

setup_test

../entrypoint.sh './tmp' '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list-all' '' 'annotation' '' '' > ./tmp/tmp-index.html.annotation.actual

assert_file "Test annotate index.html" expected/index.html.annotation.expected ./tmp/tmp-index.html.annotation.actual

cleanup_test

# --------------------------------------------------------------------------------------------
# Test annotation (GitHub Diff)

setup_test

cd tmp/ && git init && git add . && git commit -m "temporary git" && cd -

cp files/index.html.updated tmp/index.html
cp ../entrypoint.sh tmp/entrypoint.sh

cd tmp/ && git commit -am "changed" && cd -

cd tmp/ && git diff HEAD^..HEAD && cd -

cd tmp && ./entrypoint.sh '.' '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list-all' 'diff' 'annotation' 'HEAD^' 'HEAD' > ../tmp/tmp-index.html.diff.annotation.actual && cd -

assert_file "Test diff annotate index.html" expected/index.html.diff.annotation.expected ./tmp/tmp-index.html.diff.annotation.actual

cleanup_test
