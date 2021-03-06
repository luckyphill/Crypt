#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=10:00:00
#SBATCH --mem=1GB 
#SBATCH --array=0-9900
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2019a

mkdir -p output


echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read n p g w
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then
        echo "Running FixedDomain Buckle Sweep with n = $n, p = $p, g = $g, w = $w"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < BuckleSweepFixedDomain.txt

if [ $found = 1 ]; then
	for seed in $(seq 1 1 10)
	do
		echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); obj = RunFixedDomainBuckle($n, $p, $g, $w, $seed); obj.GenerateSimulationData(); quit()"
	    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); obj = RunFixedDomainBuckle($n, $p, $g, $w, $seed); obj.GenerateSimulationData(); quit()"
	done
else 
  echo "BuckleSweepFixedDomain.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi