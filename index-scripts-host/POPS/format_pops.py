import argparse
from pathlib import Path

import xarray as xr


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Fixes attributes and fill values of POPS forecast NetCDF files."
        )
    )
    parser.add_argument("path", help="Path to NetCDF files", type=str)

    args = parser.parse_args()
    nc_files = list(Path(args.path).rglob("*.nc"))

    valid_range_attrs = {
        "uos": {"valid_min": -20.0, "valid_max": 20.0},
        "vos": {"valid_min": -20.0, "valid_max": 20.0},
        "sos": {"valid_min": 0.0, "valid_max": 45.0},
        "tos": {"valid_min": 173.0, "valid_max": 373.0},
    }

    for nc_file in nc_files:
        ds = xr.open_dataset(nc_file, mask_and_scale=False, decode_cf=False, decode_times=False)
        coord_data_vars = [v for v in ds.data_vars if v in ["lat", "lon"]]
        for coord in coord_data_vars:
            ds = ds.set_coords(coord)

        encoding = {}
        for var in ds.data_vars:
            ds[var] = ds[var].where(ds[var] != ds[var].attrs.get("missing_value"), other=1e20)
            new_attrs = {
                **ds[var].attrs,
                "valid_min": valid_range_attrs.get(var, {}).get("valid_min"),
                "valid_max": valid_range_attrs.get(var, {}).get("valid_max"),
                "_FillValue": 1e20
            }

            ds[var] = ds[var].drop_attrs()
            ds[var] = ds[var].assign_attrs(new_attrs)

            del ds[var].attrs["missing_value"]

            ds[var] = ds[var].astype("float32")

            encoding[var] = {"dtype": "float32"}

        ds.to_netcdf(nc_file, encoding=encoding, format="NETCDF4", engine="netcdf4")
