#!/usr/bin/env bash

declare -A fruits
fruits=([apple]='100 dollars' [orange]='150 dollars')

echo ${fruits[apple]}
echo "Array indexes: ${!fruits[*]}"

for i in ${!fruits[@]}; do
  echo "${i}: ${fruits[$i]}"
done
