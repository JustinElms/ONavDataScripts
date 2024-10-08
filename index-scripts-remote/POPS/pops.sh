#!/usr/bin/env bash

# Indexes latest POPS model forecast data.
# Place this script in Indexing LXD container and run it from index_pops.sh on host.

DATE=$(date +%Y%m%d)
YESTERDAY=$(date -d "-1 days" +%Y%m%d)

MODELS=(canso100 canso500 fundy500 grc100 kit100 kit500 sf30 sj100 sss150 stle200 stle500 vh20)

for MODEL in ${MODELS[@]}; do
  [ -f ${HOME}/db/${MODEL}.sqlite3 ] && rm ${HOME}/db/${MODEL}.sqlite3
  
  ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ${MODEL} -i /data/hpfx.collab.science.gc.ca/${DATE}/model_pops/${MODEL}/ -o ${HOME}/db -h

  mv ${HOME}/db/${MODEL}.sqlite3 /data/db/
done
