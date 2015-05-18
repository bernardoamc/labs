#!/usr/bin/env bash

declare -A modules
modules=(['analysis-core']='1.49' ['audit-trail']='1.8' ['brakeman']='0.7' ['build-pipeline-plugin']='1.33' ['clone-workspace-scm']='0.5' ['copyartifact']='1.27' ['envinject']='1.88' ['feature-branch-notifier']='1.1' ['parameterized-trigger']='2.19' ['jenkins-multijob-plugin']='1.9' ['mercurial']='1.46' ['external-monitor-job']='1.1' ['rake']='1.7.7' ['ssh-slaves']='0.25')

for name in ${!modules[@]}; do
  echo "Downloading ${name}: ${modules[$name]}"
  $(curl -Lo "plugins/${name}-${modules[$name]}.hpi" "https://updates.jenkins-ci.org/download/plugins/${name}/${modules[$name]}/${name}.hpi")
done
