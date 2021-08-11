dir=`pwd`

index=/home/wd/xinyan/Germline/Species/Homo_sapiens/Index/Gencode/Hisat2_ERCC_Index/Homo_sapiens.GRCh38.Gencode.ERCC92.genome
gtf_file=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA-seq/Ref/Gencode/gencode.v28.annotation.ERCC92.gtf
gtf_ss=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA-seq/Ref/Gencode/gencode.v28.annotation.ERCC92.for.hisat2.ss
gtf_exon=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA-seq/Ref/Gencode/gencode.v28.annotation.ERCC92.for.hisat2.exon

ls */*/*sc*.R1.clean.fq.gz |while read id
do
  sample=${id%%/*}
  cell_name=${id##*/}
  cell_dir=${cell_name%%.*}
  mkdir -p $dir/$sample/$cell_dir/$cell_dir
  hisat2 --known-splicesite-infile $gtf_ss --dta -t -p 8 -x $index -U $id -S $dir/$sample/$cell_dir/$cell_dir/accepted_hits.sam 1>$dir/$sample/$cell_dir/$cell_dir/alignment_summary.txt 2>&1
  samtools view -@ 8 -bS $dir/$sample/$cell_dir/$cell_dir/accepted_hits.sam -o $dir/$sample/$cell_dir/$cell_dir/accepted_hits.bam
  
  echo "$cell_name is done."

done
