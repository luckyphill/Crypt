#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=00:15:00 
#SBATCH --mem=2GB 
#SBATCH --array=0-7564
#SBATCH --err="output/kill_count_cct8_%a.err" 
#SBATCH --output="output/kill_count_cct8_%a.out" 
#SBATCH --job-name="kill_count_cct8"
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
while IFS=, read es ms vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "kill count sweep with $es, $ms, $vf"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < kill_count_params.txt 

if [ $found = 1 ]; then

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -ees ${es} -ms ${ms} -vf ${vf}";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -ees ${es} -ms ${ms} -vf ${vf} -cct 8
else 
  echo "kill_count_params.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi