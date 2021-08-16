#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

for test in ./test/*.vader
do 
  nvim -EsNu <(cat << EOF
    filetype off
    set rtp+=.
    set rtp+=vader.vim
    filetype plugin indent on
    syntax enable
  ) -c "Vader! $1"

  if [[ $? == 0 ]]
  then
    VADER_RESULTS+=("$GREEN + SUCCESS: $1 $NC")
    RESULT=0
  else
    VADER_RESULTS+=("$RED - FAIL: $1 $NC")
    RESULT=1
  fi
done

printf '%b\n' "${VADER_RESULTS[@]}"

exit $RESULT
