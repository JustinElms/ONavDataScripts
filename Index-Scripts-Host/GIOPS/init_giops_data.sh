#!/usr/bin/env bash

# Initializes best estimate for GIOPS datasetsinit_giops_data.
DATE=$(date -d "-1 years" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past year
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf; then
        # Download data for the current date
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon

        EXC_ARR=( "--exclude "{015..240..003}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 --exclude 000/ ${EXCLUDE[@]} 2d 2d ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/2d/12/012/

        EXC_ARR=( "--exclude "{048..240..024}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 ${EXCLUDE[@]} 3d 3d ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/00/024/
    fi
done

ssh ubuntu@u2004-index "cd Index-Scripts-Remote ; ./init_giops_db.sh"