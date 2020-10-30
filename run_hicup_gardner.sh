#!/bin/bash
# This is a wrapper script that runs hicup on gardner. It takes a textfile containing the paths to the forward read(R1) files, which must have a corresponding reverse(R2) file.

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./run_hicup_gardner5.sh dir textfile"
	exit 0
fi

dir=$1
IDs=$2

cd $dir

if [ ! -d results/ ]; then
	mkdir results
fi
if [ ! -d conf/ ]; then
	mkdir conf
fi

#Part 1: Split each lane fastq into 15 pieces
for name in $(cat $IDs); do
	p2_jobids=()
	for L in $(seq 1 8); do
		cat /group/nobrega-lab/grace/hic/scripts/submit_job_example.pbs | sed "s|<jobname>|hicup_p1_${name}_L${L}|g" | sed "s|mem=250gb|mem=50gb|g" > hicup_p1_${name}_L${L}.pbs

		sed -i "$ a cd ${dir}/raw" hicup_p1_${name}_L${L}.pbs
		sed -i "$ a bunzip2 ${name}_L${L}_R1.fastq.bz2" hicup_p1_${name}_L${L}.pbs
		sed -i "$ a bunzip2 ${name}_L${L}_R2.fastq.bz2" hicup_p1_${name}_L${L}.pbs

		sed -i "$ a /group/nobrega-lab/grace/bin/fastq-splitter.pl --n-parts 15 --check ${name}_L${L}_R1.fastq" hicup_p1_${name}_L${L}.pbs
		sed -i "$ a /group/nobrega-lab/grace/bin/fastq-splitter.pl --n-parts 15 --check ${name}_L${L}_R2.fastq" hicup_p1_${name}_L${L}.pbs

		sed -i "$ a bzip2 ${name}_L${L}_R1.fastq" hicup_p1_${name}_L${L}.pbs
		sed -i "$ a bzip2 ${name}_L${L}_R2.fastq" hicup_p1_${name}_L${L}.pbs

		p1_jobid=$(qsub hicup_p1_${name}_L${L}.pbs | cut -f1 -d'.')
		

		for i in $(seq -f "%02g" 1 15); do
			cp /group/nobrega-lab/grace/hic/scripts/hicup_example.conf conf/${name}_L${L}_${i}.conf
			sed -i "$ a raw/${name}_L${L}_R1.part-${i}.fastq" conf/${name}_L${L}_${i}.conf
			sed -i "$ a raw/${name}_L${L}_R2.part-${i}.fastq" conf/${name}_L${L}_${i}.conf
		
			if [ ! -f results/${name}_L${L}_R1_2.part-${i}.hicup.bam ]; then

				cat /group/nobrega-lab/grace/hic/scripts/submit_job_example_dependency.pbs | sed "s|<jobname>|hicup_p2_${name}_L${L}_${i}|g" | sed "s|<jobid>|${p1_jobid}|g" | sed "s|mem=250gb|mem=50gb|g" | sed "s|walltime=24:00:00|walltime=12:00:00|g"> hicup_p2_${name}_L${L}_${i}.pbs
				sed -i "$ a cd ${dir}" hicup_p2_${name}_L${L}_${i}.pbs
				sed -i "$ a /group/nobrega-lab/grace/bin/hicup_v0.5.9/hicup --outdir ${dir}/results --config conf/${name}_L${L}_${i}.conf" hicup_p2_${name}_L${L}_${i}.pbs
	
				p2_jobid=$(qsub hicup_p2_${name}_L${L}_${i}.pbs | cut -f1 -d'.')
				p2_jobids+=($p2_jobid)
			fi
		done
	done

#Part 3: recompose split fastq files, run hicup_deduplicator and prep for CHiCAGO
	depend=$(echo "${p2_jobids[*]}" | tr ' ' ':')	
	cat /group/nobrega-lab/grace/hic/scripts/submit_job_example_dependency.pbs | sed "s|<jobname>|hicup_p3_${name}|g" | sed "s|<jobid>|${depend}|g" > hicup_p3_${name}.pbs
	cat /group/nobrega-lab/grace/hic/scripts/submit_job_example.pbs | sed "s|<jobname>|hicup_p3_${name}|g" > hicup_p3_${name}.pbs
	sed -i "$ a cd ${dir}" hicup_p3_${name}.pbs
	
	files_array=()
	for L in $(seq 1 8); do
		for i in $(seq -f "%02g" 1 15); do
			file=results/${name}_L${L}_R1_2.part-${i}.hicup.bam
			files_array+=($file)
		done
	done

	sed -i "$ a samtools cat -o results/${name}_R1_2.hicup.bam ${files_array[*]}" hicup_p3_${name}.pbs

	for L in $(seq 1 8); do
		for i in $(seq -f "%02g" 1 15); do
			sed -i "$ a if [ -f results/${name}_R1_2.part-${i}.hicup.bam ]; then"  hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R1.part-${i}.trunc.fastq.gz" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R2.part-${i}.trunc.fastq.gz" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R1_2.part-${i}.filt.bam" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R1_2.part-${i}.pair.bam" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R1.part-${i}.map.sam" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R2.part-${i}.map.sam" hicup_p3_${name}.pbs
			sed -i "$ a 	rm results/${name}_L${L}_R1_2.part-${i}.HiCUP_summary_report.html" hicup_p3_${name}.pbs
			sed -i "$ a 	rm raw/${name}_L${L}_R1.part-${i}.fastq" hicup_p3_${name}.pbs
			sed -i "$ a 	rm raw/${name}_L${L}_R2.part-${i}.fastq" hicup_p3_${name}.pbs
			sed -i "$ a fi" hicup_p3_${name}.pbs
		done	
	done

	echo "results/${name}_R1_2.hicup.bam" > conf/${name}_deduplicator.conf
	sed -i "$ a /group/nobrega-lab/grace/bin/hicup_v0.5.9/hicup_deduplicator --config conf/${name}_deduplicator.conf --outdir ${dir}/results --threads 1" hicup_p3_${name}.pbs
	sed -i "$ a cd results" hicup_p3_${name}.pbs
	sed -i "$ a samtools view -bS ${name}_R1_2.hicup.dedup.sam > ${name}_R1_2.hicup.dedup.bam" hicup_p3_${name}.pbs
	sed -i "$ a /group/nobrega-lab/grace/hic/scripts/bam2chicago.sh ${name}_R1_2.hicup.dedup.bam ../../design_files/probes-MboI_fragments-v3.baitmap ../../design_files/MboI.rmap ${name}_R1_2" hicup_p3_${name}.pbs
	sed -i "$ a mv ${name}_R1_2/* . && rm -r ${name}_R1_2/" hicup_p3_${name}.pbs

	sed -i "$ a module load gcc/5.4.0 && module load R/3.3.2" hicup_p3_${name}.pbs
	sed -i "$ a /group/nobrega-lab/grace/hic/scripts/run_CHiCAGO.R ${dir}/results/ /group/nobrega-lab/grace/hic/design_files ${name}_R1_2.chinput" hicup_p3_${name}.pbs

	qsub hicup_p3_${name}.pbs

done
