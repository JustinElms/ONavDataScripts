#!/usr/bin/env bash

# Downloads and indexes latest GIOPS model data for 10 day forecast

DATE=$(date +%Y%m%d)

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf
lftp -e "mirror -c --parallel=5 lat_lon lat_lon ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_giops/netcdf

ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py giops_day -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py gdwps_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/2d/"