#!/bin/bash

# fastq and multiqc

fastqc fastq_file/*
multiqc fastq_file/* .

# mv html and zip file in other directory

mkdir fastq_file/multiqc_html_zip
mv fastq_file/*html multiqc_html_zip
mv fastq_file/*zip multiqc_html_zip
