#!/usr/bin/env bash

# Initializes best estimate for CAPS datasets.

DATE=20250721 # Data prior to 2025-07-21 contains incorrect lat/lon info and cannot be used
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km; then
        # Download data for the current date
        INC_ARR=( "--include "{000..012}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")  
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror -c --parallel=5 --include /"*.nc" ${INCLUDE} model_caps/ model_caps/ ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
    fi
    
    rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/{00,12}/{013..048}

done

ssh ubuntu@u2004-index "cd index-scripts-remote/CAPS/ ; bash init_caps_db.sh"