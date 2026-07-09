#!/usr/bin/env bash
# Build the GitHub Pages site: download the first STEP chunk of the ABC
# dataset, extract the first N models, gzip each file, and write an index.
#
# Env:
#   CHUNK_ARCHIVE  path to an already-downloaded abc_0000_step_v00.7z
#                  (skips the ~1.6 GB download)
#   WORK           working directory (default: ./build)
#   N              number of models to host (default: 1000)
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${WORK:-"$REPO_ROOT/build"}
N=${N:-1000}

mkdir -p "$WORK"
cd "$WORK"

if [ -z "${CHUNK_ARCHIVE:-}" ]; then
    wget -q https://deep-geometry.github.io/abc-dataset/data/step_v00.txt
    CHUNK_URL=$(sed '1q;d' step_v00.txt | awk '{print $1}')
    CHUNK_NAME=$(sed '1q;d' step_v00.txt | awk '{print $2}')
    echo "Downloading $CHUNK_NAME from $CHUNK_URL ..."
    wget -q --no-check-certificate "$CHUNK_URL" -O "$CHUNK_NAME"
    CHUNK_ARCHIVE="$WORK/$CHUNK_NAME"
fi
CHUNK_NAME=$(basename "$CHUNK_ARCHIVE")

# Extract only the first N model directories; the full chunk holds 10000
# models (~15 GB uncompressed), far more than we need or than CI disk allows.
echo "Extracting first $N model directories from $CHUNK_NAME ..."
seq -f '%08g/*' 0 $((N - 1)) > include.txt
rm -rf extracted
7z x -y "$CHUNK_ARCHIVE" -i@include.txt -oextracted > /dev/null

rm -rf site
mkdir -p site/step
find extracted -name '*.step' | sort | head -n "$N" > files.txt
echo "Compressing $(wc -l < files.txt) STEP files ..."
xargs -a files.txt -P "$(nproc)" -I{} \
    sh -c 'gzip -9 -c "$1" > "site/step/$(basename "$1").gz"' _ {}

python3 "$REPO_ROOT/scripts/make_index.py" files.txt site "$CHUNK_NAME"
cp "$REPO_ROOT/site/index.html" site/

echo "Done. Site size:"
du -sh site
