s=$1
perl=fqpick.pl
fq1=$s.2.fq.gz
fq2=160826_wwl_ko_R1.fastq.gz
out1=$s.1.fq.gz
perl $perl $fq1 $fq2 $out1
