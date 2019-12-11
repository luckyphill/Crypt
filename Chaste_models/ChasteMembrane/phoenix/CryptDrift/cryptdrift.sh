#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=12:00:00 
#SBATCH --mem=1GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

mkdir -p output
export CHASTE_TEST_OUTPUT=/fast/users/a1738927/testoutput/

Mn=$1
Mnp=$2
eesM=$3
msM=$4
cctM=$5
wtM=$6
Mvf=$7
seed=$8

echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptColumnFullMutation -crypt 1 -t 1000 -Mn ${Mn} -Mnp ${Mnp} -eesM ${eesM} -msM ${msM} -Mvf ${Mvf} -cctM ${cctM} -wtM ${wtM} -run $seed -sm 1000 -Pul";
/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptColumnFullMutation -crypt 1 -t 1000 -Mn ${Mn} -Mnp ${Mnp} -eesM ${eesM} -msM ${msM} -cctM ${cctM} -Mvf ${Mvf} -wtM ${wtM} -run $seed -sm 1000 -Pul
