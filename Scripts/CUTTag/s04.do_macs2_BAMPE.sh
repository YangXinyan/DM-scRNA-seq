### This script will run macs2 to do peak calling

ls ../../Bam_Chr/*chr.bam |while read id
do
  samp=${id##*/}
  samp=${samp%.bam}
  macs2 callpeak --verbose 3 -t $id -n $samp -g mm -f BAMPE --cutoff-analysis -B --call-summits > $samp.rr 2>&1
done

