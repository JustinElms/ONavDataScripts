#!/usr/bin/env bash

# Initializes best estimate for GIOPS datasets
DATE=$(date -d "-90 days" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past 90 days
while (( $(date -d "${DATE}" +%s) <= $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    YESTERDAY=$(date -d "${DATE} days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf; then
        # Download data for the current date
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon

        EXC_ARR=( "--exclude "{015..240..003}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 --exclude 00/000/ --exclude 00/012/ ${EXCLUDE[@]} 2d 2d ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

        EXC_ARR=( "--exclude "{048..240..024}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 --exclude 00/000/ ${EXCLUDE[@]} 3d 3d ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

    fi

    if [ -d "/data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/2d/12/012/" ]; then
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/2d/00/000/
    fi

    if [ -d "/data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/00/024/" ]; then
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/00/000/
    fi

done

ssh ubuntu@u2004-index "cd index-scripts-remote/GIOPS/ ; bash init_giops_db.sh"