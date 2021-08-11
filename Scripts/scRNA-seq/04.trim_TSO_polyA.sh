# remove TSO sequence and ployA

samp=$1
pl_exe=/usr/bin/perl
pl_trim=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA_UMI/RNA_UMI/bin/trim_TSO_polyA.pl
dir=`pwd`

ls */*sc*.umi.fq.gz |while read id
do
sample=${id%%/*}
cell_name=${id##*/}
$pl_exe $pl_trim $dir/${sample}/${cell_name%%.*}.umi.fq.gz $dir/${sample}/${cell_name%%.*}.umi.trim.fq.gz 0
echo "${cell_name%%.*} is done"
done
        
