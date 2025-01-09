#!/bin/bash

mkdir PEAR_fastq

# Assembled reads with a Phred quality score greater than 30.

fastq=($(ls raw_data_fastq/*.gz))
tLen=${#fastq[@]}
for (( i=0; i<${tLen}; i=i+2));
do
x=${fastq[$i]##*/}
pear -f ${fastq[$i]} -r ${fastq[$i+1]} -o PEAR_fastq/${x%_L*} -j 20 -q 30
done

# Move only assembled pairs

mkdir PEAR_assambled
mv PEAR_fastq/*assembled.fastq PEAR_assambled


figlet done

