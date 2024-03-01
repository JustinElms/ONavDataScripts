#!/usr/bin/env bash

# Indexes latest GIOPS 10 day forecast data. 
# Place this script in Indexing LXD container and run it from index_giops.sh on host.
# Takes 1 argument - RUN - the forecast run to be indexed. Should be 00 or 12

RUN=$1

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/giops-fc2dll-10day.sqlite3 ] && rm ${HOME}/db/giops-fc2dll-10day.sqlite3
[ -f ${HOME}/db/giops-fc3dll-10day.sqlite3 ] && rm ${HOME}/db/giops-fc3dll-10day.sqlite3
[ -f ${HOME}/netcdf-timestamp-mapper/giops-fc2dll-10day.txt ] && rm ${HOME}/netcdf-timestamp-mapper/giops-fc2dll-10day.txt
[ -f ${HOME}/netcdf-timestamp-mapper/giops-fc3dll-10day.txt ] && rm ${HOME}/netcdf-timestamp-mapper/giops-fc3dll-10day.txt

# Add yesterday's best estimate data to archive
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll-10day-${RUN}-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/2d/${RUN}/012/ -o ${HOME}/db -h
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc3dll-10day-${RUN}-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/${RUN}/ -o ${HOME}/db -h

if [ $RUN == 12 ]
then
    cp ${HOME}/db/giops-fc2dll-10day-12-archive.sqlite3 ${HOME}/db/giops-fc2dll-10day.sqlite3
    cp ${HOME}/db/giops-fc3dll-10day-12-archive.sqlite3 ${HOME}/db/giops-fc3dll-10day.sqlite3
elif [ $RUN == 00 ]
then
    cp ${HOME}/db/giops-fc2dll-10day-00-archive.sqlite3 ${HOME}/db/giops-fc2dll-10day.sqlite3
    cp ${HOME}/db/giops-fc3dll-10day-00-archive.sqlite3 ${HOME}/db/giops-fc3dll-10day.sqlite3
fi

cd ${HOME}/netcdf-timestamp-mapper

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/2d/${RUN}/{012..240..024}/ -type f > giops-fc2dll-10day.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll-10day -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/ -o ${HOME}/db --file-list giops-fc2dll-10day.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/${RUN}/ -type f > giops-fc3dll-10day.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc3dll-10day -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/ -o ${HOME}/db --file-list giops-fc3dll-10day.txt  -h

mv {$HOME}/db/giops-fc2dll-10day.sqlite3 /data/db/
mv {$HOME}/db/giops-fc3dll-10day.sqlite3 /data/db/