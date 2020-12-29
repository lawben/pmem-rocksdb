#!/usr/bin/env bash
#kvs write.sh
ulimit -n 1048576

db=/mnt/nvme0/rocksdb_sst
wal=/mnt/nvrams1/viper/rocks-test/wal
kvs_file=/mnt/nvrams1/viper/rocks-test/rocksdb.value
kvs_size=53687091200

rm -f ${db}/* 
rm -f ${wal}/*
rm -f ${kvs_file}*

export LD_LIBRARY_PATH=/usr/local/lib64/:/usr/local/lib
numactl --cpunodebind=0 --membind=0 \
./db_bench \
    --benchmarks="fillrandom,stats,levelstats" \
    --enable_write_thread_adaptive_yield=false \
    --disable_auto_compactions=false \
    --max_background_compactions=32 \
    --max_background_flushes=4 \
    --value_size=200 \
    --key_size=16 \
    --db=${db} \
    --wal_dir=${wal} \
    --enable_pipelined_write=true \
    --allow_concurrent_memtable_write=true \
    --batch_size=1 \
    --histogram=true \
    --use_direct_io_for_flush_and_compaction=true \
    --target_file_size_base=67108864 \
    --disable_wal=false \
    --dcpmm_enable_wal=true \
    --sync=true \
    \
    --writes=1000000 \
    --num=100000000 \
    --threads=100 \
    \
    --dcpmm_kvs_mmapped_file_fullpath=${kvs_file} \
    --dcpmm_kvs_mmapped_file_size=${kvs_size} \
    --dcpmm_compress_value=true \
    \
    --report_interval_seconds=10 \
    --report_file=report.csv
