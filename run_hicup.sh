#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./run_hicup.sh dir tmp R1_fastq
	fastq must be in the format <sample>_<rep#>_L<lane>_R<read 1 or 2>.part<part>.fastq
	dir is where raw fastqs are located"
	exit 0
fi

dir=$1
tmp=$2
name=$3
fastq=$4

cd $dir
L=$(echo $fastq | rev | cut -f3 -d'.' | cut -f2 -d'_' | rev | sed 's|L||g')
i=$(echo $fastq | rev | cut -f2 -d'.' | rev | cut -f2 -d'-')

cp /project2/nobrega/grace/hic/scripts/hicup_example.conf $dir/conf/${name}_L${L}_${i}.conf
echo ${tmp}${name}_L${L}_R1.part-${i}.fastq >> ${dir}conf/${name}_L${L}_${i}.conf
echo ${tmp}${name}_L${L}_R2.part-${i}.fastq >> ${dir}conf/${name}_L${L}_${i}.conf

/project2/nobrega/grace/hic/scripts/hicup_v0.5.9/hicup --outdir $tmp --config $dir/conf/${name}_L${L}_${i}.conf
