# expire.py - reads expiry files output by Imposm and tells Tegola to purge the affected tiles
# Expiry files are output by the `-expiretiles-dir` Imposm option.
from pathlib import Path
import subprocess
import os
import sys
import time

if len(sys.argv) != 2:
    print("Usage:", sys.argv[0], "<imposm expire dir>")
    sys.exit(1)

expire_dir = sys.argv[1]

pathlist = Path(expire_dir).glob("**/*.tiles")
for path in pathlist:
    file_time = os.path.getmtime(path)
    if (time.time() - file_time) <= 610:
        print("Handling expire for", path)
        subprocess.run(
            [
                "tegola",
                "cache",
                "purge",
                "tile-list",
                path,
                "--config",
                "/home/osm/styles/tegola/config.toml",
                "--max-zoom",
                "17",
                "--min-zoom",
                "7",
            ]
        )
