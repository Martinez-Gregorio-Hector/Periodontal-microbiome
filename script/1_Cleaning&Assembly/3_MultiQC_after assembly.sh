#!/bin/bash

# fastq and multiqc

fastqc PEAR_assambled/*
multiqc PEAR_assambled/* .

# move html and zip files in other directory

mkdir PEAR_assambled/multiqc_html_zip
mv PEAR_assambled/*html multiqc_html_zip
mv PEAR_assambled/*zip multiqc_html_zip
