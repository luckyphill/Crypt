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

	properties
		% The various parameters are grouped by:
		% simParams: These define the crypt shape and behaviour
		% solverParams: These define numerical conditions, like run time, time step
		% seedParams: These define the intial conditions of the crypt (in this case, a random number seed)
		% They are stored in maps where key = the flag/variable name, value = numerical value of the variable
		% These are set when the simpoint is initialised and won't change
		simParams containers.Map

		solverParams containers.Map

		seedParams containers.Map

		% The name of the test.
		% This is used when building the simulation command
		chasteTest

		% This is an object that handles reading and writing of output
		outputType
		overWrite = false;
	end

	properties (SetAccess = protected)
		% These properties are determined from the input values, and are set 
		% in the constructor only (hence immutable)
		% The input values never change for a given simpoint, so these will never change

		simOutputLocation % Where Chaste stores its own output
		dataSaveLocation % Where the data for the given analysis will be stored

		dataFile
		errorFile

		fileName

		simulationCommand

		inputString

	end

	properties (SetAccess = protected, GetAccess = public)
		% These properties are determined from simulations and can be modified
		% within the class at any time, but cannot be modified from outside

		% The concole output from the simulation
		cmdout

		% The loaded simulation data in the format defined in 'outputType'
		data
	end




	methods
		function obj = set.outputType( obj, v )
			% This is to validate the object given to outputType in the constructor
            validateattributes(v, {'dataType'}, {});
            obj.outputType = v;
        end
		% These methods are available externally and are how the data gathering is handled

		function sp = simpoint(p)
			% Initialise the simpoint and generate all the fixed file names
			% p is an input structure, containing all the details needed for a simulation
			% they are then dispersed appropriately

			sp.simParams = p.simParams;

			sp.solverParams = p.solverParams;

			sp.seedParams = p.seedParams;


			sp.outputType = p.outputType;


			sp.chasteTest = p.chasteTest;


			if isfield(p, 'overWrite')
				sp.overWrite = p.overWrite;
			end



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

			%% TODO: This implicitly assumes the data is contained in a single file.
			%% It could easily be in multiple, and dataType can handle this
			%% To make this more general, implement a way of having multiple files
			data = nan;
			successCode = 0;

			if ~sp.overWrite
				% We are going to take whatever data exists and if it doesn't exist
				% we will generate it
				try
					data = sp.outputType.loadData(sp);
					successCode = 2;
				catch err
					fprintf('%s\n',err.message);
					fprintf('Problem retrieving data, attempting to regenerate\n');
					
					% The data couldn't be read in for some reason, so attempt to regenerate
					if sp.runSimulation();
						try
							data = sp.outputType.loadData(sp);
							successCode = 1;
						catch err
							fprintf('%s\n',err.message);
							fprintf('Regeneration failed\n');
							successCode = 0;
						end
					end
				end

			else
				% We are going to run the simulation and make new data, regardless
				% of what already exists
				if sp.runSimulation();
					try
						data = sp.outputType.loadData(sp);
						successCode = 1;
					catch err
						fprintf('%s\n',err.message);
						fprintf('Data generation failed\n');
						successCode = 0;
					end
				end

			end

		end

		function status = runSimulation(sp)
			% Runs the simulation command
			% This will never throw an error

			% The 'system' command will always work in Matlab. It doesn't care what you type
			% it just reports back what the console said

			% Delete the previous error file
			[~,~] = system(['rm ', sp.errorFile]);
			[status, sp.cmdout] = system([sp.simulationCommand, sp.inputString],'-echo');

			if status
				% The simulation ended in an unexpected way, save console output to the error file
				fid = fopen(sp.errorFile,'w');
				fprintf(fid, cmdout);
				fclose(fid);
				fprintf('Problem running simulation. Console output saved in:\n%s', sp.errorFile);
			else
				% If status returns 0, then the command completed without failing
				% However, this does not mean the data will necessarily be in the correct
				% format. Error checking needs to happen in the data processing
				% Data should be able to be processed correctly
				sp.outputType.saveOutput(sp);
			end

		end

		function data = loadSimulationData(sp)
			% Uses the loader to get the data from the file when it knows a file exists
			% There might be a situation when the file exists, but it wasn't written correctly
			% In this case, loader should throw an error, which will be handled here

			data = nan;
			try
				data = sp.dataType.loadData(sp);
			catch err
				fprintf('%s\n',err.message);
			end

		end

	end

	methods (Access = protected)
		% These methods are purely for managing the class 

		function generateSimOutputLocation(sp)
			% This generates the simulation output path for the given parameters
			% in the given Chaste test. This will depend on how the
			% Chaste function 'simulator.SetOutputDirectory()' is implemented, so this method
			% will be test-specific. The default values of some parameters will need to be know here

			path_start = '/tmp/phillip/testoutput/';

			path_normal = sprintf('n_%d_np_%d_EES_%g_MS_%g_CCT_%g_WT_%g_VF_%g_run_%d/', n, np, ees, ms, cct, wt, vf, run_number);

			path_mpos = sprintf('mpos_%d_', mpos);

			output_path = [path_start, p.chaste_test, '/', path_normal, path_mpos];

			if use_resist
				path_resist = sprintf('rdiv_%d_rple_%g_rcct_%g_', rdiv, rple, rcct);
				output_path  = [output_path, path_resist];
			end

			path_mutant = sprintf('Mnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/', Mnp, eesM, msM, cctM, wtM, Mvf);

			path_results = sprintf('results_from_time_%d/',bt);

			output_path =  [output_path, path_mutant, path_results];

		end


		function generateDataSaveLocation(sp)



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

		function generateSimulationCommand(sp)


		end

		

		function generateInputString(sp)

			input_string = [];

			for i = 1:q
				input_string = [input_string, sprintf(' -%s %g',p.static_flags{i}, p.static_params(i))];
			end

			for i = 1:n
				input_string = [input_string, sprintf(' -%s %g',p.input_flags{i}, p.input_values(i))];
			end

			input_string = [input_string, sprintf(' -%s %g',p.run_flag, p.run_number)];
		end

	end
end






