# This script will run bowtie2 alignment and samtools (view/sort...)
#BowtieIndex=/home/wd/xinyan/Germline/Species/Mouse/Index/Ensembl/Bowtie2Index/Mus_musculus.GRCm38.Ensembl.genome
BowtieIndex=/home/dell/xinyan/Developmental/Mouse/Index/Ensembl/Bowtie2Index/Mus_musculus.GRCm38.Ensembl.genome
# BowtieIndex=/home/dell/xinyan/Developmental/Homo_sapiens/Index/Ensembl/Bowtie2Index/Homo_sapiens.GRCh38.Ensembl.genome
# BowtieIndex=/home/dell/xinyan/Developmental/Homo_sapiens/hg19_From_LiLin/Bowtie2_Index/hg19.genome

ls */*_1_35bp_paired.fq.gz |while read id
do
  sample=${id%%/*}
  bowtie2 -q --phred33 --very-sensitive --end-to-end -p 2 --reorder -x $BowtieIndex -1 $id -2 ${sample}/${sample}_2_35bp_paired.fq.gz -S ${sample}/${sample}.sam 1>$sample/${sample}.align.log 2>&1
  samtools view -@ 6 -bhS -q 35 $sample/${sample}.sam -o $sample/${sample}.unique.bam
  samtools sort -@ 6 $sample/${sample}.unique.bam -o $sample/${sample}.unique.sorted.bam
  samtools flagstat $sample/${sample}.unique.sorted.bam 1>$sample/${sample}.mapping.log 2>&1
  samtools index -@ 6 $sample/${sample}.unique.sorted.bam
  samtools idxstats $sample/${sample}.unique.sorted.bam > $sample/${sample}.unique.sorted.mitochondrial.stats
  picard EstimateLibraryComplexity I=$sample/${sample}.unique.sorted.bam O=$sample/${sample}.unique.sorted.bam_est_lib_complex_metrics.txt

  rm ${sample}/${sample}.unique.bam
  rm ${sample}/${sample}.sam

  echo "$id is done"
done

