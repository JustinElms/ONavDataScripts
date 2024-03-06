#!/usr/bin/env bash

# Indexes historical datasets that will be exanded upon by new data

cd ${HOME}/netcdf-timestamp-mapper

rm ${HOME}/db/giops-fc2dll-archive.sqlite3
rm ${HOME}/db/giops-fc3dll-10day-00-archive.sqlite3
rm ${HOME}/db/giops-fc3dll-10day-12-archive.sqlite3

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_giops/netcdf/lat_lon/2d/00/012/ -type f > giops-fc2dll-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll-archive -i /data/hpfx.collab.science.gc.ca/$(date +%Y%m%d)/WXO-DD/model_giops/ -o ${HOME}/db --file-list giops-fc2dll-archive.txt -h

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_giops/netcdf/lat_lon/3d/00/000/ -type f > giops-fc3dll-10day-00-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc3dll-10day-00-archive -i /data/hpfx.collab.science.gc.ca/$(date +%Y%m%d)/WXO-DD/model_giops/ -o ${HOME}/db --file-list giops-fc3dll-10day-00-archive.txt -h

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_giops/netcdf/lat_lon/3d/12/024/ -type f > giops-fc3dll-10day-12-archive.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc3dll-10day-12-archive -i /data/hpfx.collab.science.gc.ca/$(date +%Y%m%d)/WXO-DD/model_giops/ -o ${HOME}/db --file-list giops-fc3dll-10day-12-archive.txt -h