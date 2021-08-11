sh 01.QC.sh > 01.QC.out 2>&1          && \
sh 02.bowtie-samtools.sh > 02.bowtie-samtools.out 2>&1    && \
sh 03.remove_chrM_dup.sh > 03.remove_chrM_dup.out  2>&1 
