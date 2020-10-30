#!/bin/Rscript
args = commandArgs(trailingOnly=TRUE)
library(Chicago)
library(data.table)


if (length(args)==0) {
  stop("USAGE: CHiCAGO_batch.R <dir> <design_dir> <input_file> <sample_name>\n
       input_file a file to be processed in *chinput format. \n
       a design_files folder must be present in the working directory. \n
       input files must be in <dir> and in *.chinput format.", call.=FALSE)
}

working_dir <- args[1]
design_dir <- args[2]

setwd(working_dir)

input<-args[3]
name<-args[4]

run_chicago <- function(input) {
  name_out <- paste(name,"_nothreshold",sep='')
  analysis <- setExperiment(designDir = design_dir)
  modifySettings(analysis,settings=c(minNPerBait=0,minFragLen=150,maxFragLen=40000,maxLBrownEst=1500000,binsize=20000,removeAdjacent=TRUE))
  analysis <- readAndMerge(files=input, cd=analysis)
  analysis <- chicagoPipeline(analysis)
  
  exportResults(analysis, name_out,cutoff=0)
}

run_chicago(input)

