#!/bin/bash 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=03:00:00 
#SBATCH --mem=2GB
#SBATCH --err="output/smooth_pop_up_%j.err" 
#SBATCH --output="output/smooth_pop_up_%j.out" 
#SBATCH --job-name="smooth_pop_up_%j"

# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran

mkdir -p output

EES=$1
MS=$2
CCT=$3
VF=$4

module load matlab/2016b
module unload OpenMPI
module unload HDF5


for RUN in $(seq 1 1 10)
do
		echo "-ees" ${EES} "-ms" ${MS} "-cct" ${CCT} "-vf" ${VF} "-run " ${RUN};
	 /home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -ees ${EES} -ms ${MS} -cct ${CCT} -vf ${VF} -run  ${RUN};

done