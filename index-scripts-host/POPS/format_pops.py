import glob
import sys

import xarray as xr


def rename_coords(model_path: str) -> None:
    """
    Renames latitude and longitude variables in POPS model NC file
    """
    nc_files = glob.glob(f"{model_path}/*.nc")

    for file in nc_files:
        print(file)
        ds = xr.open_dataset(file)
        ds = ds.rename({"lon": "longitude", "lat": "latitude"})
        ds.to_netcdf(file)


if __name__ == "__main__":
    model_path = sys.argv[1]
    print(model_path)
    rename_coords(model_path)
