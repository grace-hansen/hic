#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./run_bam2chicago.sh dir bam design_files
	bams must be in the format <sample>_<rep>_R1_2.hicup.dedup.bam
d"
	exit 0
fi

dir=$1
bam=$2
design_files=$3
cd $dir

sample=$(echo $bam | cut -f1 -d'R' | rev | cut -c2- | rev)
#name=$(echo $(echo $bam | cut -f1 -d'R' | rev | cut -c2- | rev ) "nodelete" )
name=$(echo $bam | cut -f1 -d'R' | rev | cut -c2- | rev )
echo "/project2/nobrega/grace/hic/scripts/bam2chicago.sh $bam $design_files/probes-MboI_fragments-v3.baitmap $design_files/MboI.rmap ${name} "
/project2/nobrega/grace/hic/scripts/bam2chicago.sh $bam $design_files/probes-MboI_fragments-v3.baitmap $design_files/MboI.rmap ${name} 
mv ${sample}/* . && rm -r ${sample}/
