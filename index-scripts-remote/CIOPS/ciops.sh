#!/usr/bin/env bash

# Indexes latest RIOPS forecast data.
# Place this script in Indexing LXD container and run it from index_ciops.sh on host.

python ${HOME}/index-scripts-remote/clean_archive_dbs.py

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

[ -f ${HOME}/db/ciops-east_fc_2dl.sqlite3 ] && rm ${HOME}/db/ciops-east_fc_2dl.sqlite3
[ -f ${HOME}/db/ciops-east_fc_3dll.sqlite3 ] && rm ${HOME}/db/ciops-east_fc_3dll.sqlite3
[ -f ${HOME}/db/ciops-west_fc_2dl.sqlite3 ] && rm ${HOME}/db/ciops-west_fc_2dl.sqlite3
[ -f ${HOME}/db/ciops-west_fc_3dll.sqlite3 ] && rm ${HOME}/db/ciops-west_fc_3dll.sqlite3
[ -f ${HOME}/db/ciops-salish_fc_2dl.sqlite3 ] && rm ${HOME}/db/ciops-salish_fc_2dl.sqlite3
[ -f ${HOME}/db/ciops-salish_fc_3dll.sqlite3 ] && rm ${HOME}/db/ciops-salish_fc_3dll.sqlite3

[ -f ${HOME}/netcdf-timestamp-mapper/ciops-east_fc_2dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-east_fc_2dll.txt
[ -f ${HOME}/netcdf-timestamp-mapper/ciops-east_fc_3dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-east_fc_3dll.txt
[ -f ${HOME}/netcdf-timestamp-mapper/ciops-west_fc_2dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-west_fc_2dll.txt
[ -f ${HOME}/netcdf-timestamp-mapper/ciops-west_fc_3dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-west_fc_3dll.txt
[ -f ${HOME}/netcdf-timestamp-mapper/ciops-salish_fc_2dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-salish_fc_2dll.txt
[ -f ${HOME}/netcdf-timestamp-mapper/ciops-salish_fc_3dll.txt ] && rm ${HOME}/netcdf-timestamp-mapper/ciops-salish_fc_3dll.txt

# Add yesterday's best estimate data to archive
find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/east/2km/{000..005} -type f | grep -E "(Sfc|0.5m)" > ciops-east-2d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-2d-archive.txt -h

find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/east/2km/{000..005} -type f -name "*-all_*.nc" > ciops-east-3d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-3d-archive.txt -h

find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/west/2km/{000..005} -type f | grep -E "(Sfc|0.5m)" > ciops-west-2d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-2d-archive.txt -h

find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/west/2km/{000..005} -type f -name "*-all_*.nc" > ciops-west-3d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-3d-archive.txt -h

find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/salish-sea/500m/{001..006} -type f | grep -E "(Sfc|0.5m)" > ciops-salish-2d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-2d-archive.txt -h

find /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/salish-sea/500m/{001..006} -type f -name "*-all_*.nc" > ciops-salish-3d-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-3d-archive.txt -h

# Add today's earlier runs to archive
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/${RUNS[$IDX]}/{000..005}  -type f | grep -E "(Sfc|0.5m)" > ciops-east-2d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-2d-temp.txt -h
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/${RUNS[$IDX]}/{000..005}  -type f -name "*-all_*.nc" > ciops-east-3d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-3d-temp.txt -h

        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/${RUNS[$IDX]}/{000..005}  -type f | grep -E "(Sfc|0.5m)" > ciops-west-2d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-2d-temp.txt -h
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/${RUNS[$IDX]}/{000..005}  -type f -name "*-all_*.nc" > ciops-west-3d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-3d-temp.txt -h

        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUNS[$IDX]}/{001..006}  -type f | grep -E "(Sfc|0.5m)" > ciops-salish-2d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-2d-temp.txt -h
        find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUNS[$IDX]}/{001..006}  -type f -name "*-all_*.nc" > ciops-salish-3d-temp.txt
        ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-3d-temp.txt -h                
    fi
done

# Create new index db from archive

cp ${HOME}/db/ciops-east-2d-archive.sqlite3 ${HOME}/db/ciops-east_fc_2dll.sqlite3
cp ${HOME}/db/ciops-east-3d-archive.sqlite3 ${HOME}/db/ciops-east_fc_3dll.sqlite3

cp ${HOME}/db/ciops-west-2d-archive.sqlite3 ${HOME}/db/ciops-west_fc_2dll.sqlite3
cp ${HOME}/db/ciops-west-3d-archive.sqlite3 ${HOME}/db/ciops-west_fc_3dll.sqlite3

cp ${HOME}/db/ciops-salish-2d-archive.sqlite3 ${HOME}/db/ciops-salish_fc_2dll.sqlite3
cp ${HOME}/db/ciops-salish-3d-archive.sqlite3 ${HOME}/db/ciops-salish_fc_3dll.sqlite3

# Index latest data

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/${RUNS[-1]}  -type f | grep -E "(Sfc|0.5m)" > ciops-east-2d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east_fc_2dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-east-2d.txt -h
find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/${RUNS[-1]}  -type f -name "*-all_*.nc" > ciops-east-3d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east_fc_3dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-east-3d.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/${RUNS[-1]}  -type f | grep -E "(Sfc|0.5m)" > ciops-west-2d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west_fc_2dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-west-2d.txt -h
find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/${RUNS[-1]}  -type f -name "*-all_*.nc" > ciops-west-3d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west_fc_3dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-west-3d.txt -h

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUNS[-1]}  -type f | grep -E "(Sfc|0.5m)" > ciops-salish-2d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish_fc_2dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-salish-2d.txt -h
find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUNS[-1]}  -type f -name "*-all_*.nc" > ciops-salish-3d.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish_fc_3dll -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/ -o ${HOME}/db --file-list ciops-salish-3d.txt -h

mv ${HOME}/db/ciops-east_fc_2dll.sqlite3 /data/db/
mv ${HOME}/db/ciops-east_fc_3dll.sqlite3 /data/db/

mv ${HOME}/db/ciops-west_fc_2dll.sqlite3 /data/db/
mv ${HOME}/db/ciops-west_fc_3dll.sqlite3 /data/db/

mv ${HOME}/db/ciops-salish_fc_2dll.sqlite3 /data/db/
mv ${HOME}/db/ciops-salish_fc_3dll.sqlite3 /data/db/