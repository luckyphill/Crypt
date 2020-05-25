classdef analysis < Abstract
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

	properties
		
		% SAVE THIS FILE UNTIL ABSTRACTION IS NEEDED

		chastePath
		


	end

	methods

		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.outputTypes{1}.getFullFilePath(obj.simul)], '-echo');

		end

	end

	methods (Abstract)
		% 
		function generateData()
			% A method to make the simpoints run their respective simulations 

		end

		function loadData()
			% A method to collect existing data and put it into the analysis
			% If the data doesn't exist, it ignores it

		end

		function processData()
			% A method that uses the loaded data and puts it in a form to be plotted/observed
		end

		function generatePlot()
			% Takes the processed data, plots it and saves the plot

		end

	end


end