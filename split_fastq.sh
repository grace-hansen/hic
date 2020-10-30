#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "USAGE: ./run_hicup_gardner5.sh dir tmp file_R1 file_R2 n_split
	file must be in the format <sample>_<rep#>_L<lane>_R<read 1 or 2>.fastq.gz
	dir is where raw fastqs are located"
	exit 0
fi

dir=$1
tmp=$2
file_R1=$3
file_R2=$4
n_split=$5

if [[ $(echo ${file_R1} | rev | cut -f1 -d'.' | rev) == "bz2" ]]; then
	echo "Compression type: bz2"
	fastq_R1=${file_R1%".bz2"} #Bash magic removes '.bz2' from end
	fastq_R2=${file_R2%".bz2"} #Bash magic removes '.bz2' from end
	name_R1=${file_R1%".fastq.bz2"}
	name_R2=${file_R2%".fastq.bz2"}
	cd $dir

	bunzip2 -c $file_R1 > $fastq_R1 
	bunzip2 -c $file_R2 > $fastq_R2

	/project2/nobrega/grace/hic/scripts/fastq-splitter.pl --n-parts $n_split --check $fastq_R1
	/project2/nobrega/grace/hic/scripts/fastq-splitter.pl --n-parts $n_split --check $fastq_R2
	
	mv $name_R1.part-*.fastq $tmp
	rm $fastq_R1
	mv $name_R2.part-*.fastq $tmp
	rm $fastq_R2

elif [[ $(echo ${file_R1} | rev | cut -f1 -d'.' | rev) == "gz" ]]; then
	echo "Compression type: gz"
	fastq_R1=${file_R1%".gz"} #Bash magic removes '.bz2' from end
	fastq_R2=${file_R2%".gz"} #Bash magic removes '.bz2' from end
	name_R1=${file_R1%".fastq.gz"}
	name_R2=${file_R2%".fastq.gz"}
	cd $dir

	zcat $file_R1 > $fastq_R1 
	zcat $file_R2 > $fastq_R2

	/project2/nobrega/grace/hic/scripts/fastq-splitter.pl --n-parts $n_split --check $fastq_R1
	/project2/nobrega/grace/hic/scripts/fastq-splitter.pl --n-parts $n_split --check $fastq_R2
	
	#mv $name_R1.part-*.fastq $tmp
	rm $fastq_R1
	#mv $name_R2.part-*.fastq $tmp
	rm $fastq_R2
else 
	echo "Compression type unknown; please user files with *gz or *bz2"
	exit 1
fi

