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

		% A cell array of classes that handle the reading and writing of data
		outputTypes
		numOutputTypes = 0;

		% A list of outputtypes that have not been generated yet
		outputTypesToRun = {};

		data = nan;

	end

	methods (Abstract)
		% These methods must be implemented in subclasses

		% A method that does the actual running
		% It also uses the save data function, so by the end of
		% the function run time, there will be a data or error file
		runSimulation

	end

	methods

		function set.outputTypes( obj, v )
			% This is to validate the object given to outputType in the constructor
			if isa(v, 'dataType')
            	validateattributes(v, {'dataType'}, {});
            	obj.outputTypes = {v};
            	numOutputTypes = 1;
            end

            if isa(v, 'cell')
            	numOutputTypes = length(v);
            	for i = 1:numOutputTypes
            		validateattributes(v{i}, {'dataType'}, {});
            	end
            	obj.outputTypes = v;
            end

            if ~isa(v, 'cell') && ~isa(v, 'dataType')
            	% Invalid input
            	error('sim:dataType', 'outputTypes must either be a class of type dataType, or a cell array of dataType classes');
            end
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

			if numOutputTypes == 0
				error('sim:NoOutputTypes', 'At least one outputType must be specified before running the simulation');
			end

			if ~obj.overWrite
				% We are going to take whatever data exists and if it doesn't exist
				% we will generate it
				for i = 1:numOutputTypes
					if ~obj.outputTypes{i}.exists(obj)
						obj.outputTypesToRun = {obj.outputTypes{i}  ,obj.outputTypesToRun};
					end
				end

				if isempty(obj.outputTypesToRun)
					% All data exists already, no need to run simulation
					fprintf('Data already exists\n');
					successCode = 2;
				else
					% We need to run the simulation to generate the data that is missing
					if obj.runSimulation();
						successCode = 1;
						for i=1:length(obj.outputTypesToRun)
							if obj.outputTypesToRun{i}.exists(obj)
								fprintf('Data generation successful for %\n', obj.outputTypesToRun{i}.name);
							else
								fprintf('Data generation failed for %\n', obj.outputTypesToRun{i}.name);
								successCode = 0;
							end
						end
					end
				end
			else
				obj.outputTypesToRun = obj.outputTypes;
				if obj.runSimulation();
					successCode = 1;
					for i=1:length(obj.outputTypesToRun)
						if obj.outputTypesToRun{i}.exists(obj)
							fprintf('Data generation successful for %\n', obj.outputTypesToRun{i}.name);
						else
							fprintf('Data generation failed for %\n', obj.outputTypesToRun{i}.name);
							successCode = 0;
						end
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






