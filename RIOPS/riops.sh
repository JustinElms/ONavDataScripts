#!/usr/bin/env bash

# Indexes latest RIOPS forecast data. 
# Place this script in Indexing LXD container and run it from index_riops.sh on host.

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/riops-fc2dps.sqlite3 ] && rm ${HOME}/db/riops-fc2dps.sqlite3
[ -f ${HOME}/db/riops-fc3dps.sqlite3 ] && rm ${HOME}/db/riops-fc3dps.sqlite3
[ -f ${HOME}/netcdf-timestamp-mapper/riops-fc2dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/riops-fc2dps.txt
[ -f ${HOME}/netcdf-timestamp-mapper/riops-fc3dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/riops-fc3dps.txt

# Add yesterday's best estimate data to archive
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/forecast/polar_stereographic/2d/ -o ${HOME}/db -h
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/forecast/polar_stereographic/3d/ -o ${HOME}/db -h

cp ${HOME}/db/riops-fc2dps-archive.sqlite3 ${HOME}/db/riops-fc2dps.sqlite3
cp ${HOME}/db/riops-fc3dps-archive.sqlite3 ${HOME}/db/riops-fc3dps.sqlite3

cd ${HOME}/netcdf-timestamp-mapper

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/ -type f > riops-fc2dps.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/ -o ${HOME}/db --file-list riops-fc2dps.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/ -type f > riops-fc3dps.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/ -o ${HOME}/db --file-list riops-fc3dps.txt  -h