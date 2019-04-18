#!/bin/bash
script=$1

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5
module load matlab/2016b
matlab -nodisplay -nodesktop -r "${script}; quit()"