#-*- coding:utf-8 -*-
from __future__ import division
import re
import sys
import os
import subprocess
import cPickle as pickle
import time

import RNA_UMI.utils.module_running_jobs as m_jobs
import RNA_UMI.settings.projpath         as m_proj
import RNA_UMI.settings.scripts          as m_scpt

def make_dir(l_args):
    """docstring for make_dir"""
    if len(l_args) == 1:
        """ only dictionary """
        if not os.path.isdir( l_args[0] ):
            os.mkdir( l_args[0] )
    
    elif len(l_args) == 2:
        """ dictionary/sample """
        if not os.path.isdir( l_args[0] ):
            os.mkdir( l_args[0] )
        if not os.path.isdir( "%s/%s" % (l_args[0],l_args[1]) ):
            os.mkdir(         "%s/%s" % (l_args[0],l_args[1]) )

    elif len(l_args) == 3:
        """ dictionary/sample/subname """
        if not os.path.isdir( l_args[0] ):
            os.mkdir( l_args[0] )
        if not os.path.isdir( "%s/%s"    % (l_args[0],l_args[1]) ):
            os.mkdir(         "%s/%s"    % (l_args[0],l_args[1]) )
        if not os.path.isdir( "%s/%s/%s" % (l_args[0],l_args[1],l_args[2]) ):
            os.mkdir(         "%s/%s/%s" % (l_args[0],l_args[1],l_args[2]) )


class Map_From_raw(m_scpt.Scripts):
    
    def __init__(self, ref, sam_RNAinfo, is_debug=1):
        super(Map_From_raw, self).__init__()
        
        self.s_idx = ".".join(sam_RNAinfo.split("/")[-1].split(".")[:-1])
        
        self.load_RNA_samInfo(sam_RNAinfo)
        self.define_scripts(self.s_idx)
        self.define_fastq(self.s_idx)

        self.ref = ref
        self.is_debug = is_debug
        self.define_files(self.ref)
        self.M_CvtEnd = {"PE":2,"SE":1}
       
    def s001_add_UMI(self):
        sh_file      = "%s/s001.add_UMI.sh"         % (self.scripts)
        sh_work_file = "%s/s001.add_UMI_work.sh"    % (self.scripts)

        l_sh_info = self.s_001_add_UMI()
        l_sh_work = []
        for samp in self.samInfo_pd_RNA['sample']:
            l_sh_work.append("sh %s %s" % (sh_file, samp) )

        my_job = m_jobs.run_jobs(sh_file, sh_work_file, l_sh_info, l_sh_work)
#        my_job.running_multi(cpu=10, is_debug = self.is_debug)
        my_job.running_SGE(vf="3G", maxjob=100, is_debug = self.is_debug)

    def s002_trim_TSO_polyA(self):
        sh_file      = "%s/s002.trim_TSO_polyA.sh"         % (self.scripts)
        sh_work_file = "%s/s002.trim_TSO_polyA_work.sh"    % (self.scripts)

        l_sh_info = self.s_002_trim_TSO_polyA()
        l_sh_work = []
        for samp in self.samInfo_pd_RNA['sample']:
            make_dir(  [ self.dir_raw_data, samp ] )
            l_sh_work.append("sh %s %s" % (sh_file, samp) )

        my_job = m_jobs.run_jobs(sh_file, sh_work_file, l_sh_info, l_sh_work)
#        my_job.running_multi(cpu=10, is_debug = self.is_debug)
        my_job.running_SGE(vf="3G", maxjob=100, is_debug = self.is_debug)


    def s01_QC(self):
        sh_file      = "%s/s01.QC.sh"      % (self.scripts)
        sh_work_file = "%s/s01.QC_work.sh" % (self.scripts)
        
        l_sh_info = self.s_01_QC()
        l_sh_work = []
        for samp in self.samInfo_pd_RNA['sample']:
            make_dir(  [ self.dir_clean_data, samp ] )
            idx       = (self.samInfo_pd_RNA['sample'] == samp)
            end       = self.samInfo_pd_RNA[ idx ]['end_type'].values[0]
            data_dype = self.M_CvtEnd[ end ]
            l_sh_work.append("sh %s %s %d" % (sh_file, samp, data_dype) )
      
        my_job = m_jobs.run_jobs(sh_file, sh_work_file, l_sh_info, l_sh_work)
#        my_job.running_multi(cpu=10, is_debug = self.is_debug)
        my_job.running_SGE(vf="2G", maxjob=100, is_debug = self.is_debug)


    def s02_Tophat(self):
        sh_file      = "%s/s02.Tophat.sh"      % (self.scripts)
        sh_work_file = "%s/s02.Tophat_work.sh" % (self.scripts)
        
        l_sh_info = self.s_02_Tophat()
        l_sh_work = []
        for samp in self.samInfo_pd_RNA['sample']:
            idx       =(self.samInfo_pd_RNA['sample'] == samp)
            brief_name= self.samInfo_pd_RNA[ idx ]['brief_name'].values[0]
            make_dir( [ self.dir_tophat, brief_name ] )
            end       = self.samInfo_pd_RNA[ idx ]['end_type'].values[0]
            data_dype = self.M_CvtEnd[ end ]
            l_sh_work.append("sh %s  %s %s %d"                              %\
                (sh_file, samp, brief_name, data_dype))

        my_job = m_jobs.run_jobs(sh_file, sh_work_file, l_sh_info, l_sh_work)
#        my_job.running_multi(cpu=6, is_debug = self.is_debug)
        my_job.running_SGE(vf="7G", maxjob=100, is_debug = self.is_debug)

       
    def s03_HTSeq_known(self):
        sh_file      = "%s/s03.HTSeq.sh"      % (self.scripts)
        sh_work_file = "%s/s03.HTSeq_work.sh" % (self.scripts)

        l_sh_info = self.s_03_HTSeq_known()
        l_sh_work = []
        for brief_name in self.samInfo_pd_RNA['brief_name']:
            make_dir([ self.dir_HTS_known, brief_name ])
            l_sh_work.append("sh %s  %s  %s" % (sh_file, brief_name, self.ref))

        my_job = m_jobs.run_jobs(sh_file, sh_work_file, l_sh_info, l_sh_work)
#        my_job.running_multi(cpu=8, is_debug = self.is_debug)
        my_job.running_SGE(vf="3G", maxjob=100, is_debug = self.is_debug)


    def s04_mergeCount(self):
        make_dir([ self.dir_mergeCout ,self.s_idx ])
        mergeCount = "%s/%s/%s.UMI_count.xls" % (self.dir_mergeCout ,self.s_idx, self.s_idx)
        f_mergeCount = open(mergeCount, "w")
        l_file = [ "%s/%s/%s.umi_tpm_gene_ERCC.xls" %
            (self.dir_HTS_known, sam, sam)
            for sam in self.samInfo_pd_RNA['brief_name']
            ]

        print >>f_mergeCount, "Gene\t%s" % ("\t".join(self.samInfo_pd_RNA['brief_name']))
        shell_info = " paste %s " % (" ".join(l_file))
        p=subprocess.Popen(shell_info,stdout=subprocess.PIPE,shell=True)
        for line in p.stdout:
            line = line.strip('\n')
            f   = line.split()
            info = "%s" %(f[0])
            l_out_count = []
            for i in xrange(len(self.samInfo_pd_RNA['brief_name'])):
                count = f[1+i*3]
                l_out_count.append(count)

            print >>f_mergeCount, "%s\t%s" %(info, "\t".join(l_out_count))
        f_mergeCount.close()

    def s05_mergeTPM(self):
        mergeTPM   = "%s/%s/%s.UMI_TPM.xls"   % (self.dir_mergeCout ,self.s_idx, self.s_idx)
        f_mergeTPM   = open(mergeTPM,   "w")
        l_file = [ "%s/%s/%s.umi_tpm_gene_ERCC.xls" %
            (self.dir_HTS_known, sam, sam)
            for sam in self.samInfo_pd_RNA['brief_name']
            ]

        print >>f_mergeTPM, "Gene\t%s" % ("\t".join(self.samInfo_pd_RNA['brief_name']))
        shell_info = " paste %s " % (" ".join(l_file))
        p=subprocess.Popen(shell_info,stdout=subprocess.PIPE,shell=True)
        for line in p.stdout:
            line = line.strip('\n')
            f   = line.split()
            info = "%s" %(f[0])
            l_out_tpm   = []
            for i in xrange(len(self.samInfo_pd_RNA['brief_name'])):
                TPM   = f[2+i*3]
                l_out_tpm.append(TPM)

            print >>f_mergeTPM, "%s\t%s" %(info, "\t".join(l_out_tpm))
        f_mergeTPM.close()

    def s06_mergeCount_no_ERCC(self):
        #make_dir([ self.dir_mergeCout ,self.s_idx ])
        mergeCount = "%s/%s/%s.UMI_count_no_ERCC.xls" % (self.dir_mergeCout ,self.s_idx, self.s_idx)
        f_mergeCount = open(mergeCount, "w")
        l_file = [ "%s/%s/%s.umi_tpm_gene.xls" %
            (self.dir_HTS_known, sam, sam)
            for sam in self.samInfo_pd_RNA['brief_name']
            ]

        print >>f_mergeCount, "Gene\t%s" % ("\t".join(self.samInfo_pd_RNA['brief_name']))
        shell_info = " paste %s " % (" ".join(l_file))
        p=subprocess.Popen(shell_info,stdout=subprocess.PIPE,shell=True)
        for line in p.stdout:
            line = line.strip('\n')
            f   = line.split()
            info = "%s" %(f[0])
            l_out_count = []
            for i in xrange(len(self.samInfo_pd_RNA['brief_name'])):
                count = f[1+i*3]
                l_out_count.append(count)

            print >>f_mergeCount, "%s\t%s" %(info, "\t".join(l_out_count))
        f_mergeCount.close()

    def s07_mergeTPM_no_ERCC(self):
        mergeTPM   = "%s/%s/%s.UMI_TPM_no_ERCC.xls"   % (self.dir_mergeCout ,self.s_idx, self.s_idx)
        f_mergeTPM   = open(mergeTPM,   "w")
        l_file = [ "%s/%s/%s.umi_tpm_gene.xls" %
            (self.dir_HTS_known, sam, sam)
            for sam in self.samInfo_pd_RNA['brief_name']
            ]

        print >>f_mergeTPM, "Gene\t%s" % ("\t".join(self.samInfo_pd_RNA['brief_name']))
        shell_info = " paste %s " % (" ".join(l_file))
        p=subprocess.Popen(shell_info,stdout=subprocess.PIPE,shell=True)
        for line in p.stdout:
            line = line.strip('\n')
            f   = line.split()
            info = "%s" %(f[0])
            l_out_tpm   = []
            for i in xrange(len(self.samInfo_pd_RNA['brief_name'])):
                TPM   = f[2+i*3]
                l_out_tpm.append(TPM)

            print >>f_mergeTPM, "%s\t%s" %(info, "\t".join(l_out_tpm))
        f_mergeTPM.close()


