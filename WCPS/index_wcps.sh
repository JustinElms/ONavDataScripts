#!/usr/bin/env bash

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
lftp -e "mirror --parallel=5 model_wcps . ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

# Index new dataset

ssh ubuntu@u2004-index "cd index-scripts ; ./wcps.sh"

# replace production dataset db

lxc file pull u2004-index/home/ubuntu/db/wcps-2dll.sqlite3 /data/db/

# remove yesterday's forecast data 

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_wcps
