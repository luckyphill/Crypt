#!/bin/bash

#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=15:00:00
#SBATCH --mem=2GB

# Configure notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran

mkdir -p output

CCT=$1
VF=$2

module load matlab/2016b
module unload OpenMPI
module unload HDF5
matlab -nodisplay -nodesktop -r "find_pop_up_limit_phoenix(${CCT}, ${VF}); quit()"