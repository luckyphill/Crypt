#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=02:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-9261%120
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

mkdir -p output


echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read n np ees ms cct vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Parameter optimisation with: -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -vf ${vf}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $1

if [ $found = 1 ]; then

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -vf ${vf} -run 1";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptColumn -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -vf ${vf} -run 1

else 
  echo "grid_search_1.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi