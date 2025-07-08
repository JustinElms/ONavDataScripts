#!/usr/bin/env bash

# Indexes latest CAPS model forecast data.
# Place this script in Indexing LXD container and run it from index_caps.sh on host.

DATE=$(date +%Y%m%d)
[ -f ${HOME}/db/${MODEL}.sqlite3 ] && rm ${HOME}/db/${MODEL}.sqlite3

find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/ -name \*.nc -type f > ${HOME}/db/caps-fc.txt
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n caps-fc -i /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/ -o ${HOME}/db --file-list ${HOME}/db/caps-fc.txt -h

mv ${HOME}/db/caps-fc.sqlite3 /data/db
