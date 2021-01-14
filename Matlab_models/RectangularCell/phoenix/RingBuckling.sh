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
module load matlab
export EDGEDIR='/hpcfs/users/a1738927/Research/Crypt/Matlab_models/RectangularCell'

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); t = RingBuckling(20,10,10,1);t.RunToTime(200); quit()"
