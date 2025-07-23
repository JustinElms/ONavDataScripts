#!/usr/bin/env bash

# Downloads and indexes latest POPS models forecast

source $HOME/onav-cloud/etc/ocean-navigator-env.sh

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

MODELS=(canso100 canso500 fundy500 kit100 kit500 sf30 sj100 sss150 stle200 stle500 vh20)

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/model_pops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/model_pops/

cd /data/hpfx.collab.science.gc.ca/${DATE}/model_pops/

for MODEL in ${MODELS[@]}; do
  lftp -e "lcd /data/hpfx.collab.science.gc.ca/${DATE}/model_pops/  ; mirror --parallel=5 ${MODEL} ${MODEL} ; bye" http://dd.weather.gc.ca/dfo/pops_model/${DATE}
done

ssh ubuntu@u2004-index "cd index-scripts-remote/POPS/ ; bash pops.sh"

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/model_pops
