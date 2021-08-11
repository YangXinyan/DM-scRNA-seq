# This script is to run genomeCoverageBed and transform bam file to bdg file
# Then generate bigwig file to show in IGV

# chrom=/home/dell/anaconda3/pkgs/igvtools-2.5.3-0/share/igvtools-2.5.3-0/lib/genomes/hg38.chrom.sizes
# chrom=/home/dell/anaconda3/pkgs/igvtools-2.5.3-0/share/igvtools-2.5.3-0/lib/genomes/hg19.chrom.sizes
chrom=/home/dell/anaconda3/pkgs/igvtools-2.5.3-0/share/igvtools-2.5.3-0/lib/genomes/mm10.chrom.sizes

# cat unique_read.txt |while read line
cat unique_read.txt |while read line
do
  scale=`echo $line | awk -F ' ' '{print $1}' `
  samp=`echo $line |awk -F ' ' '{print $2}'`
  samp=${samp%.final*}

  genomeCoverageBed -ibam ../Bam_Chr/${samp}.chr.bam -scale $scale -bg > ${samp}.chr.bdg  && \
        sort -k1,1 -k2,2n ${samp}.chr.bdg | grep -v chrJH |grep -v chrEBV  > ${samp}.chr.sort.bdg  && \
        /home/dell/Software/UCSC/bedGraphToBigWig ${samp}.chr.sort.bdg $chrom ${samp}.bw  && \
#	/home/wd/xinyan/Software/IGV-cli/IGVTools/igvtools toTDF ${samp}.chr.bdg ${samp}.chr.bdg.tdf mm10 > ${samp}.toTDF.log 2>&1 && \
        rm ${samp}.chr.sort.bdg ${samp}.chr.bdg && \
  echo "$samp is done" 

done
