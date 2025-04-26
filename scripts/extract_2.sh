#!/usr/bin/env bash

## EXTRACT FOR AP, BL, CP, HOME_CSC FILES ##

# UNPACK AP ARCHIVE #

mkdir -p $EXTRPRJ $PARTPRJ

for part in "$AP" "$CP" "$CSC" "$BL"; do
    for file in "$part"/*.lz4; do
        [ -e "$file" ] || continue  # Skip if no files
        outname=$(basename "$file" .lz4)
        lz4 -d "$file" "$EXTRPRJ/$outname"
    done
done

