#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./merge_bams.sh dir tmp sample_rep n_splits n_lanes
	bams must be in the format <sample>_<rep#>_L<lane>_R1_2.part<part>.hicup.bam
	dir is where raw fastqs are located"
	exit 0
fi

dir=$1
tmp=$2
sample_rep=$3
n_splits=$4

lanes=$(ls $tmp/${sample_rep}_L*_R1.fastq.* | rev | cut -f3 -d'.' | cut -f2 -d'_' | sed "s|L||g" | sort -u )

cd $dir
#Merge bams:

files_array=()
for L in $(echo $lanes | tr ' ' '\n' | sed "s|L||"); do
	for i in $(seq -f "%02g" 1 $n_splits); do
		file=$tmp/${sample_rep}_L${L}_R1_2.part-${i}.hicup.bam
		if [ -f $file ]; then
			files_array+=($file)
		else 
			echo "$file not found!"
			exit
		fi

	done
done
echo "samtools cat -o results/${sample_rep}_R1_2.hicup.bam ${files_array[*]}"
samtools cat -o results/${sample_rep}_R1_2.hicup.bam ${files_array[*]}

#if [ -f rm $dir/tmp/${sample_rep}_L${L}_R1_2.hicup.bam ]; then
#	rm $dir/tmp/${sample_rep}_L${L}_R1_2.part-${i}.hicup.bam
#	rm $dir/tmp/${sample_rep}_L${L}_R1.part-*.fastq
#	rm $dir/tmp/${sample_rep}_L${L}_R2.part-*.fastq
#fi
