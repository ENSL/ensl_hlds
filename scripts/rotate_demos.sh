#!/bin/bash

rotateFiles() {
 file="$0".zip
 if test -f "$file";
   then rm "$0" && echo "Removed: $0"
 else
   zip -9 --quiet -r "$0.zip" "$0" && rm "$0" && echo "Rotated: $0"
 fi
}

while true; do 
 export -f rotateFiles
 find . -maxdepth 1 -iname '*.dem' -mmin +30 -exec bash -c 'rotateFiles "$0"' {} \;
 sleep 300
done
