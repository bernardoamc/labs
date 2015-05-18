#!/usr/bin/env bash

echo $(ls)

if [ $? -eq 0 ]; then
  echo "executed successfully"
else
  echo "terminated unsuccessfully"
fi
