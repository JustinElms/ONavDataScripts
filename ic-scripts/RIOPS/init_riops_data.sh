#!/usr/bin/env bash

# Initializes best estimate for RIOPS datasets.

DATE=$(date -d "-6 months" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) < $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_riops/netcdf; then
        # Download data for the current date
        INC_ARR=( "--include "{000..005}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")  
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror --parallel=5 ${INCLUDE} model_riops model_riops ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/
    fi

done

ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py riops_fc_2dps -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py riops_fc_3dps -s"