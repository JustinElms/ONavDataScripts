#!/usr/bin/env bash

# Removes data older than 1 year in hpfx datastore

DATE="202200401"
END=$(date -d "-1 years" +%Y%m%d)

while [ "$DATE" != $END ]; do 
  echo $DATE

  echo "Removing GIOPS"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_giops/
  echo "Removing RIOPS"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_riops/
  echo "Removing CIOPS"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_ciops/
  echo "Removing WCPS"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_wcps/
  echo "Removing GDWPS"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}/WXO-DD/model_gdwps/
  echo "Removing ${DATE}"
  rm -r /data/hpfx.collab.science.gc.ca/${DATE}

  DATE=$(date -d "$DATE + 1 day" +%Y%m%d)
done