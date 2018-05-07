#!/bin/bash

rotateFiles() {
 file="$0".lz4
 if test -f "$file";
   then rm "$0" && echo "Removed: $0"
 else
   lz4 -9 -z -q "$0.lz4" "$0" && rm "$0" && echo "Rotated: $0"
 fi
}

while true; do 
 export -f rotateFiles
 find . -maxdepth 1 -iname '*.log' -mmin +30 -exec bash -c 'rotateFiles "$0"' {} \;
 sleep 300
done
