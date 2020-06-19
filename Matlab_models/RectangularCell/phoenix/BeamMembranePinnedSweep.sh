#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=1GB 
#SBATCH --array=0-880
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2019a

mkdir -p output


echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read p g w b
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then
        n=$((2*w))
        echo "Running Pinned Beam Membrane Sweep with n = $n, p = $p, g = $g, w = $w, b = $b"
        found=1 

        break 
    fi 
    i=$((i + 1)) 
done < BeamMembraneSweep.txt

if [ $found = 1 ]; then
	for seed in $(seq 1 1 10)
	do
		echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); obj = RunBeamMembranePinned($n, $p, $g, $w, $b, $seed); obj.RunSimulation(); quit()"
	    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); obj = RunBeamMembranePinned($n, $p, $g, $w, $b, $seed); obj.RunSimulation(); quit()"
	done
else 
  echo "BeamMembraneSweep.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi