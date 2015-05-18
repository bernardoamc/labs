#!/usr/bin/env bash

echo -e "Enter password: "
stty -echo  # Disable echo when typying on terminal
read password
stty echo   # Enable echo again
echo
echo Password read.
