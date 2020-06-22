classdef (Abstract) Analysis < matlab.mixin.SetGet
	% This is a class that controls all the details of a
	% particular analysis. It handles the generation and gathering
	% of data using the simpoint class, and collates it into useful
	% information, generally in the form of plots.
	% A given analysis can have one or many simpoints, but should only
	% produce one type of output. Different analyses can use the same data


	% There are two types of analysis, a single parameter that looks at how
	% a single instance of a simulation behaves
	% A parameter sweep, that takes average data from a bunch of simulations
	% and plots them in a grid

	properties (Abstract)

		analysisName
		parameterSet
		slurmTimeNeeded
		simulationDriverName
		simulationInputCount
		simulationRuns

	end

	properties

		saveLocation

		simulationFileLocation

		slurmJobArrayLimit = 10000

	end

	methods (Abstract)

		% Produce a matrix where each row is a parameter set to be tested
		% This could include specific seeds if you like, but different seeds
		% can be handled in the sbatch file
		MakeParameterSet

	end

	methods

		function ProduceSimulationFiles(obj)

			% This will make the parameter set file and the
			% shell script needed for sbatch

			obj.SetSaveDetails();

			command = '';

			if length(obj.parameterSet) <= obj.slurmJobArrayLimit
				% If the parameter set is less than the job array limit, no need to
				% number the param files
				paramFile = [obj.analysisName, '.txt'];
				paramFilePath = [obj,simulationFileLocation, paramFile];
				dlmwrite( paramFilePath, obj.parameterSet, 'precision','%g');

				command = obj.BuildCommand(length(obj.parameterSet), paramFile);

			else
				% If it's at least obj.slurmJobArrayLimit + 1, then split it over
				% several files
				nFiles = ceil( length(obj.parameterSet) / obj.slurmJobArrayLimit );
				for i = 1:nFiles-1
					paramFile = [obj.analysisName, '_', num2str(i), '.txt'];
					paramFilePath = [obj.simulationFileLocation, paramFile];
					
					iRange = (  (i-1) * obj.slurmJobArrayLimit + 1 ):( i * obj.slurmJobArrayLimit );
					dlmwrite( paramFilePath, obj.parameterSet(iRange, :), 'precision','%g');
					
					command = [command, obj.BuildCommand(obj.slurmJobArrayLimit, paramFile), '\n'];

				end
				% The last chunk
				paramFile = [obj.analysisName, '_', num2str(nFiles), '.txt'];
				paramFilePath = [obj.simulationFileLocation, paramFile];
				
				iRange = (  (nFiles-1) * obj.slurmJobArrayLimit + 1 ):length(obj.parameterSet);
				dlmwrite( paramFilePath, obj.parameterSet(iRange, :),'precision','%g');

				command = [command, obj.BuildCommand(length(obj.parameterSet) - i *obj.slurmJobArrayLimit, paramFile)];
			end

			% Now to make the shell file for sbatch  (...maybe do this later)
			fid = fopen([obj.simulationFileLocation, 'launcher.sh'],'w');
			fprintf(fid, command);
			fclose(fid);

		end

		function command = BuildCommand(obj,len,paramFile)

			% Build up the command to launch the sbatch

			command = 'sbatch ';
			command = [command, sprintf('--array=0-%d ',len)];
			command = [command, sprintf('--time=%d:00:00 ',obj.slurmTimeNeeded)];
			command = [command, sprintf('../generalSbatch%d.sh ',obj.simulationInputCount)];
			command = [command, sprintf('%s ', obj.simulationDriverName)];
			command = [command, sprintf('%s ', paramFile)];
			command = [command, sprintf('%d', obj.simulationRuns)];

		end

		function SetSaveDetails(obj)

			researchPath = getenv('HOME');
			if isempty(researchPath)
				error('HOME environment variable not set');
			end
			if ~strcmp(researchPath(end),'/')
				researchPath(end+1) = '/';
			end

			obj.simulationFileLocation = [researchPath, 'Research/Crypt/Matlab_models/RectangularCell/phoenix/', obj.analysisName, '/'];

			obj.saveLocation = [researchPath, 'Research/Crypt/Images/Matlab/', obj.analysisName, '/'];


			if exist(obj.saveLocation,'dir')~=7
				mkdir(obj.saveLocation);
			end

			if exist(obj.simulationFileLocation,'dir')~=7
				mkdir(obj.simulationFileLocation);
			end

		end

		function SavePlot(obj, h, name)
			% Necessary to save figures
			obj.SetSaveDetails();
			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print([obj.saveLocation,name],'-dpdf')

		end

		function A = Concatenate(obj, A, b)

			% Adds row vector b to the bottom of matrix A
			% If padding is needed, nans are added to the right
			% side of the matrix or vector as appropriate


			if length(b) < length(A)
				% pad vector
				d = length(A) - length(b);
				b = [b, nan(1,d)];
			end
			
			if length(b) > length(A)
				% pad matrix
				d = length(b) - length(A);
				[m,n] = size(A);
				A = [A,nan(m,d)];
			end

			A = [A;b];

		end

	end

end