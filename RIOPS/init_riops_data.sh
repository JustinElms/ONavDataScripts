#!/usr/bin/env bash

# Initializes best estimate for GIOPS datasetsinit_giops_data.
DATE=$(date -d "-1 years" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf; then
        # Download data for the current date
        DATE=$(date -d "${DATE} +1 days" +%Y%m%d)

        # Download data for the current date
        EXC_ARR=( "--exclude "{006..084}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")        
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "lcd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/  ; mirror --parallel=5 ${EXCLUDE} model_riops model_riops ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
    fi
done

ssh ubuntu@u2004-index "cd index-scripts ; ./init_riops_db.sh"