function find_optimal_region(p)
	% This function takes in the name of a Chaste test, and an associated objective function
	% The goal is to explore the parameter space and find a point/region where the objective function
	% is minimised. It also needs to take a list of input parameters and an initial search
	% range for each parameter

	% p is a parameter struct that contains all the information need to run the function
	% in order to use the function, a struct p must be created with the following fields:

	% chaste_test 		- string: The name of the chaste test that is essentially the black box part of the optimisation
	%					It is written and tested in c++. Any issues with the test must be handled outside this script

	% obj 				- function handle: It takes a vector of numbers and returns a single number representing the score
	% 					of the relevant parameter set. The order of the numbers will be determined by the output {chaste_test}
	% 					produces. If there is an issue with the expected values in the input vector not matching
	% 					it should be addressed in the file {chaste_test} or {obj}

	% base_path			- string: the path leading to the Research directory on the particular machine
	%					There is expected to be a structure {base_path}/Research/Crypt/Data/Chaste/ParameterSearch/
	%					for the output files, and the structure {base_path}/chaste_build/projects/ChasteMembrane/test/'
	%					for the chaste_test
	% input_flags 		- cell array of strings: containing the input flag names
	% fixed_parameters 	- string: contains input parameters to {chaste_test} that will not be modified i.e. simulation length
	% prange 			- cell array of arrays: gives the initial coarse grained parameters to test
	% limits 			- cell array of paired numbers: gives the [min, max] values that parameters can take in the coarse grained sweep
	% min_step_size 	- array: contains the minimum step size allowed in pattern_search - necessary since some inputs are integers
	% ignore_existing	- bool: a true/false flag that says if to run simulations even when data exists - important if {chaste_test} is modified
	% repetitions		- int: the number of times to run a simulation in the pattern search for averaging

	% The Chaste test will print all the relevent data to the command line
	% This output will be captured and saved to file
	% The capture function will look for output between the lines "DEBUG: START" and "DEBUG: END"
	% and on each line will put the data (assumed numerical) found after the "=" into a vector
	% This vector will be passed to {obj} for processing
	% The file name will be automatically generated using the parameter names in input_flags
	% and the parameter values used by the particular simulation instance
	% Files will be stored in the directory structure: "/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/{chaste_test}/{obj}"
	% in other words, it treats each objective function like the specification of a different type of crypt  

	% A test to ensure basic functionality
	% test(1);

	% Optimisation in three stages:
	% Stage 1: A super coarse sweep, as determined by prange
	% Stage 2: Pick the best coarse parameter set as a starting point and find the minimum from there
	% Stage 3: With an optimal solution (assuming penalty of 0) branch out in multiple directions to
	%		   find the boundaries of the zero region

	p.input_values = coarse_sweep(p);

	fprintf('\n\nCoarse sweep completed, starting pattern search\n\n\n');

	p.input_values = pattern_search(p);

	fprintf('\n\nPattern search completed, best parameters are %s\n\n\n', generate_input_string(p));

	parameter_space = fine_sweep(p, p.input_values)



end
