#!/bin/bash

#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=48:00:00
#SBATCH --mem=2GB

# Configure notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

EES=$1
N=$2
CCT=$3
VF=$4


module load matlab/2016b
module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

matlab -nodisplay -nodesktop -r "pop_up_limit(${EES}, ${N}, ${CCT}, ${VF}, 39, 9, 7); quit()"