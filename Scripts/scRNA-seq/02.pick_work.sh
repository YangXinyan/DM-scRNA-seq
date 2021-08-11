# Base on the information of @READ ID in fastq file in .2.fq.gz, split 96 single cell .1.fq.gz from R1.fastq.gz

ls *sc*.2.* | while read id 
do
sh 02.pick.sh ${id%%.*}
echo "$id is done."
done
