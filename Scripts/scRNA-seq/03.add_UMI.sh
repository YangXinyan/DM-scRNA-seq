# add UMI information to @READ ID

samp=$1
pl_exe=/usr/bin/perl
pl_add_UMI=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA_UMI/RNA_UMI/bin/new0930_add_UMI.pl
dir=`pwd`

ls */*sc*.1.fq.gz |while read id 
do
sample=${id%%/*}
cell_name=${id##*/}
$pl_exe $pl_add_UMI $dir/${sample}/${cell_name%%.*}.1.fq.gz $dir/${sample}/${cell_name%%.*}.2.fq.gz $dir/${sample}/${cell_name%%.*}.umi.fq.gz
echo "${cell_name%%.*} is done"

done        
