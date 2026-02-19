#!/usr/bin/env bash

# Downloads and indexes latest CAPS model forecast

DATE=$(date +%Y%m%d)

# Get new data
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
lftp -e "mirror -c --parallel=5 --exclude-glob '*.grib2' model_caps/ model_caps/ ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/

ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py caps_fc_2drp -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py caps_fc_3drp -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/"