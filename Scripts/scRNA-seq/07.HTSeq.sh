dir=`pwd`

py_exe=/usr/bin/python
samtools_exe=/usr/local/bin/samtools
htseq_exe=/home/wd/anaconda3/bin/htseq-count
umi_HTseq=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA_UMI/RNA_UMI/bin/02_UMI_HTseq.py
TPM=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA_UMI/RNA_UMI/bin/GRCh38_gencode_tpm.py
known_GTF=/home/wd/xinyan/Germline/Species/Homo_sapiens/RNA-seq/Ref/Gencode/gencode.v28.annotation.ERCC92.gtf

# tophat_dir=/media/hobart/WDstore/hyf/PGCwd/project/cleanData/hESC
# HTS_k_dir=/media/hobart/WDstore/hyf/PGCwd/project/countRes/hESC

ls */*sc*/*sc*/accepted_hits.bam |while read id
do
  sample_name=${id%%/*}
  temp=${id#*/}
  cell_name=${temp%%/*}
  HTS_k_dir=$dir/countRes

  chmod u+x $id

  samtools sort -n -m 200000000 $id -o $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.bam 

  samtools view $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.bam  \
           -o $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.sam    


  [ ! -d $HTS_k_dir/$sample_name/$cell_name ] && mkdir -p $HTS_k_dir/$sample_name/$cell_name

  $htseq_exe                                                                          \
      -s no -f sam -a 10                                                              \
      $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.sam              \
      $known_GTF                                                                      \
      -o $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.gene.sam      \
      >$HTS_k_dir/$sample_name/$cell_name/$cell_name.dexseq.txt                     &&\

  grep -v -P '^ERCC-|^RGC-|MIR|SNORD|Mir|Snord'                                       \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.dexseq.txt                        \
     >$HTS_k_dir/$sample_name/$cell_name/$cell_name.dexseq_clean_gene.txt           &&\

  grep -P '^ERCC-'                                                                    \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.dexseq.txt                        \
     >$HTS_k_dir/$sample_name/$cell_name/$cell_name.dexseq_ERCC_RGCPloyA.txt          \

  $py_exe $umi_HTseq                                                                  \
      $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.gene.sam         \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi.txt

  grep -v -P '^ERCC-|^RGC-|MIR|SNORD|Mir|Snord'                                       \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi.txt                           \
     >$HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_gene.xls	            &&\
    
  grep -P '^ERCC-|^RGC-'                                                              \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi.txt                           \
     >$HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_ERCC.xls	            &&\

  cat $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_gene.xls                \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_ERCC.xls                \
     >$HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_gene_ERCC.xls

  rm  $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.sam              \
      $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.bam              \
      $dir/$sample_name/$cell_name/$cell_name/accepted_hits.umi.sort.gene.sam         \

  $py_exe $TPM                                                                        \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_gene.xls                \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_tpm_gene.xls                  \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_clean_gene_ERCC.xls           \
      $HTS_k_dir/$sample_name/$cell_name/$cell_name.umi_tpm_gene_ERCC.xls

  echo "$cell_name is done."

done


        
