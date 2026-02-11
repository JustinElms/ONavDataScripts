#!/usr/bin/env bash

# Syncs and indexes daily and monthly CMEMS global multi-year physical reanalysis data.

python ${HOME}/index-scripts-host/sync_glorys.py

ssh ubuntu@u2004-index "cd index-scripts-remote/CMEMS/ ; bash glorys.sh"
