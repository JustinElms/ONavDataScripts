#!/usr/bin/env bash

# Downloads and indexes latest CAPS model forecast

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data
INC_ARR=( "--include /"{001..012}"/" )
INCLUDE=$(printf "%s " "${INC_ARR[@]}") 
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
lftp -e "mirror -c --parallel=5 ${INCLUDE} --exclude-glob '*.grib2' model_caps/ model_caps/ ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/

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
        lftp -e "mirror -c --parallel=5 --exclude-glob '*.grib2' ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_caps/3km/      
    fi
done

# Index new dataset
ssh ubuntu@u2004-index "cd index-scripts-remote/CAPS/ ; bash caps.sh"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py caps_fc_2drp -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py caps_fc_3drp -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_caps/3km/"