#!/usr/bin/env bash

# Indexes historical datasets that will be exanded upon by new data

cd ${HOME}/netcdf-timestamp-mapper

rm ${HOME}/db/riops-fc2dps-archive.sqlite3
rm ${HOME}/db/riops-fc3dps-archive.sqlite3

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/ -type f > riops-fc2dps-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc2dps-archive -i /data/hpfx.collab.science.gc.ca/$(date +%Y%m%d)/WXO-DD/model_riops/ -o ${HOME}/db --file-list riops-fc2dps-archive.txt -h

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/ -type f > riops-fc3dps-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n riops-fc3dps-archive -i /data/hpfx.collab.science.gc.ca/$(date +%Y%m%d)/WXO-DD/model_riops/ -o ${HOME}/db --file-list riops-fc3dps-archive.txt -h