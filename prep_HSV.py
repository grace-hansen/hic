#!/usr/bin/python

import gzip, subprocess
import argparse
import pandas as pd
parser = argparse.ArgumentParser()
parser.add_argument("dir", help="full path to HSV directory you're analyzing. File 'IDs' should be there, with paths to 3 ibeds to process")
args=parser.parse_args()
##################################
dir=args.dir

IDs=open("%s/IDs"%dir,'r').readlines()
IDs=[i.strip() for i in IDs]


################## Remove interactions > 1MB and trans interactions ##################

ibed1=pd.read_csv(IDs[0],sep='\t')
ibed1=ibed1[ibed1['bait_chr']==ibed1['otherEnd_chr']]
ibed1=ibed1[abs(ibed1['bait_start']-ibed1['otherEnd_start'])<1000000]
ibed1=ibed1.rename(columns={"N_reads": "nreads1", "score": "score1"})

ibed2=pd.read_csv(IDs[1],sep='\t')
ibed2=ibed2[ibed2['bait_chr']==ibed2['otherEnd_chr']]
ibed2=ibed2[abs(ibed2['bait_start']-ibed2['otherEnd_start'])<1000000]
ibed2=ibed2.rename(columns={"N_reads": "nreads2", "score": "score2"})


ibed3=pd.read_csv(IDs[2],sep='\t')
ibed3=ibed3[ibed3['bait_chr']==ibed3['otherEnd_chr']]
ibed3=ibed3[abs(ibed3['bait_start']-ibed3['otherEnd_start'])<1000000]
ibed3=ibed3.rename(columns={"N_reads": "nreads3", "score": "score3"})

############### Merge interactions ##################
ibed1_2=ibed1.merge(ibed2,on=['bait_chr','bait_start','bait_end','otherEnd_chr','otherEnd_start','otherEnd_end'])
interactions=ibed3.merge(ibed1_2,on=['bait_chr','bait_start','bait_end','otherEnd_chr','otherEnd_start','otherEnd_end'])
interactions.to_csv("%s/interactions_tmp.txt"%dir,sep='\t',index=False)