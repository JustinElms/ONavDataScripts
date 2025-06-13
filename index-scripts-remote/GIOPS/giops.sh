#!/usr/bin/env bash

# Indexes latest GIOPS 10 day forecast data.
# Place this script in Indexing LXD container and run it from index_giops.sh on host.

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/giops-fc2dll.sqlite3 ] && rm ${HOME}/db/giops-fc2dll.sqlite3
[ -f ${HOME}/db/giops-fc3dll-10day.sqlite3 ] && rm ${HOME}/db/giops-fc3dll-10day.sqlite3
[ -f ${HOME}/db/giops-fc2dll.txt ] && rm ${HOME}/db/giops-fc2dll.txt
[ -f ${HOME}/db/giops-fc3dll-10day.txt ] && rm ${HOME}/db/giops-fc3dll-10day.txt

if [ -d http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/12/ ]
then
    RUN="12"
else
    RUN="00"
fi

# Add yesterday's best estimate data to archive
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/2d/ -o ${HOME}/db -h
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc3dll-10day-${RUN}-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/${RUN}/ -o ${HOME}/db -h

cp ${HOME}/db/giops-fc2dll-archive.sqlite3 ${HOME}/db/giops-fc2dll.sqlite3
cp ${HOME}/db/giops-fc3dll-10day-${RUN}-archive.sqlite3 ${HOME}/db/giops-fc3dll-10day.sqlite3

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/2d/ -type f > ${HOME}/db/giops-fc2dll.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/ -o ${HOME}/db --file-list ${HOME}/db/giops-fc2dll.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/${RUN}/ -type f > ${HOME}/db/giops-fc3dll-10day.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ${HOME}/db/giops-fc3dll-10day -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/ -o ${HOME}/db --file-list ${HOME}/db/giops-fc3dll-10day.txt  -h

mv ${HOME}/db/giops-fc2dll.sqlite3 /data/db/
mv ${HOME}/db/giops-fc3dll-10day.sqlite3 /data/db/
