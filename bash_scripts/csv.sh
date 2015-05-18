#!/usr/bin/env bash

data="name,sex,rollno,location"

#To read each of the item in a variable, we can use IFS.
(
  IFS=","

  for item in $data; do
    echo Item: $item
  done
)
