#!/usr/bin/env bash
#
# Usage: ./placar-log [dev|qa|stage|prod]
#
# Ctrl+C to exit.

ENV="$1"

echo "Logs for placar-$ENV-01 and placar-$ENV-02"
echo
echo

ssh placar-$ENV-01 "tail -f /abd/app/placar-site/log/$ENV.log" &
PID1=$!

ssh placar-$ENV-02 "tail -f /abd/app/placar-site/log/$ENV.log" &
PID2=$!

close_connection () {
  kill -15 $PID1 $PID2 &>/dev/null
}

trap close_connection SIGINT

wait $PID1
wait $PID2
