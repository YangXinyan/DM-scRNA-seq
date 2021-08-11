perl=/WPSnew/lilin/bin/RNA_UMI/bin/fqpick.pl
sample=$1
total_fq1=$2
perl $perl $sample.2.fq.gz $total_fq1 $sample.1.fq.gz

