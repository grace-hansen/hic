#!/bin/bash
# This script runs CHiCAGO with merged promoters.

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./run_CHiCAGO_mergedTSS.sh dir textfile \n
			This script runs CHiCAGO with merged promoters. It takes as its input the working directory and a text file with the relevant *.chinput files."
	exit 0
fi

dir=$1
chinputs=$2

for chinput in $(cat $chinputs); do
	name=$(echo $chinput | cut -f1 -d'.')
	cat /group/nobrega-lab/grace/hic/scripts/submit_job_example.pbs | sed "s|<jobname>|CHiCAGO_mergedTSS_${name}|g" | sed "s|mem=250gb|mem=100gb|g" > CHiCAGO_mergedTSS_${name}.pbs
	sed -i "$ a cd ${dir}" CHiCAGO_mergedTSS_${name}.pbs
	sed -i "$ a /group/nobrega-lab/grace/hic/scripts/bam2chicago.sh ${name}.hicup.dedup.bam ../../design_files/longTSS/probes-MboI_fragments-longTSS.baitmap ../../design_files/longTSS/MboI-longTSS.rmap ${name}_R1_2_mergedTSS" CHiCAGO_mergedTSS_${name}.pbs
	sed -i "$ a module load gcc/5.4.0 && module load R/3.3.2" CHiCAGO_mergedTSS_${name}.pbs
	sed -i "$ a mv ${name}_R1_2_mergedTSS/* . && rm -r ${name}_R1_2_mergedTSS/" CHiCAGO_mergedTSS_${name}.pbs
	sed -i "$ a /group/nobrega-lab/grace/hic/scripts/run_CHiCAGO.R ${dir}/results/ /group/nobrega-lab/grace/hic/design_files/longTSS ${name}_R1_2_mergedTSS.chinput" CHiCAGO_mergedTSS_${name}.pbs
	#sed -i "$ a mv ${name}_R1_2.chinput ${name}_R1_2_mergedTSS.chinput" CHiCAGO_mergedTSS_${name}.pbs

	qsub CHiCAGO_mergedTSS_${name}.pbs
	done
