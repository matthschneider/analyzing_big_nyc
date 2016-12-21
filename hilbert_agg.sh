#!/bin/bash

#PBS -l select=1:ncpus=8:mem=50gb
#PBS -l walltime=01:59:00
#PBS -r n
#PBS -N Schneider
#PBS -A "SinStatEc"
#PBS -m e

module load R

R CMD BATCH --slave hilbert_agg.R hilbert_agg.Rout
