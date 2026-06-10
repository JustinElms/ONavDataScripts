import argparse
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import xarray as xr


def process_gdwps(grib_file: str | Path) -> None:
    output_file = grib_file.with_suffix(".nc")

    with xr.open_dataset(grib_file, decode_times=False) as ds:
        for coord in ["time", "step", "surface"]:
            if coord in ds.coords:
                ds = ds.drop_vars(coord)
        ds = ds.rename({"valid_time": "time"})

        for var in ds.data_vars:
            ds[var] = ds[var].expand_dims(dim={"time": ds["time"].size}, axis=0)
        ds.to_netcdf(output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=("Converts GDWPS grib2 files to NetCDF4."))
    parser.add_argument("path", help="The path to the grib2 files.", type=str)

    args = parser.parse_args()
    grib_files = list(Path(args.path).rglob("*.grib2"))

    max_workers = int(os.cpu_count() / 4) or 1
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(process_gdwps, grib_file=grib_file) for grib_file in grib_files]

        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Error processing file: {e}")
