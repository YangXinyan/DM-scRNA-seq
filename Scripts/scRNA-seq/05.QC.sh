# remove low-quality base

samp=$1
data_type=$2
pl_exe=/usr/bin/perl
pl_QC=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA-seq/SingleCell/GSE86146/script/QC_plus_rm_primer-SE_truncatedRease.pl

dir=`pwd`


ls */*sc*.umi.trim.fq.gz |while read id
do
sample=${id%%/*}
cell_file=${id##*/}
cell_name=${cell_file%%.*}
in_dir=$dir/rawData/$sample
out_dir=$dir/cleanData/$sample

mkdir -p $in_dir/$cell_name
mkdir -p $out_dir
cp $dir/$sample/$cell_file $in_dir/$cell_name/$cell_file
$pl_exe $pl_QC --indir $in_dir --outdir $out_dir --sample $cell_name             \
    --end 1

echo "$cell_name id done"

done
