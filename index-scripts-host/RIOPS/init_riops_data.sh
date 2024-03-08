#!/usr/bin/env bash

# Initializes best estimate for RIOPS datasets.

DATE=$(date -d "-1 years" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf; then
        # Download data for the current date
        INC_ARR=( "--include "{000..005}"/" )
        INCLUDE=$(printf "%s " "${INC_ARR[@]}")  
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
        lftp -e "mirror --parallel=5 ${INCLUDE} model_riops model_riops ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/{2d,3d}/{00..18..06}/{006..084}
    fi
done

ssh ubuntu@u2004-index "cd index-scripts-remote/RIOPS/ ; bash init_riops_db.sh"