#!/usr/bin/env bash

# Indexes historical datasets that will be exanded upon by new data

cd ${HOME}/netcdf-timestamp-mapper

rm ${HOME}/db/ciops-east-2d-archive.sqlite3
rm ${HOME}/db/ciops-west-2d-archive.sqlite3
rm ${HOME}/db/ciops-salish-2d-archive.sqlite3
rm ${HOME}/db/ciops-east-3d-archive.sqlite3
rm ${HOME}/db/ciops-west-3d-archive.sqlite3
rm ${HOME}/db/ciops-salish-3d-archive.sqlite3

DATE=$(date -d "-1 years" +%Y%m)
ENDDATE=$(date +%Y%m)

while [ $DATE -le $ENDDATE ]; do 

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/east/ -type f | grep -E "(Sfc|0.5m)" > ciops-east-2d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-2d-archive.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/east -type f -name "*-all_*.nc" > ciops-east-3d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-east-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-east-3d-archive.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/west/ -type f | grep -E "(Sfc|0.5m)" > ciops-west-2d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-2d-archive.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/west/ -type f -name "*-all_*.nc" > ciops-west-3d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-west-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-west-3d-archive.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/salish-sea/ -type f | grep -E "(Sfc|0.5m)" > ciops-salish-2d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-2d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-2d-archive.txt -h

    find /data/hpfx.collab.science.gc.ca/${DATE}*/WXO-DD/model_ciops/salish-sea/ -type f -name "*-all_*.nc" > ciops-salish-3d-archive.txt
    ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ciops-salish-3d-archive -i /data/hpfx.collab.science.gc.ca/ -o ${HOME}/db --file-list ciops-salish-3d-archive.txt -h

    DATE=$(date -d "${DATE}01 + 1 month" +%Y%m)
done