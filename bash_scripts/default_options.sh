#!/usr/bin/env bash

defined="sim"

# Imprime a variavel declarada ou um default
echo ${defined:-"default"}
echo ${undefined:-"default"}

# Imprime o default se a variavel esta declarada
echo ${defined:+"default"}

# Declara a variavel e imprime a mesma
echo ${undefined:="teste"}
echo $undefined
