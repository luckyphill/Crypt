#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=1GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load arch/haswell
module load matlab/2019a

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); t = TumourSpheroid(10,10,20,10);t.RunToTime(300); quit()"
