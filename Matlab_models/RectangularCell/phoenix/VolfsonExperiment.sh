#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=8GB 
#SBATCH --array=0-20
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load arch/haswell
module load matlab/2019a

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); r = VolfsonExperiment(100, 5, 5, 40, 10, 30, $SLURM_ARRAY_TASK_ID);r.RunToTime(200); quit()"
