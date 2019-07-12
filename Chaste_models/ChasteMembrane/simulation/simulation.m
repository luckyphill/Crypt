classdef (Abstract) simulation < matlab.mixin.SetGet
	% A class defining the generic things a simulation needs
	% It will be handed an object of type simulation
	% The simulation runner doesn't care what happens to get the data,
	% it just activates the functions that generate it or retreive it
	% To that end, it doesn't care about variables, generating file names etc,
	% it just uses what the simulation has defined

	% To summarise, this just pulls the trigger on retrieval or generation

	properties
		% A flag to tell the data generating method if existing data is to be overwritten
		overWrite = false;

		% A class that handles the reading and writing of data
		outputType

		data = nan

	end

	methods (Abstract)
		% These methods must be implemented in subclasses

		% A method that does the actual running
		% It also uses the save data function, so by the end of
		% the function run time, there will be a data or error file
		runSimulation

	end

	methods

		function set.outputType( obj, v )
			% This is to validate the object given to outputType in the constructor
            validateattributes(v, {'dataType'}, {});
            obj.outputType = v;
        end

		% These methods are available externally and are how the data gathering is handled

		function successCode = generateSimulationData(obj)
			% First it checks for existing data
			% Then runs the simulation, and makes sure all the data is in the correct place
			% successCode is a flag to say what happened:
			% 0 - something went wrong
			% 1 - simulation ran, data processed and saved
			% 2 - existing data loaded

			%% TODO: This implicitly assumes the data is contained in a single file.
			%% It could easily be in multiple, and dataType can handle this
			%% To make this more general, implement a way of having multiple files

			successCode = 0;

			if ~obj.overWrite
				% We are going to take whatever data exists and if it doesn't exist
				% we will generate it
				try
					obj.data = obj.outputType.loadData(obj);
					successCode = 2;
				catch err
					fprintf('%s\n',err.message);
					fprintf('Problem retrieving data, attempting to regenerate\n');
					
					% The data couldn't be read in for some reason, so attempt to regenerate
					if obj.runSimulation();
						try
							obj.loadSimulationData();
							fprintf('Data generation successful\n');
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
				if obj.runSimulation();
					try
						obj.data = obj.outputType.loadData(obj);
						fprintf('Data generation successful\n');
						successCode = 1;
					catch err
						fprintf('%s\n',err.message);
						fprintf('Data generation failed\n');
						successCode = 0;
					end
				end

			end

		end

		function loadSimulationData(obj)
			% Uses the loader to get the data from the file when it knows a file exists
			% There might be a situation when the file exists, but it wasn't written correctly
			% In this case, loader should throw an error, which will be handled here

			try
				obj.data = obj.outputType.loadData(obj);
			catch err
				fprintf('%s\n',err.message);
			end

		end

	end

end






