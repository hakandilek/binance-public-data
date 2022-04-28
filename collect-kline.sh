#!/usr/bin/env bash

DAYS=423
echo "collecting data for ${DAYS} days..."
DIR_=$(pwd)
START=$(date -d "${DAYS} days ago" "+%F")
END=$(date -d yesterday "+%F")
DATA_DIR="${DIR_}/data"
DOWNLOAD_DIR="${DIR_}/download"
start=${START}

DATES=()
while [[ ! $start > $END ]]; do
    DATES+=($start)
    start=$(date -d "$start + 1 day" +%F)
done

poetry run python/download-kline.py \
    -s BTCUSDT \
    -c 1 \
    -t spot \
    -i 1m \
    -d "${DATES[@]}" \
    -folder "${DOWNLOAD_DIR}"

DAILY_DIR="${DOWNLOAD_DIR}/data/spot/daily/klines/BTCUSDT/1m"

if [ -d "${DAILY_DIR}" ] 
then
    cd ${DAILY_DIR}
    sha256sum --check *.CHECKSUM
    unzip -o "*.zip" -d ${DATA_DIR}
fi

cat ${DATA_DIR}/BTCUSDT*.csv | sort | uniq -u > "${DATA_DIR}/merged_${START}_${END}.csv"

cd ${DIR_}
