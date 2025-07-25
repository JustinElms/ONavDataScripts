#!/usr/bin/env bash

# Indexes latest RIOPS forecast data.
# Place this script in Indexing LXD container and run it from index_riops.sh on host.

python ${HOME}/index-scripts-remote/clean_archive_dbs.py

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/riops-fc2dps.sqlite3 ] && rm ${HOME}/db/riops-fc2dps.sqlite3
[ -f ${HOME}/db/riops-fc3dps.sqlite3 ] && rm ${HOME}/db/riops-fc3dps.sqlite3
[ -f ${HOME}/db/riops-fc2dll.txt ] && rm ${HOME}/db/riops-fc2dps.txt
[ -f ${HOME}/db/riops-fc3dll.txt ] && rm ${HOME}/db/riops-fc3dps.txt

# Add yesterday's best estimate data to archive
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/forecast/polar_stereographic/2d/ -o ${HOME}/db -h
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/forecast/polar_stereographic/3d/ -o ${HOME}/db -h

# Add today's earlier runs to archive
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/forecast/polar_stereographic/2d/${RUNS[$IDX]} -o ${HOME}/db -h
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/forecast/polar_stereographic/3d/${RUNS[$IDX]} -o ${HOME}/db -h
    fi
done

# Create new index db from archive
cp ${HOME}/db/riops-fc2dps-archive.sqlite3 ${HOME}/db/riops-fc2dps.sqlite3
cp ${HOME}/db/riops-fc3dps-archive.sqlite3 ${HOME}/db/riops-fc3dps.sqlite3

# Index latest data
find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/${RUNS[-1]} -type f > ${HOME}/db/riops-fc2dps.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/ -o ${HOME}/db --file-list ${HOME}/db/riops-fc2dps.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/${RUNS[-1]} -type f > ${HOME}/db/riops-fc3dps.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/ -o ${HOME}/db --file-list ${HOME}/db/riops-fc3dps.txt  -h

find /data/depot.cmc.ec.gc.ca/ftp/cmoi/dfo/dfo.ccg/ -type f -print | grep $(date +%Y%m%d) | tail -1 > ${HOME}/db/riops-fc2dll.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dll -i /data/depot.cmc.ec.gc.ca/ftp/cmoi/dfo/dfo.ccg -o ${HOME}/db --file-list ${HOME}/db/riops-fc2dll.txt -h

# replace production dataset db

mv ${HOME}/db/riops-fc2dps.sqlite3 /data/db/
mv ${HOME}/db/riops-fc3dps.sqlite3 /data/db/
mv ${HOME}/db/riops-fc2dll.sqlite3 /data/db/