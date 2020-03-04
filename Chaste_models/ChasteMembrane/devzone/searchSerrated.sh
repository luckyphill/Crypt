#!/bin/bash 
#SBATCH -p test
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=01:00:00 
#SBATCH --mem=4GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

module load matlab/2019b


echo "matlab -nodisplay -nodesktop -r searchSerrated; quit()"
matlab -nodisplay -nodesktop -r "searchSerrated; quit()"
