classdef chasteSimulation < simulation
	% A class defining the generic things a simulation needs
	% It will be handed an object of type simulation
	% The simulation runner doesn't care what happens to get the data,
	% it just activates the functions that generate it or retreive it
	% To that end, it doesn't care about variables, generating file names etc,
	% it just uses what the simulation has defined


	properties (Abstract, SetAccess = immutable)
		% The name of the actual test function as a string. This will
		% be used to build the simulation command and directory structure
		% This must be set in a subclass

		chasteTest char

	end


	properties (SetAccess = protected)
		% These are a list of maps for the parameters.
		% They are broken up by types that will be typically used
		% They don't have to be used, and it is probably more convenient
		% in most instances just to explicitly write the parameters out
		% as properties in subclasses. They are left here just in case

		% The parameters of the simulation describing the cell behaviour
		simParams containers.Map

		% Parameters describing the behaviour of mutant cells. Leave empty if no mutations
		mutantParams containers.Map

		% Parameters fed into the solver, usually time, burn in time, and time step
		solverParams containers.Map 

		% The seed that defines the starting configuration
		seedParams containers.Map 


		% The absolute path to the error file
		errorFile char

		% The absolute path to the chaste simulation output directory
		simOutputLocation char

		% The folder where the processed output will be saved
		saveLocation char

		% The complete simulation command for the particular simulation
		% This will be passed to the matlab 'system' function
		simulationCommand char

		% Not strictly necessary, but useful for console output to keep track of what is
		% actually running
		inputString char

		% The console output from the 'system' function. This is usually only needed when
		% the command fails, but can sometimes be a place where the data of interest appears
		cmdout

	end

	methods (Abstract, Access = protected)
		% These must be implemented in a concrete subclass

		% Sets the folder where Chaste saves output
		generateSimOutputLocation 

		% Sets the folder where processed data will be saved
		generateSaveLocation

		% The command that runs the simulation
		generateSimulationCommand


	end

	methods

		function successCode = runSimulation(obj)
			% Runs the simulation command
			% This will never throw an error

			% The 'system' command will always work in Matlab. It doesn't care what you type
			% it just reports back what the console said
			obj.errorFile = [obj.saveLocation,'output.err'];
			
			fprintf('Running %s with input parameters:\n', obj.chasteTest);
			fprintf('%s\n', obj.inputString);
			% Delete the previous error file
			[~,~] = system(['rm ', obj.errorFile]);
			[failed, obj.cmdout] = system(obj.simulationCommand,'-echo');
			successCode = 0;
			if failed
				% The simulation ended in an unexpected way, save console output to the error file
				fid = fopen(obj.errorFile,'w');
				fprintf(fid, obj.cmdout);
				fclose(fid);
				fprintf('Problem running simulation. Console output saved in:\n%s', obj.errorFile);
			else
				% If failed returns 0, then the command completed without failing
				% However, this does not mean the data will necessarily be in the correct
				% format. Error checking needs to happen in the data processing
				% Data should be able to be processed correctly
				obj.outputType.saveData(obj);
				successCode = 1;
			end

		end

	end


end