# This script is to use samtools to remove chrMT
# view mitochondrial.stats and duplicate

ls */*.unique.sorted.bam |while read id
do
  sample=${id%%/*}
  
  samtools view -h $sample/${sample}.unique.sorted.bam |grep -v 'MT' | samtools view -bS -o $sample/${sample}.final.bam
  
  picard EstimateLibraryComplexity I=$sample/${sample}.final.bam O=$sample/${sample}.final.bam_est_lib_complex_metrics.txt

  picard MarkDuplicates REMOVE_DUPLICATES=True I=$sample/${sample}.final.bam O=$sample/${sample}.final.dedup.bam M=$sample/${sample}.final.marked_dup_metrics.txt
  
  samtools index -@ 6 $sample/${sample}.final.dedup.bam

  echo "$sample is done"
done
