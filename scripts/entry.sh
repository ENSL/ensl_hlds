#!/bin/bash

cd /home/steam/hlds

echo "in entry_steam.sh"
env|grep HL

if [[ "$HLDS_ROTATE" = "1" ]]; then
 which lz4 &>/dev/null || echo "LZ4 not found."
 ./rotate_logs.sh >> /home/steam/hlds/ns/logs/rotate.log &
 echo "Rotating logs in background."
fi
if [[ "$HLTV_ROTATE" = "1" ]]; then
 which lz4 &>/dev/null || echo "LZ4 not found."
 ./rotate_demos.sh >> /home/steam/hlds/ns/demos/rotate.log
 echo "Rotating demos in background."
fi

if [[ "$HLTV" = "1" ]]; then
  echo "Starting HLTV"
  sleep 10
  export LD_LIBRARY_PATH=.
  set -o xtrace
  ./hltv $HLTV_OPTS >> /home/steam/hltv-`date +%F-%h:%m`.log
  set +o xtrace
  echo "Started"
elif [[ "$HLDS" = "1" ]]; then
  echo "Starting HLDS"
  set -o xtrace
  export LD_LIBRARY_PATH=.
  ./hlds_run $HLDS_OPTS
  set +o xtrace
  echo "Started"
fi

bash
