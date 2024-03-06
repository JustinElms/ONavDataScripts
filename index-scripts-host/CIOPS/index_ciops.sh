#!/usr/bin/env bash

# Downloads and indexes today's RIOPS model data

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

INC_ARR=( "--include /"{000..005}"/" )
INCLUDE=$(printf "%s " "${INC_ARR[@]}")  
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
lftp -e "mirror --parallel=5 ${INCLUDE} model_ciops model_ciops ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

# Create best estimate:
# Remove 006-084 timestamps from yesterday's data

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/{east,west}/2km/{00..18..06}/{006..048}
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/salish-sea/500m/{00..18..06}/{006..048}

# Remove 006-084 timestamps from all but latest run of today's data
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/{east,west}/2km/${RUNS[$IDX]}/{006..048}
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUNS[$IDX]}/{006..048}        
    else
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        lftp -e "mirror -c --parallel=5 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        lftp -e "mirror -c --parallel=5 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/
        lftp -e "mirror -c --parallel=5 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/      
    fi
done

# Remove data older than 1 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-1 years" +%Y%m%d)

# Index new dataset

ssh ubuntu@u2004-index "cd index-scripts-remote/CIOPS/ ; ./ciops.sh ${RUN}"