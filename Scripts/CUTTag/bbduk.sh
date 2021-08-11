# bbduk was used to remove adaptor

ls */*_1.fq.gz |while read id
do
  sample_name=${id%%/*}
  /home/dell/anaconda3/envs/RNA/bin/bbduk.sh in1=$id in2=${sample_name}/${sample_name}_2.fq.gz out1=${sample_name}/${sample_name}_1_35bp.fq.gz out2=${sample_name}/${sample_name}_2_35bp.fq.gz ref=/home/dell/anaconda3/envs/RNA/opt/bbmap-38.84-0/resources/adapters.fa ktrim=r k=23 mink=11 hdist=1 minlen=35 tpe tbo
done

