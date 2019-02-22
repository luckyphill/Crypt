#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=00:30:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-1000
#SBATCH --err="output/random_search_%a.err" 
#SBATCH --output="output/random_search_%a.out" 
#SBATCH --job-name="random_search"
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
while IFS=, read n ees ms vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Random Search: -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < random_search.txt 

if [ $found = 1 ]; then

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf}";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf} -dt 0.001
else 
  echo "random_search.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi