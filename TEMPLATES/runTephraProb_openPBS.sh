#!/bin/bash

#PBS -N inversionDebug
#PBS -j oe
#PBS -V
#PBS -m n
#PBS -M sbiasse@ntu.edu.sg
#PBS -l nodes=1:ppn=12
#PBS -q q12
#PBS

module load openmpi/1.4.5-gnu

cd $PBS_O_WORKDIR

chunk=`printf "%02d" $PBS_ARRAYID`

mpirun -np 12 -machinefile $PBS_NODEFILE -app saku.txt.$chunk
