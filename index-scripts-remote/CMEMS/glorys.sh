
#!/usr/bin/env bash

# Indexes latest CMEMS Daily and Monthly global multi-year physical reanalysis data.
# Place this script in Indexing LXD container and run it from sync_glorys.sh on host.

# Index CMEMS daily reanalysis data
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n cmems_daily -i /data/my.cmems-du.eu/GLOBAL_MULTIYEAR_PHY_001_030/cmems_mod_glo_phy_my_0.083deg_P1D-m_202311/ -o ${HOME}/db -h

# Index CMEMS monthly reanalysis data
${HOME}/netcdf-timestamp-mapper/build/nc-timestamp-mapper -n cmems_monthly -i /data/my.cmems-du.eu/GLOBAL_MULTIYEAR_PHY_001_030/cmems_mod_glo_phy_my_0.083deg_P1M-m_202311/ -o ${HOME}/db -h

mv ${HOME}/db/cmems_daily.sqlite3 /data/db/
mv ${HOME}/db/cmems_monthly.sqlite3 /data/db/