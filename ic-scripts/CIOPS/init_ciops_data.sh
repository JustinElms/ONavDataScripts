#!/usr/bin/env bash

# Initializes best estimate for CIOPS datasets.
DATE=$(date -d "-6 months" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/; then
        # Download data for the current date
        INC_ARR=( "--include /"{000..006}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")  
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror --parallel=5 ${INCLUDE} model_ciops model_ciops ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/
    fi
    
done

ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-east_fc_2dll -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-east_fc_3dll -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-west_fc_2dll -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-west_fc_3dll -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-salish-sea_fc_2dll -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-salish-sea_fc_3dll -s"