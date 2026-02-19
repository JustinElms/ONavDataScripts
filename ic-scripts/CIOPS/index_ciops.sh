#!/usr/bin/env bash

# Downloads and indexes today's CIOPS model data

DATE=$(date +%Y%m%d)

# Make directories for new data
[ ! -d /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/ ] && mkdir -p /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/

cd /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/
lftp -e "mirror -c --parallel=5 model_ciops model_ciops ; bye" http://dd.weather.gc.ca/${DATE}/WXO-DD/

ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-east_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-east_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/east/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-west_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-west_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/west/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-salish-sea_fc_2dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/"
ssh ubuntu@u2204-icechunk "cd icechunk/ ; python ic_interface.add_nc_data.py ciops-salish-sea_fc_3dll -s --nc_dir /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/salish-sea/"