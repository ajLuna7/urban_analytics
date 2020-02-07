#!/bin/bash
# don't forget to set permissions chmod 0755 script.sh

curl -o ../data/ny_trees2005.csv https://data.cityofnewyork.us/api/views/29bw-z7pj/rows.csv?accessType=DOWNLOAD

# is this their a better way to write this? 
cd ../data && \
wget -O file.zip "https://data.cityofnewyork.us/api/geospatial/cpf4-rkhq?method=export&format=Original" && \
unzip file.zip && \
rm file.zip