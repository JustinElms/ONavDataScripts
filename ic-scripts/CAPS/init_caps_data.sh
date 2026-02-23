#!/usr/bin/env bash

# Initializes best estimate for CAPS datasets.

DATE=$(date -d "-6 months" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) < $(date -d "${END_DATE}" +%s) )); do

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_caps/3km; then
        # Download data for the current date
        INC_ARR=( "--include "{001..012}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror -c --parallel=5 ${INCLUDE} --exclude-glob '*.grib2' model_caps/ model_caps/ ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/
    fi

    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)

done

ssh ubuntu@u2204-icechunk "cd icechunk/ ; python3 ic_interface/add_nc_data.py caps_fc_2drp -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python3 ic_interface/add_nc_data.py caps_fc_3drp -s"