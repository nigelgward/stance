#!/bin/bash
# to be run in a directory full of .flac files; will create the corresponding au files
# takes about a second per file, hence 10 minutes for a typical lorelei release
for filename in *flac; do
    echo sox $filename -r 8000 $(basename "$filename" .flac).au
    sox $filename -r 8000 $(basename "$filename" .flac).au
done
			    
		
