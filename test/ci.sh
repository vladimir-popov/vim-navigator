#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

VADER_RESULTS=("${GREEN}Results:$NC")
RESULT=0

for test in ./test/*.vader
do 
  vim -EsNu ./test/vimrc.ci -c "Vader! $test"

  if [[ $? == 0 ]]
  then
    VADER_RESULTS+=("$GREEN + SUCCESS: $test $NC")
  else
    VADER_RESULTS+=("$RED - FAIL: $test $NC")
    RESULT=1
  fi
done

printf '%b\n' "${VADER_RESULTS[@]}"

exit $RESULT
