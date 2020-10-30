#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./hicup_deduplicator.sh dir sample
	bams must be in the format <sample>_<rep#>_L<lane>_R1_2.part<part>.hicup.bam
	dir is where raw fastqs are located"
	exit 0
fi

dir=$1
sample=$2

cd $dir
echo "results/${sample}_R1_2.hicup.bam" > $dir/conf/${sample}_deduplicator.conf
/project2/nobrega/grace/hic/scripts/hicup_v0.5.9/hicup_deduplicator --config $dir/conf/${sample}_deduplicator.conf --outdir $dir/results --threads 1
cd results
samtools view -bS ${sample}_R1_2.hicup.dedup.sam > ${sample}_R1_2.hicup.dedup.bam
if [ -f ${sample}_R1_2.hicup.dedup.bam ]; then
	rm ${sample}_R1_2.hicup.dedup.sam
	rm ${sample}_R1_2.hicup.bam
fi
