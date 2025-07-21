#!/usr/bin/env bash

# Indexes historical datasets that will be exanded upon by new data

cd ${HOME}/netcdf-timestamp-mapper

rm ${HOME}/db/caps-fc2dps-archive.sqlite3
rm ${HOME}/db/caps-fc3dps-archive.sqlite3

DATE=$(date -d "-2 years" +%Y%m)
ENDDATE=$(date +%Y%m)

while [ $DATE -le $ENDDATE ]; do
    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_caps/3km/ -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2dps.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc2dps-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc2dps.txt -h
    
    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_caps/3km/ -name \*all\*.nc -type f > ${HOME}/db/caps-fc3dps.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc3dps-archive -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc3dps.txt -h

    DATE=$(date -d "${DATE}01 + 1 month" +%Y%m)
done