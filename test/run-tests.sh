#!/usr/bin/env bash

# =====================================================
# To run this tests you should have the Vader plugin:
# https://github.com/junegunn/vader.vim
# =====================================================


# got to the directory with this script (./test/):
cd $(dirname ${BASH_SOURCE[0]})

# path to the Vader plugin:
VADER_PATH=${VADER_PATH:='~/.vim/plugged/vader.vim/'}

# path to the directory with plugin for test:
PLUGIN_PATH=${PLUGIN_PATH:='../'}

# regexp to select tests to run
[[ -z "$1" ]] && VADER_TESTS=*.vader || VADER_TESTS="$1"


GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

VADER_RESULTS=("${GREEN}Results:$NC")
RESULT=0

function run() {
  vim -EsNu <(cat << EOF
    filetype off
    set rtp+=$VADER_PATH
    set rtp+=$PLUGIN_PATH
    filetype plugin indent on
    syntax enable
  ) -c "Vader! $1"

  if [[ $? == 0 ]]
  then
    VADER_RESULTS+=("$GREEN + SUCCESS: $1 $NC")
  else
    VADER_RESULTS+=("$RED - FAIL: $1 $NC")
    RESULT=1
  fi
}

for test in $VADER_TESTS
do 
  if [[ "$VADER_TESTS" == '*.vader' ]] 
  then
    run $test &> /dev/null
  else
    run $test
  fi  
done

printf '%b\n' "${VADER_RESULTS[@]}"

exit $RESULT