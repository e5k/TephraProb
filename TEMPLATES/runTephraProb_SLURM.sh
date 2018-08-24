#!/bin/bash

#SBATCH --cpus-per-task=16
#SBATCH -n 1
#SBATCH -p askja
#SBATCH --output=slurm-%J.out
#SBATCH --job-name=ERSv2_large
#SBATCH -t 0-12:00:00

module load GCC/4.9.3-2.25
module load OpenMPI/1.10.2
module load parallel

chunk=`printf "%02d" $SLURM_ARRAY_TASK_ID`

srun parallel -j 16 -a ERSv2_large.txt.$chunk