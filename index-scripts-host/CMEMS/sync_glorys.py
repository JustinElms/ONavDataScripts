import copernicusmarine

dataset_ids = [
    "cmems_mod_glo_phy_my_0.083deg-climatology_P1M-m",
    "cmems_mod_glo_phy_my_0.083deg_P1D-m",
    "cmems_mod_glo_phy_my_0.083deg_P1M-m",
    "cmems_mod_glo_phy_my_0.083deg_static",
]
output_dir = "/data/my.cmems-du.eu/"

for dataset_id in dataset_ids:
    print(dataset_id)
    copernicusmarine.get(
        dataset_id=dataset_id,
        dataset_version="202311",
        output_directory=output_dir,
        sync=True,
        sync_delete=True,
    )
