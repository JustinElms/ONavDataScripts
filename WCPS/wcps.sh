#!/usr/bin/env bash

DATE=$(date +%Y%m%d)

[ -f ${HOME}/wcps-file.txt ] && rm ${HOME}/wcps-file.txt

# for WCPS /18 is the oldest data in a directory
if [  -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/12 ]; then
  find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/12 -type f > ${HOME}/wcps-file.txt
elif [  -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/06 ]; then
  find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/06 -type f > ${HOME}/wcps-file.txt
elif [  -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/00 ]; then
  find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/00 -type f > ${HOME}/wcps-file.txt
elif [ -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/18 ]; then
  find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/ocean-atmosphere/1km/18 -type f > ${HOME}/wcps-file.txt
fi

[ -f ${HOME}/db/wcps-2dll.sqlite3 ] && rm ${HOME}/db/wcps-2dll.sqlite3
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n wcps-2dll -i /data/hpfx.collab.science.gc.ca -o ${HOME}/db --file-list ${HOME}/wcps-file.txt -h
