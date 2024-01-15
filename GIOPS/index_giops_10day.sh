#!/usr/bin/env bash

# Downloads and indexes latest GIOPS model data for 10 day forecast

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf
lftp -e "mirror -c --parallel=5 lat_lon lat_lon ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf

# Create best estimate
# For GIOPS 10 day FC keep both 00 and 12 runs and remove 024-240 timestamps. Alternate which run gets indexed to match latest forecast

RUN="00"
if [ -d http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/netcdf/lat_lon/3d/12/ ]; then
    RUN="12"
fi

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/2d/00/000/
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/2d/{00,12}/{015..240..003}
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/00/{024..240..024}
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/12/{048..240..024}

# Remove data older than 1 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-1 years" +%Y%m%d)

# index new dataset

ssh ubuntu@u2004-index "cd index-scripts ; ./giops_10day.sh ${RUN}"

# replace production dataset db

lxc file pull u2004-index/home/ubuntu/db/giops-fc2dll-10day.sqlite3 /data/db/
lxc file pull u2004-index/home/ubuntu/db/giops-fc3dll-10day.sqlite3 /data/db/

