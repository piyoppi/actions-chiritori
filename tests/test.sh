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

./cleanup_test.sh

# --------------------------------------------------------------------------------------------
# Test Encoding Conversion

../entrypoint.sh '*.php' 'time-limited' 'removal-marker' '' '# <' '> #' 'euc-jp' 'remove' > /dev/null

assert_file "Test Encoding Conversion" expected/index.eucjp.php.expected index.eucjp.php

./cleanup_test.sh

# --------------------------------------------------------------------------------------------
# Test index.html (default charset (UTF-8))

../entrypoint.sh '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'remove' > /dev/null

assert_file "Test index.html (default charset (UTF-8))" expected/index.html.expected index.html

./cleanup_test.sh

# --------------------------------------------------------------------------------------------
# Test list-all index.html

../entrypoint.sh '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list-all' > ./tmp/tmp-index.html.list-all.actual

assert_file "Test list-all index.html" expected/index.html.list-all.expected ./tmp/tmp-index.html.list-all.actual

./cleanup_test.sh

# --------------------------------------------------------------------------------------------
# Test list index.html

../entrypoint.sh '*.html' 'time-limited' 'removal-marker' '' '<!-- <' '> -->' '' 'list' > ./tmp/tmp-index.html.list.actual

assert_file "Test list index.html" expected/index.html.list.expected ./tmp/tmp-index.html.list.actual

./cleanup_test.sh

# --------------------------------------------------------------------------------------------
# Test index.js

echo 'awesome-feature' > ./tmp/target-config

../entrypoint.sh '*.js' 'time-limited-code' 'removal-marker-tag' './tmp/target-config' '// --' '-- //' '' 'remove' > /dev/null

assert_file "Test index.js" expected/index.js.expected index.js

./cleanup_test.sh
