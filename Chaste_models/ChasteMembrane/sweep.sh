#!/bin/bash
#
# Script to run Wnt Wall simultations in series


for E_S in 5 10 20 30
do
	for EM_S in 5 10 20 30
	do
	echo "Parameter sweep with Epithelial Stiffness " ${E_S} " and Epithleial-Membrane Stiffness " ${EM_S};
	# NB "nice -20" gives the jobs low priority (good if they are going to dominate the server and no slower if nothing else is going on)
	# ">" directs std::cout to the file.
	# "2>&1" directs std::cerr to the same place.
	# "&" on the end lets the script carry on and not wait until this has finished.
	/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestGrowingCellDivision -e ${E_S} -em ${EM_S} -g1L 8 -g1S 2
	python cell_birth.py /Users/phillipbrown/Chaste/testoutput/TestGrowingCellDivisionParameterSweep/E_${E_S}_EM_${EM_S}_G1L_8_G1S_2/results_from_time_0
	python cell_death.py /Users/phillipbrown/Chaste/testoutput/TestGrowingCellDivisionParameterSweep/E_${E_S}_EM_${EM_S}_G1L_8_G1S_2/results_from_time_0
	python cell_speed2.py /Users/phillipbrown/Chaste/testoutput/TestGrowingCellDivisionParameterSweep/E_${E_S}_EM_${EM_S}_G1L_8_G1S_2/results_from_time_0
	python cell_labelling_index.py /Users/phillipbrown/Chaste/testoutput/TestGrowingCellDivisionParameterSweep/E_${E_S}_EM_${EM_S}_G1L_8_G1S_2/results_from_time_0

	done
done

echo "Done"