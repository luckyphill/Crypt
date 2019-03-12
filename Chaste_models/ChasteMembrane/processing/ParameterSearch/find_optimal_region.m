function find_optimal_region(chaste_test, obj, p)

	% This function takes in the name of a Chaste test and a run it with 
	% different parameter sets until it reaches a set where the objective
	% function 'obj' gives a penalty of 0
	% It then searches around that point to explore the region and determine
	% the size and shape of the good region

	% p is a structure with the expected parameters

	% A chaste test must output the following variables:
	% Total number of cells through whole simulation
	% Cells died from anoikis
	% Cells died from sloughing
	% Final cell count
	% Final proliferative zone count
	


	simulation_command = ['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/', chaste_test];

	[status,cmdout] = system([ -cct ' num2str(cct) ' -ees ' num2str(vars(1)) ' -ms ' num2str(vars(2)) ' -vf ' num2str(vars(3))])';







end


function parameters = optimiser(simulation_command, obj, p)



end
