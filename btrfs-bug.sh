#!/bin/bash

SRC_FOLDER=$(pwd)/src_dir
MOVING_FILE=${TARGET_FOLDER}/missing-file.txt
TRG_FOLDER=$(pwd)/target

echo "Creating src/target directories on:"
echo "source: ${SRC_FOLDER}"
echo "target: ${TRG_FOLDER}"

mkdir -p "$SRC_FOLDER"
mkdir -p "$TRG_FOLDER"

for x in {1..10000}; do
  dd if=/dev/zero ibs=1M count=1 of="${SRC_FOLDER}/$x.txt" 2>/dev/null
done

echo "missing-file.txt" > "${SRC_FOLDER}/missing-file.txt"

cat <<EOF > rsyncd.conf
uid = nobody
gid = nobody
use chroot = no
max connections = 4
syslog facility = local5
pid file = /tmp/rsync.pid
[ftp]
        path = $SRC_FOLDER
        comment = ftp area
EOF

echo "Staring rsync daemon on port 9999"
rsync --daemon --port=9999 --config=./rsyncd.conf --verbose

echo "Done."
