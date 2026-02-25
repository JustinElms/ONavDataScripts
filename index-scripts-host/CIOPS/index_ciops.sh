#!/usr/bin/env bash

# Downloads and indexes today's CIOPS model data

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Create best estimate:
# Remove 006/7-048 timestamps from yesterday's data

rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/{east,west}/2km/{00..18..06}/{006..048}
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_ciops/salish-sea/500m/{00..18..06}/{007..048}

# Make directories for new data

[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/

# Remove 006/7-048 timestamps from all but latest run of today's data
INC_ARR=( "--include /"{000..006}"/" )
INCLUDE=$(printf "%s " "${INC_ARR[@]}")

RUNS=($(lftp -e "cls -1; exit" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/))
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    RUN=${RUNS[$IDX]::-1}
    echo $RUN

    if [ $IDX != $((NRUNS-1)) ]
    then
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        lftp -e "mirror -c --parallel=5 ${INCLUDE} ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        lftp -e "mirror -c --parallel=5 ${INCLUDE} ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/
        lftp -e "mirror -c --parallel=5 ${INCLUDE} ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/

        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/{east,west}/2km/${RUN}/{006..048}
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/${RUN}/{007..048}

    elif [ $IDX == $((NRUNS-1)) ]; then
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        lftp -e "mirror -c --parallel=5 ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/east/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        lftp -e "mirror -c --parallel=5 ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/west/2km/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/
        lftp -e "mirror -c --parallel=5 ${RUN} ${RUN} ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/500m/
        break

    fi
done

# Index new dataset
ssh ubuntu@u2004-index "cd index-scripts-remote/CIOPS/ ; bash ciops.sh"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-east_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-east_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-west_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-west_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-salish-sea_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py ciops-salish-sea_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/"