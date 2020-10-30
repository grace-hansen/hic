#!/bin/bash

module load python/anaconda-2020.02
source activate /project2/nobrega/grace/conda/HiC-env

snakemake \
    --snakefile /project2/nobrega/grace/hic/scripts/snake/Snakefile \
    -kp \
    -j 500 \
    --rerun-incomplete \
    --cluster-config /project2/nobrega/grace/hic/scripts/snake/cluster.json \
    -c "sbatch \
        --mem={cluster.mem} \
        --nodes={cluster.n} \
        --time={cluster.time} \
        --tasks-per-node=1 \
        --partition=broadwl \
        --job-name={cluster.name} \
        --output={cluster.logfile}" \
    $*
