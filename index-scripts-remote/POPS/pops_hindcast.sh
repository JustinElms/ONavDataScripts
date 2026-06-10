#!/usr/bin/env bash

# Indexes latest POPS model hindcast data.
# Place this script in Indexing LXD container and run it from index_pops_hindcast.sh on host.

MODELS=(canso100 canso500 fundy500 kit100 kit500 sf30 sj100 sss150 stle200 stle500 vh20)

for MODEL in ${MODELS[@]}; do
  [ -f ${HOME}/db/${MODEL}.sqlite3 ] && rm ${HOME}/db/${MODEL}.sqlite3
  
  ${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n ${MODEL}_hindcast -i /data/hpfx.collab.science.gc.ca/dfo/pops_model_hindcast/${MODEL}/ -o ${HOME}/db -h

  mv ${HOME}/db/${MODEL}_hindcast.sqlite3 /data/db
done
