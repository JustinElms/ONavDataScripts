#!/usr/bin/env bash

# Downloads and indexes latest RIOPS model data for 10 day forecast

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/
lftp -e "mirror -c --parallel=5 polar_stereographic polar_stereographic ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/

# Create best estimate

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/{2d,3d}/{00..18..06}/{006..084}

# Remove data older than 1 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-1 years" +%Y%m%d)

# index new dataset

ssh ubuntu@u2004-index "cd index-scripts ; ./riops.sh ${RUN}"

# replace production dataset db

lxc file pull u2004-index/home/ubuntu/db/riops-fc2dps.sqlite3 /data/db/
lxc file pull u2004-index/home/ubuntu/db/riops-fc3dps.sqlite3 /data/db/

