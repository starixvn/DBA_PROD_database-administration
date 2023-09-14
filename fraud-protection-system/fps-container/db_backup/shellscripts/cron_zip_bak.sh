#!/bin/sh

#declare variables
extension="bak"
source_path="/mount/fps/t1/"
dest_path="/mount/fps/t1/bk_zip"

#loop and zip
for i in `find $source_path | grep -E "\.$extension$"`
do 
    empty=""

    pathfile=$(echo "$i" | sed "s|$source_path|$empty|")

    #zip to seperate files
    7z a -y $dest_path/"$pathfile".7z "$i";
    
done
