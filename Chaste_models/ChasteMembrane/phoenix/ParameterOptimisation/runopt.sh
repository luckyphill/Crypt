#!/bin/bash
script=$1

module load matlab/2016b

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

matlab -nodisplay -nodesktop -r "${script}; quit()"