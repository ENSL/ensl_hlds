#!/bin/bash

function rotateLogs() {
 while true; do 
   cd /home/steam/hlds/ns/logs || exit 1
   find . -iname '*.log' -mmin +60 -printf 'Rotated: %p\n' -exec lz4 -z -9 -q "{}" "{}.lz" \;
   sleep 300
 done
}

if [ -z $ROTATE_LOGS ]; then
 which lz4 &>/dev/null || echo "LZ4 not found."
 rotateLogs >> /home/steam/hlds/ns/logs/rotate_logs.log &
 echo "Rotating logs."
fi

./hlds_run -game ns +maxplayers 32 +log on +map ns_veil +exec ns/server.cfg
bash
