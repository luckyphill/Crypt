# Drop all the remaining sweeps - may as well, there's heaps of computing time left

sbatch genericOptimalPointSweep.sh 1 MouseColonDesc.txt
sbatch genericOptimalPointSweep.sh 2 MouseColonAsc.txt
sbatch genericOptimalPointSweep.sh 3 MouseColonTrans.txt
sbatch genericOptimalPointSweep.sh 4 MouseColonCaecum.txt

sbatch genericOptimalPointSweep.sh 5 RatColonDesc.txt
sbatch genericOptimalPointSweep.sh 6 RatColonAsc.txt
sbatch genericOptimalPointSweep.sh 7 RatColonTrans.txt
sbatch genericOptimalPointSweep.sh 8 RatColonCaecum.txt


