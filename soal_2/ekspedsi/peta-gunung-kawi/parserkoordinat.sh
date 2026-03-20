#!/bin/bash

grep -E '"id":|"site_name":|"latitude":|"longitude":' gsxtrack.json | \
sed -E 's/.*"id": "([^"]+)".*/\1/' | \
sed -E 's/.*"site_name": "([^"]+)".*/\1/' | \
sed -E 's/.*"latitude": ([-.0-9]+).*/\1/' | \
sed -E 's/.*"longitude": ([-.0-9]+).*/\1/' | \
awk '{
    if (NR%4 == 1) id=$0
    else if (NR%4 == 2) site=$0
    else if (NR%4 == 3) lat=$0
    else if (NR%4 == 0) print id "," site "," lat "," $0
}' | sort > titik-penting.txt 

echo "Parsing i mari cak. tak simpen ndek : titik-penting.txt"
