classdef simpoint
	% A class defining a simulation point for a given Chaste test
	% It will be the primary way of controlling the data from a simulation
	% In the class will be held:
	% - Input paramters
	% - The simulation command
	% - Output file writer, specific to the type of data required
	% - Output file location
	% - A method controlling the simulation running and data checking
	% Essentially the purpose of this class is to put the data in a standard location
	% and make sure that simulations only run when the data does not exist
	% OR the data is specifically requested to be regenerated

	properties (Constant = true)
		% A list of input parameter names (unique to the Chaste test)
		% A list of the corresponding parameter values
		% These are broken up into crypt parameters and simulation parameters
		% For example:  n, np, ees, ms, cct, wt, vf are crypt parameters
		% while: 		t, bt, dt, sm 				are numerical conditions
		% There is also the seed parameter 'run_number' which identifies the
		% specific starting conditions

		% These are set when the simpoint is initialised and won't change
		simParams
		simValues

		solverParams
		solverValues

		seedParams
		seedValues

		chasteTest

		outputType dataType
		overWrite = false;
	end

	properties (SetAccess = immutable)
		% These properties are determined from the input values, and are set 
		% in the constructor only (hence immutable)
		% The input values never change for a given simpoint, so these will never change

		simOutputLocation % Where Chaste stores its own output
		dataSaveLocation % Where the data for the given analysis will be stored

		dataFile
		errorFile

		fileName = 'test'

		simulationCommand

		inputString



	end

	properties 
		% These properties are determined from simulations and can be modified
		% within the class at any time

		% The concole output from the simulation
		cmdout

		% The loaded simulation data in the format defined in 'outputType'
		data
	end

	methods
		function sp = simpoint(cryptParams, cryptValues, simParams, simValues, chasteTest, typeOfData)
			% Initialise the simpoint and generate all the fixed file names

			sp.outputType = typeOfData;


			sp.simOutputLocation = '/tmp/phillip/'; % Where Chaste stores its own output
			sp.dataSaveLocation = 'Research/Crypt/Data/'; % Where the data for the given analysis will be stored

			sp.dataFile = [sp.dataSaveLocation, sp.fileName, '.txt'];
			sp.errorFile = [sp.dataSaveLocation, sp.fileName, '.err'];

			sp.simulationCommand = 'tmp';

			sp.inputString = 'tmp';



		end


		function [data, successCode] = generateSimulationData(sp)
			% Runs the simulation, and makes sure all the data is in the correct place
			% First it checks for existing data
			% successCode is a flag to say what happened:
			% 0 - something went wrong
			% 1 - simulation ran, data processed and saved
			% 2 - existing data loaded

			data = [];
			successCode = 0;

			if ~sp.overWrite
				% We are going to take whatever data exists and if it doesn't exist
				% we will generate it
				try
					data = sp.outputType.loadData(sp);
				catch err
					if strcmp(err.message, 'File does not exist')
						fprintf('File does not exist, generating data\n')
					end
					if strcmp(err.message, 'Data was not found in the expected format')
						fprintf('There was a problem reading the data. Attmepting to regenerate\n')
					end

					sp.runSimulation();

				end

			else
				sp.runSimulation();


			end





			if exist(sp.dataFile, 'file') == 2 && ~sp.overWrite
				fprintf('Found existing data\n');
				try
					data = loadSimulationData(sp);
				catch
					fprintf('Problem retrieving data, attempting to regenerate\n');
					runSimulation(sp);
				end
			else
				runSimulation(sp);
				try
					data = loadSimulationData(sp);
				catch
					fprintf('Simulation')
				end
			end

		end

		function successCode = runSimulation(sp)
			% Runs the simulation command
			% This will never throw an error

			% The 'system' command will always work in Matlab. It doesn't care what you type
			% it just reports back what the console said
			[status, sp.cmdout] = system([sp.simulationCommand, sp.inputString],'-echo');

			if status
				% The simulation ended in an unexpected way, save console output to the error file
				fid = fopen(sp.errorFile,'w');
				fprintf(fid, cmdout);
				fclose(fid);
				fprintf('Problem running simulation. Console output saved in:\n%s', errorFile);
			else
				% If status returns 0, then the command completed without failing
				% However, this does not mean the data will necessarily be in the correct
				% format. Error checking needs to happen in the data processing
				% Data should be able to be processed correctly
				sp.outputType.processOutput(sp);
			end

		end

		function data = loadSimulationData(sp)
			% Uses the loader to get the data from the file when it knows a file exists
			% There might be a situation when the file exists, but it wasn't written correctly
			% In this case, loader should throw an error, which will be handled here

			data = [];
			try
				data = sp.dataType.loadData(sp);
			catch
				fprintf('Error loading data from %s', sp.dataFile);
			end

		end

		function generateFileName(sp)

			% This function takes in the flags and values for this particular simulation,
			% and produces the file name. There are numerous variables that can be provided
			% and they all ought to be represented in the file name if they are specified
			% At the same time we want to keep them all in a regular order. This function
			% won't do that. If a special order is needed, that should be controlled 
			% when building the structure p

			n = length(p.input_flags);
			m = length(p.input_values);

			r = length(p.static_flags);
			q = length(p.static_params);

			assert(n==m);
			assert(r==q);

			file_dir = [p.base_path, 'Research/Crypt/Data/Chaste/', p.process, '/', p.chaste_test, '/', func2str(p.obj), '/'];
			if exist(file_dir,'dir')~=7
				% Make the full path
				if exist([p.base_path, 'Research/Crypt/Data/Chaste/', p.process, '/', p.chaste_test, '/'],'dir')~=7
					mkdir([p.base_path, 'Research/Crypt/Data/Chaste/', p.process, '/', p.chaste_test, '/']);
				end

				mkdir(file_dir);

			end

			file_name = p.output_file_prefix;
			% if ~strcmp(file_name(end), '_')
			% 	file_name(end+1) = '_';
			% end

			for i = 1:q
				file_name = [file_name, sprintf('_%s_%g',p.static_flags{i}, p.static_params(i))];
			end

			for i = 1:n
				file_name = [file_name, sprintf('_%s_%g',p.input_flags{i}, p.input_values(i))];
			end

			file_name = [file_name, sprintf('_%s_%g',p.run_flag, p.run_number)];

			file_name = [file_name, '.txt'];

			data_file = [file_dir, file_name];

		end

	end
end






