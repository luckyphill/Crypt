#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1
#SBATCH --time=72:00:00 
#SBATCH --mem=16GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

export TZ=Australia/Adelaide
export CHASTE_TEST_OUTPUT=/fast/users/a1738927/testoutput/

module load matlab/2019b

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

mkdir -p output

script=$1

echo "-nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); $script; quit()"
matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); $script; quit()"