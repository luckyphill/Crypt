#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=8GB 
#SBATCH --array=0-10
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2019a

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); r = RodsInChannel(10,5, 20, 5, 0.1, 4, $SLURM_ARRAY_TASK_ID);r.RunToTime(300); quit()"
