#!/usr/bin/env bash

# Downloads and indexes today's RIOPS model data

DATE=$(date +%Y%m%d)
YESTERDAY=$(date  --date="yesterday" +"%Y%m%d")

# Get new data

INC_ARR=( "--include "{000..005}"/" )
INCLUDE=$(printf "%s " "${INC_ARR[@]}") 
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic
cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/
lftp -e "mirror -c --parallel=5 ${INCLUDE} polar_stereographic polar_stereographic ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/

# Create best estimate:
# Remove 006-084 timestamps from yesterday's data
rm -r /data/hpfx.collab.science.gc.ca/${YESTERDAY}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/{2d,3d}/{00..18..06}/{006..084}

# Remove 006-084 timestamps from all but latest run of today's data
RUNS=( $(find /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort -n) )
NRUNS=${#RUNS[*]}

for IDX in "${!RUNS[@]}"
do
    if [ $IDX != $((NRUNS-1)) ]; then
        rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/{2d,3d}/${RUNS[$IDX]}/{006..084}
    else
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/
        lftp -e "mirror -c --parallel=5 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/2d/
        cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/
        lftp -e "mirror -c --parallel=5 ${RUNS[$IDX]} ${RUNS[$IDX]} ; bye" http://hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/netcdf/forecast/polar_stereographic/3d/        
    fi
done

# Remove data older than 1 yr

rm -r /data/hpfx.collab.science.gc.ca/$(date -d "-1 years" +%Y%m%d)

# Index new dataset

ssh ubuntu@u2004-index "cd index-scripts-remote/RIOPS/ ; bash riops.sh"