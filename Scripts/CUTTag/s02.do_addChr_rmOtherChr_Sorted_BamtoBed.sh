# Because of ENSEMBL version genome dont have "chr", so this script is to add "chr" in bam file
# And remove other chr number

ls *.final.dedup.bam |while read id
do
  samp=${id%.final.dedup.bam}

  ### add chr in header (only in chr1-22 X Y MT)
  nohup samtools view -@ 8 -h $id | sed -e '/^@SQ/s/SN\:/SN\:chr/' -e '/^[^@]/s/\t/\tchr/2' | grep -v 'chrKI' | grep -v 'chrGL'| grep -v 'chrJH' | samtools view -@ 8 -bS - > ${samp}.chr.bam  && \
  samtools sort -@ 3 -n ${samp}.chr.bam -o ${samp}.chr.sortRead.bam && \
  bamToBed -i ${samp}.chr.sortRead.bam -bedpe > ${samp}.chr.sortRead.bed  && \
  cat ${samp}.chr.sortRead.bed |grep -v WARNING > ${samp}.final.bed && \
  rm ${samp}.chr.sortRead.bam ${samp}.chr.sortRead.bed &
done
