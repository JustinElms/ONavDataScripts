from datetime import datetime, timedelta

import os
import sqlite3

uris = [
    "/home/ubuntu/db/ciops-east-2d-archive.sqlite3",
    "/home/ubuntu/db/ciops-east-3d-archive.sqlite3",
    "/home/ubuntu/db/ciops-west-2d-archive.sqlite3",
    "/home/ubuntu/db/ciops-west-3d-archive.sqlite3",
    "/home/ubuntu/db/ciops-salish-2d-archive.sqlite3",
    "/home/ubuntu/db/ciops-salish-3d-archive.sqlite3",
    "/home/ubuntu/db/giops-fc3dll-10day-00-archive.sqlite3",
    "/home/ubuntu/db/giops-fc3dll-10day-12-archive.sqlite3",
    "/home/ubuntu/db/giops-fc2dll-10day-archive.sqlite3",
    "/home/ubuntu/db/riops-fc2dps-archive.sqlite3",
    "/home/ubuntu/db/riops-fc3dps-archive.sqlite3",
]

today = datetime.today()
cutoff_date = datetime.today() - timedelta(days=365)

time_delta = cutoff_date - datetime(1950, 1, 1)
timestamp_cutoff = time_delta.days * 3600 * 24

for uri in uris:
    if not os.path.isfile(uri):
        print(f"Skipping {uri}. File does not exist.")
        continue

    print(f"Cleaning {uri}...")

    conn = sqlite3.connect(uri, uri=True)
    c = conn.cursor()

    c.execute(
        "SELECT * FROM Timestamps where Timestamps.timestamp "
        f"< {timestamp_cutoff};"
    )
    data = c.fetchall()
    timestamp_ids = [d[0] for d in data]

    c.execute(
        "SELECT * FROM TimestampVariableFilepath WHERE "
        "TimestampVariableFilepath.timestamp_id IN "
        f"({', '.join([str(t) for t in timestamp_ids])});"
    )
    data = c.fetchall()
    filepath_ids = [d[0] for d in data]
    filepath_ids = list(set(filepath_ids))

    c.execute(
        "DELETE FROM Filepaths WHERE Filepaths.id IN "
        f"({', '.join([str(id) for id in filepath_ids])});"
    )

    c.execute(
        "DELETE FROM TimestampVariableFilepath WHERE "
        "TimestampVariableFilepath.filepath_id IN "
        f"({', '.join([str(id) for id in filepath_ids])});"
    )

    c.execute(
        "DELETE FROM Timestamps WHERE Timestamps.id IN "
        f"({', '.join([str(id) for id in timestamp_ids])});"
    )

    c.execute("SELECT min(id) FROM Filepaths;")
    min_filepath_id = c.fetchall()[0][0]
    min_filepath_id

    c.execute("SELECT min(id) FROM Timestamps;")
    min_timestamp_id = c.fetchall()[0][0]
    min_timestamp_id

    c.execute(f"UPDATE Filepaths Set id=id - {min_filepath_id - 1};")
    c.execute(f"UPDATE Timestamps Set id=id - {min_timestamp_id - 1};")
    c.execute(
        "UPDATE TimestampVariableFilepath Set filepath_id=filepath_id - "
        f"{min_filepath_id - 1};"
    )
    c.execute(
        "UPDATE TimestampVariableFilepath Set timestamp_id=timestamp_id - "
        f"{min_timestamp_id - 1};"
    )

    conn.commit()
    conn.close()
