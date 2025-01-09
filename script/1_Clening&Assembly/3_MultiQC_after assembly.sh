#!/bin/bash

# fastq and multiqc

fastqc raw_data_fastq/*
multiqc raw_data_fastq/* .

# move html and zip files in other directory

mkdir raw_data_fastq/multiqc_html_zip
mv raw_data_fastq/*html multiqc_html_zip
mv raw_data_fastq/*zip multiqc_html_zip
