classdef AbstractDataWriter < handle & matlab.mixin.Heterogeneous
	% This class sets out the required functions for writing
	% data to file

	% This will usually be used for something like storing the spatial
	% positions of the nodes etc for later visualisation. In other words
	% it is designed for use when each time step will produce a lot of
	% data, rather than just a handful of values

	properties
		% A structure that holds the data for a single
		% time step. This will be a cell array for each type of
		% data held by the concrete class. It can take matrices
		% or cell arrays. Each row of the matrix or cell array should
		% contain all the data about a single unit that is being stored
		% for example, if storing nodes, each row should be data for a
		% single node
		data

		% The corresponding time point
		timePoint

		% How many steps between each data point
		samplingMultiple

		% A flag to determine if each time step will be written to a
		% separate file, or all will be written in a single file
		multipleFiles = true

		% If writing multiple files, each file needs a unique number
		% so we need to keep track of where we're up to
		fileNumber = 0

		% A path pointing to where the data will be stored
		rootStorageLocation = [getenv('HOME'),'/Research/Crypt/Data/Matlab/SimulationOutput/'];

		% A flag to tell the function that the full path has been made
		% i.e. using mkdir
		fullPathMade = false

		% The full path to the folder where the data will be written
		fullPath

	end

	properties (Abstract)

		% A name for the file(s) to be written. This will be given in
		% a cell array, and the file names will match with the data
		% in the matching data cell array
		fileNames

		% The sub directory structure under the roor storage location
		% Should be at minimum be 'simname/' and can also go deeper
		% with parameter sets etc. 
		subdirectoryStructure
	end

	methods (Abstract)

		GatherData(obj, t);
		
	end

	methods

		function WriteData(obj, t)

			if mod(t.step, obj.samplingMultiple) == 0

				if ~obj.fullPathMade
					obj.MakeFullPath();
					obj.fullPathMade = true;
				end

				obj.GatherData(t);

				obj.timePoint = t.t;

				if obj.multipleFiles
					obj.WriteToMultipleFiles();
					obj.fileNumber = obj.fileNumber + 1;
				else
					% Not yet complete
					obj.WriteToSingleFile();
				end

			end

		end

		function WriteToMultipleFiles(obj)

			% At each time step, write a new file

			for i = 1:length(obj.data)
				
				outputFile = sprintf('%s%s_%08d.csv', obj.fullPath, obj.fileNames{i}, obj.fileNumber);

				switch class(obj.data{i})
					case 'double'
						writematrix(obj.data{i}, outputFile);
					case 'cell'
						writecell(obj.data{i}, outputFile);
					otherwise
						error('ADW:WriteToMultipleFiles:CantWrite', 'Cant write class %s to file', class(obj.data{i}));
				end
				
			end

		end

		function WriteToSingleFile(obj)

			% Writes the data to a single file
			for i = 1:length(obj.data)
				
				outputFile = sprintf('%s%s.csv', obj.fullPath, obj.fileNames{i});

				switch class(obj.data{i})
					case 'double'
						% Need to flatten the matrix into a single row, and provide separate
						% delimiters between each row, then append to the existing file
						n = obj.data{i};
						n = n';
						n = [obj.timePoint,n(:)'];
						writematrix(n, outputFile,'WriteMode','append');
					case 'cell'
						% Need to flatten the cell into a single row, and provide separate
						% delimiters between each row - Not Done
						writecell(obj.data{i}, outputFile,'WriteMode','append');
					otherwise
						error('ADW:WriteToSingleFile:CantWrite', 'Cant write class %s to file', class(obj.data{i}));
				end
				
			end

		end


		function MakeFullPath(obj)

			% Only runs once. First checks if the directory exists,
			% and if not makes it.

			obj.fullPath = [obj.rootStorageLocation, obj.subdirectoryStructure];

			if exist(obj.fullPath,'dir')~=7
				mkdir(obj.fullPath);
			end

			% If there's anything in there, delete it
			[~,~] = system(['rm ', obj.fullPath, '*']);

		end

	end

end