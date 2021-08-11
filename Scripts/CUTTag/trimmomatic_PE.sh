# trimmomatic was used to remove low-quality reads

trimmomatic=/home/dell/anaconda3/envs/RNA/share/trimmomatic-0.39-1/trimmomatic.jar
#trimmomatic=/home/wd/xinyan/Software/Trimmomatic-0.38/trimmomatic-0.38.jar
ls */*_1_35bp.fq.gz |while read id
do
  sample_name=${id%%/*}
  java -jar $trimmomatic PE -phred33 $id ${sample_name}/${sample_name}_2_35bp.fq.gz  ${sample_name}/${sample_name}_1_35bp_paired.fq.gz ${sample_name}/${sample_name}_1_35bp_unpaired.fq.gz ${sample_name}/${sample_name}_2_35bp_paired.fq.gz ${sample_name}/${sample_name}_2_35bp_unpaired.fq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:35
done
