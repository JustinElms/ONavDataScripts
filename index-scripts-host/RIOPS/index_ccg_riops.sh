
cd /data/depot.cmc.ec.gc.ca/ftp/cmoi/dfo/dfo.ccg/

ssh ubuntu@u2404-minio "mc mirror myminio/depot.cmc.ec.gc.ca /data/depot.cmc.ec.gc.ca/"

NCFILE=$(ls *.nc | tail -n 1)

ssh ubuntu@u2204-icechunk "cd icechunk/ ; source env/icechunk-env.sh ; python ic_interface/add_nc_data.py riops_fc_2dll --nc_files /data/depot.cmc.ec.gc.ca/ftp/cmoi/dfo/dfo.ccg/${NCFILE}"
