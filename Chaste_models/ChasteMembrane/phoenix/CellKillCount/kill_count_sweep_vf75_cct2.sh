#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=00:10:00 
#SBATCH --mem=4GB 
#SBATCH --array=0-4000
#SBATCH --err="output/kill_count_vf75_cct2_%a.err" 
#SBATCH --output="output/kill_count_vf75_cct2_%a.out" 
#SBATCH --job-name="kill_count_vf75_cct2"
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module unload OpenMPI
mkdir -p output 

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read es ms
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "kill count sweep with $es, $ms"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < kill_count_params.txt 

if [ $found = 1 ]; then

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -ees ${es} -ms ${ms}";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -ees ${es} -ms ${ms} -vf 0.75
else 
  echo "kill_count_params.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi