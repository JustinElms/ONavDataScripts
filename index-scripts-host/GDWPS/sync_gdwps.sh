#!/usr/bin/env bash

# Downloads and indexes latest GDWPS model data

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps

cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD
lftp -e "lcd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/  ; mirror --parallel=5 model_gdwps model_gdwps ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/

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

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
python ${CWD}/process_gdwps.py /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/25km/
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py gdwps_2dll --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/25km/00/"

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_gdwps