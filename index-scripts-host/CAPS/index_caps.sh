#!/usr/bin/env bash

# Downloads and indexes latest CAPS model forecast

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data
INC_ARR=( "--include /"{001..012}"/" )
INCLUDE=$(printf "%s " "${INC_ARR[@]}") 
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
lftp -e "mirror -c --parallel=5 -x *.grib2 ${INCLUDE} model_caps/ model_caps/ ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

# Create best estimate:
# Remove 013-048 timestamps from yesterday's data
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_caps/3km/{00,12}/{013..048}

# Remove 013-048 timestamps from all but latest run of today's data
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/${RUNS[$IDX]}/{013..048}
    else
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/
        lftp -e "mirror -c --parallel=5 -x *.grib2 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/      
    fi
done

# Remove data older than 2 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-2 years" +%Y%m%d)

# Index new dataset

ssh ubuntu@u2004-index "cd index-scripts-remote/CAPS/ ; bash caps.sh"