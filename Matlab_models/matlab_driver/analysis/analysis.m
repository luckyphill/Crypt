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

	end

	properties

		saveLocation
	end


	methods
		function SetSaveDetails(obj)

			researchPath = getenv('HOME');
			if isempty(researchPath)
				error('HOME environment variable not set');
			end
			if ~strcmp(researchPath(end),'/')
				researchPath(end+1) = '/';
			end

			obj.saveLocation = [researchPath, 'Research/Crypt/Images/Matlab/', obj.analysisName, '/'];


			if exist(obj.saveLocation,'dir')~=7
				mkdir(obj.saveLocation);
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


	end


end