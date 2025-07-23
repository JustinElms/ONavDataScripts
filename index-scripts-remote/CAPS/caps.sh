#!/usr/bin/env bash

# Indexes latest CAPS model forecast data.
# Place this script in Indexing LXD container and run it from index_caps.sh on host.

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/caps-fc2drp.sqlite3 ] && rm ${HOME}/db/caps-fc2drp.sqlite3
[ -f ${HOME}/db/caps-fc3drp.sqlite3 ] && rm ${HOME}/db/caps-fc3drp.sqlite3
[ -f ${HOME}/db/caps-fc2drp.txt ] && rm ${HOME}/db/caps-fc2drp.txt
[ -f ${HOME}/db/caps-fc3drp.txt ] && rm ${HOME}/db/caps-fc3drp.txt

# Add yesterday's best estimate data to archive
find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/ -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2drp.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc2drp-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc2drp.txt -h
find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/ -name \*all\*.nc -type f > ${HOME}/db/caps-fc3drp.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc3drp-archive -i /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc3drp.txt -h

# Add today's earlier runs to archive
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/${RUNS[$IDX]} -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2drp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc2drp-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc2drp.txt -h
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/${RUNS[$IDX]} -name \*all\*.nc -type f > ${HOME}/db/caps-fc3drp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc3drp-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc3drp.txt -h
    fi
done

# Create new index db from archive
cp ${HOME}/db/caps-fc2drp-archive.sqlite3 ${HOME}/db/caps-fc2drp.sqlite3
cp ${HOME}/db/caps-fc3drp-archive.sqlite3 ${HOME}/db/caps-fc3drp.sqlite3

# Create new index db from archive
cp ${HOME}/db/riops-fc2dps-archive.sqlite3 ${HOME}/db/riops-fc2dps.sqlite3
cp ${HOME}/db/riops-fc3dps-archive.sqlite3 ${HOME}/db/riops-fc3dps.sqlite3

# Index latest data
find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/${RUNS[-1]} -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2drp.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc2drp -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc2drp.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/${RUNS[-1]}  -name \*all\*.nc -type f > ${HOME}/db/caps-fc3drp.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc3drp -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc3drp.txt -h

# replace production dataset db
mv ${HOME}/db/caps-fc3drp.sqlite3 /data/db
mv ${HOME}/db/caps-fc2drp.sqlite3 /data/db
