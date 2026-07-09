#!/usr/bin/env python3
"""Write site/index.json listing every hosted file with its download path."""
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

files_txt, site_dir, chunk_name = sys.argv[1], Path(sys.argv[2]), sys.argv[3]

files = []
for line in Path(files_txt).read_text().splitlines():
    src = Path(line)
    gz = site_dir / "step" / (src.name + ".gz")
    files.append({
        "id": src.name[:8],
        "name": src.name,
        "path": f"step/{gz.name}",
        "stepBytes": src.stat().st_size,
        "gzBytes": gz.stat().st_size,
    })

index = {
    "name": "abc-step-1000",
    "description": "First 1000 STEP files from the ABC dataset, "
                   "served gzip-compressed",
    "source": "https://deep-geometry.github.io/abc-dataset/",
    "chunk": chunk_name,
    "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "count": len(files),
    "totalStepBytes": sum(f["stepBytes"] for f in files),
    "totalGzBytes": sum(f["gzBytes"] for f in files),
    "files": files,
}

(site_dir / "index.json").write_text(json.dumps(index, indent=1))
print(f"index.json: {len(files)} files, "
      f"{index['totalStepBytes'] / 1e9:.2f} GB uncompressed, "
      f"{index['totalGzBytes'] / 1e9:.2f} GB compressed")
