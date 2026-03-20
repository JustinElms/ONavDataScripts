#!/usr/bin/env bash

source ~/onav-cloud/etc/ocean-navigator-env.sh

cd onav-cloud/Ocean-Data-Map-Project/
python scripts/cmems_obs/get_cmems_obs_day.py ${$ONAV_SQLALCHEMY_DATABASE_URI} /data/nrt.cmems-du.eu/
