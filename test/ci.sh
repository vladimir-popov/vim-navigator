#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

VADER_RESULTS=("${GREEN}Results:$NC")
RESULT=0

vim -EsNu ./test/vimrc.ci -c "Vader! ./test/render.vader"
