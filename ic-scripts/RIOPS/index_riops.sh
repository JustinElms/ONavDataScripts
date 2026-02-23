#!/usr/bin/env bash

# Downloads and indexes today's RIOPS model data

DATE=$(date +%Y%m%d)

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/
lftp -e "mirror -c --parallel=5 ${INCLUDE} polar_stereographic polar_stereographic ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/

ssh ubuntu@u2204-icechunk "cd icechunk/ ; python3 ic_interface/add_nc_data.py riops_fc_3dps -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python3 ic_interface/add_nc_data.py riops_fc_2dps -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/"
