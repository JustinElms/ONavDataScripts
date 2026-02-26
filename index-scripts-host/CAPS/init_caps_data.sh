#!/usr/bin/env bash

# Initializes best estimate for CAPS datasets.

DATE=$(date -d 2025-07-21 +%Y%m%d) # Data prior to 2025-07-21 contains incorrect lat/lon info and cannot be used
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    echo $DATE

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_caps/3km; then
        # Download data for the current date
        INC_ARR=( "--include "{001..012}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror -c --parallel=5 ${INCLUDE} --exclude-glob '*.grib2' model_caps/ model_caps/ ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/
    fi

    rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/{00,12}/{013..048}

    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
done

ssh ubuntu@u2004-index "cd index-scripts-remote/CAPS/ ; bash init_caps_db.sh"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py caps_fc_2drp -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py caps_fc_3drp -s"