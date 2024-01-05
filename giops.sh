#!/usr/bin/env bash

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")


# remove old list and databases
rm -r giops-fc3dll-10day.*

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

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/{$RUN}/{024..240..024}

echo /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_giops/netcdf/lat_lon/3d/{$RUN}/{024..240..024}

# Remove data older than 1 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-1 years" +%Y%m%d)/WXO-DD/model_giops/netcdf/lat_lon/3d/{$RUN}/{024..240..024}

# index new dataset

find /data/hpfx.collab.science.gc.ca/*/WXO-DD/model_giops/netcdf/lat_lon/3d/${RUN}/ -mtime -1 -type f > giops-fc2dll-10day.txt
${HOME}/onav-cloud/tools/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n giops-fc2dll-10day -i /data/hpfx.collab.science.gc.ca -o . --file-list giops-fc2dll-10day.txt -h

# replace production dataset db