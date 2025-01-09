#!/bin/bash

# Generate the metadata file that will be used for qiime2

mkdir data
echo -e "sample-id\tabsolute-filepath" > data/manifest.tsv
for f in `ls PEAR_assambled/*fastq`; do n=`basename $f`; echo -e "12802.${n%.fastq.gz}\t$PWD/$f"; done >> data/manifest.tsv


############################## active QIIME2 v.2022.2 ##############################
source activate qiime2-2022.2

mkdir -p qiime2/qzv qiime2/qza

qiime tools import \
--input-path data/manifest.tsv \
--type 'SampleData[SequencesWithQuality]' \
--input-format SingleEndFastqManifestPhred33V2 \
--output-path qiime2/qza/Fastqs.qza

qiime demux summarize \
--i-data qiime2/qza/Fastqs.qza \
--o-visualization qiime2/qzv/se-demux.qzv

# Denoising
qiime dada2 denoise-single \
--i-demultiplexed-seqs qiime2/qza/Fastqs.qza \
--p-trim-left 20 \
--p-trunc-len 450 \
--p-n-threads 20 \
--o-denoising-stats qiime2/qza/stats-dada2.qza \
--o-representative-sequences qiime2/qza/seqs-dada2.qza \
--o-table qiime2/qza/table-dada2.qza

# Visualization
qiime feature-table tabulate-seqs \
--i-data qiime2/qza/seqs-dada2.qza \
--o-visualization qiime2/qzv/rep-seqs-dada2.qzv

# Check the depth of the samples
qiime feature-table summarize \
--i-table qiime2/qza/table-dada2.qza \
--m-sample-metadata-file data/sample-metadata.txt \
--o-visualization qiime2/qzv/table-dada2.qzv

qiime metadata tabulate \
--m-input-file qiime2/qza/stats-dada2.qza \
--o-visualization qiime2/qzv/denoising-stats.qzv

# Phylogeny
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences qiime2/qza/seqs-dada2.qza \
--o-alignment qiime2/qza/aligned-rep-seqs.qza \
--o-masked-alignment qiime2/qza/masked-aligned-rep-seqs.qza \
--o-tree qiime2/qza/unrooted-tree.qza \
--o-rooted-tree qiime2/qza/rooted-tree.qza

# Taxonomic classification using SILVA 138 database

mkdir tmp
export TMPDIR=tmp
silva138=PATH_DATABASE/silva-138-99-nb-classifier.qza

qiime feature-classifier classify-sklearn \
--i-classifier $silva138 \
--i-reads qiime2/qza/seqs-dada2.qza \
--o-classification qiime2/qza/taxonomy.qza

qiime metadata tabulate \
--m-input-file qiime2/qza/taxonomy.qza \
--m-input-file qiime2/qza/seqs-dada2.qza \
--o-visualization qiime2/qzv/taxonomy.qzv

# Rarefaction
qiime diversity alpha-rarefaction \
  --i-table qiime2/qza/table-dada2.qza \
  --i-phylogeny qiime2/qza/rooted-tree.qza \
  --p-max-depth 30000 \
  --m-metadata-file data/sample-metadata.txt \
  --o-visualization qiime2/qzv/alpha-rarefaction.qzv

qiime taxa barplot \
  --i-table qiime2/qza/table-dada2.qza \
  --i-taxonomy qiime2/qza/taxonomy.qza \
  --m-metadata-file data/sample-metadata.txt \
  --o-visualization qiime2/qzv/taxa-bar-plots.qzv

end=`date +%s`
runtime=$((end-start))
echo 'run time = ' $runtime'(sec)'

figlet done 
