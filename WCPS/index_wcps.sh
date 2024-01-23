#!/usr/bin/env bash

source ${HOME}/onav-cloud/etc/ocean-navigator-env.sh
conda activate transfer-tools

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps
lftp -e "mirror --parallel=5 model_wcps . ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

lxc file pull u2004-index/home/ubuntu/db/wcps-2dll.sqlite3 /data/db/

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_wcps
