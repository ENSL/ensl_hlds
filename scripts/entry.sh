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
  export LD_LIBRARY_PATH=.
  ./hltv +serverpassword europe +connect localhost:27015 +record demos/gathers >> /home/steam/hlds/ns/demos/hltv-`date +%F-%h:%m`.log
elif [[ "$HLDS" = "1" ]]; then
  echo "Starting HLDS"
  export LD_LIBRARY_PATH=.
  ./hlds_run -game ns +maxplayers 32 +log on +map ns_veil +exec ns/server.cfg -pingboost 3 +sys_ticrate 1000
fi

bash