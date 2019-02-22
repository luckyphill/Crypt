#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=02:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-4000
#SBATCH --err="output/grid_search_1_%a.err" 
#SBATCH --output="output/grid_search_1_%a.out" 
#SBATCH --job-name="grid_search_1"
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
        echo "grid Search: -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < grid_search_1.txt 

if [ $found = 1 ]; then
	for RUN in $(seq 1 1 10)
	do

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf} -run ${RUN}";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf} -dt 0.001 -run ${RUN}
	done
else 
  echo "grid_search_1.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi