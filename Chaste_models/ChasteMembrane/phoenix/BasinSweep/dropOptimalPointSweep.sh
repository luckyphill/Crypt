# Drop all the remaining sweeps - may as well, there's heaps of computing time left

sbatch genericOptimalPointSweep.sh 1 ../../optimal/MouseColonDesc.txt
sbatch genericOptimalPointSweep.sh 2 ../../optimal/MouseColonAsc.txt
sbatch genericOptimalPointSweep.sh 3 ../../optimal/MouseColonTrans.txt
sbatch genericOptimalPointSweep.sh 4 ../../optimal/MouseColonCaecum.txt

sbatch genericOptimalPointSweep.sh 5 ../../optimal/RatColonDesc.txt
sbatch genericOptimalPointSweep.sh 6 ../../optimal/RatColonAsc.txt
sbatch genericOptimalPointSweep.sh 7 ../../optimal/RatColonTrans.txt
sbatch genericOptimalPointSweep.sh 8 ../../optimal/RatColonCaecum.txt


