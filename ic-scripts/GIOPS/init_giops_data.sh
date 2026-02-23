#!/usr/bin/env bash

# Initializes best estimate for GIOPS datasets
DATE=$(date -d "-6 months" +%Y%m%d)
END_DATE=$(date +%Y%m%d)

# Get available data from past two months
while (( $(date -d "${DATE}" +%s) < $(date -d "${END_DATE}" +%s) )); do
    DATE=$(date -d "${DATE} +1 days" +%Y%m%d)
    echo $DATE

    if wget -q --method=HEAD http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf; then
        # Download data for the current date
        [ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon

        EXC_ARR=( "--exclude "{015..240..003}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 ${EXCLUDE[@]} 2d 2d ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

        EXC_ARR=( "--exclude "{048..240..024}"/" )
        EXCLUDE=$(printf "%s " "${EXC_ARR[@]}")
        lftp -e "mirror -c --parallel=5 ${EXCLUDE[@]} 3d 3d ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/

    fi

done

ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py giops_day -s"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py gdwps_2dll -s"