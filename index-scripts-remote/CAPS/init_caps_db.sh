#!/usr/bin/env bash

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_caps/3km/ -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2drp.txt

# Indexes historical datasets that will be exanded upon by new data

rm ${HOME}/db/caps-fc2drp-archive.sqlite3
rm ${HOME}/db/caps-fc3drp-archive.sqlite3

DATE=$(date -d "-2 years" +%Y%m)
ENDDATE=$(date +%Y%m)

while [ $DATE -le $ENDDATE ]; do
    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_caps/3km/ -name \*Sfc\*.nc -type f > ${HOME}/db/caps-fc2drp.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc2drp-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc2drp.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_caps/3km/ -name \*all\*.nc -type f > ${HOME}/db/caps-fc3drp.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc3drp-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc3drp.txt -h

    DATE=$(date -d "${DATE}01 + 1 month" +%Y%m)
done