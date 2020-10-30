#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./merge_reps.sh dir sample n_reps
	bams must be in the format <sample>_<rep>_R1_2.hicup.dedup.bam
d"
	exit 0
fi

dir=$1
sample=$2

reps=$(ls $dir${sample}_*_R1_2.hicup.dedup.bam | rev | cut -f4 -d'.' | cut -f3 -d'_' | sort -u )

cd $dir

merge_array=()
for i in $(echo $reps | tr ' ' '\n' ); do
	file=${sample}_${i}_R1_2.hicup.dedup.bam
	merge_array+=($file)
done
samtools merge ${sample}_merged_R1_2.hicup.dedup.bam ${merge_array[*]}
