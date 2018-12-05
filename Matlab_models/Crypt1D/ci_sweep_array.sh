#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=05:00:00 
#SBATCH --mem=2GB 
#SBATCH --array=0-400
#SBATCH --err="output/ci_sweep_%a.err" 
#SBATCH --output="output/ci_sweep_%a.out" 
#SBATCH --job-name="ci_sweep"
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2016b
mkdir -p output 

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read s f
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "ci_server_sweep($s,$f,400)"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < sweep.txt 
if [ $found = 1 ]; then 

	echo "Parameters $s, $f with 400 runs"
	matlab -nodisplay -nodesktop -singleCompThread -r "ci_server_sweep($s,$f,400); quit()"

else 
  echo "sweep_data.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi