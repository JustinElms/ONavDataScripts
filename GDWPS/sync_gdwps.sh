#!/usr/bin/env bash

# Downloads and indexes latest GIOPS model data for 10 day forecast

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

DATE=$(date +%Y%m%d)

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps

cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD
lftp -e "lcd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/  ; mirror --parallel=5 model_gdwps model_gdwps ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

# additions to create symlinks for latest data
rm -r /data/thredds/model_links/model_gdwps/*

if [ -d "/data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/25km/12/" ]
then
  DATA=/data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/25km/12/*.grib2
else
  DATA=/data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/25km/00/*.grib2
fi 

for f in $DATA
do
   ln -s $f /data/thredds/model_links/model_gdwps/
done

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_gdwps