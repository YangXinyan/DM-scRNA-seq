dir=`pwd`
s=$1
perl=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA_UMI/fqpick_raw.pl
fq1=$s.2.fq.gz
fq2=${dir##*/}_1.fq.gz
out1=$s.1.fq.gz
perl $perl $fq1 $fq2 $out1
