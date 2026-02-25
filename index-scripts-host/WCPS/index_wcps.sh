#!/usr/bin/env bash

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
lftp -e "mirror --parallel=5 --exclude PrecipRate --exclude PrecipAccum --exclude RainAccum --exclude Runoff --exclude SnowfallAccum model_wcps . ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/
        
# Index new dataset
ssh ubuntu@u2004-index "cd index-scripts-remote/WCPS/ ; bash wcps.sh"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py wcps_2dll --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps"

# remove yesterday's forecast data 

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_wcps