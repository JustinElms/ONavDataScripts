#!/usr/bin/env bash

# Downloads and indexes latest CAPS model forecast

source $HOME/onav-cloud/etc/ocean-navigator-env.sh

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/

lftp -e "lcd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/ ; mirror --parallel=5 --include /"*.nc" model_caps/ model_caps/ ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/

ssh ubuntu@u2004-index "cd index-scripts-remote/CAPS/ ; bash caps.sh"

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/