classdef viewStackAnalysis < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties

		crypt
		cryptName
		
		n

		muts
		ranges

		imageFile
		imageLocation

		leg

		times
		allStacks

		simul

	end

	methods

		function obj = viewStackAnalysis(crypt, muts, ranges)
			% This object examines the time-average thickness at a given cell position
			% It breaks the crypt up into compartments determined by the ceiling of the
			% input parameter n. It needs to be smaller than the maximum number of cells
			% in the crypt in order to smooth out the function
			% The time average thickness for each cell location is plotted up to the point
			% where the special sloughing mechanism cuts in

			% muts is a cell array of strings matching 'Mnp','eesM','msM','cctM','wtM','Mvf'
			% ranges is a maxtrix where each row are the parameters corresponding to muts
		
			params = getCryptParams(crypt);
			obj.n = params(1);

			obj.muts = muts;
			obj.ranges = ranges;



			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/StackAnalysis/', obj.cryptName, '/'];
			for i=1:length(obj.muts)
				obj.imageLocation = sprintf('%s%s', obj.imageLocation, obj.getParamName(obj.muts{i}));
			end
			obj.imageLocation = [obj.imageLocation, '/'];

			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.imageFile = obj.imageLocation;

			for i=1:length(obj.muts)
				obj.imageFile = sprintf('%s%s', obj.imageFile, obj.getParamName(obj.muts{i}));
			end

			obj.imageFile = strrep(obj.imageFile, '.', '_');



			obj.leg = {};

			data = [];
			for j = 1:length(ranges(1,:))
				values = [];
				for i = 1:length(muts)
					values(end + 1) = ranges(i,j);
				end

				stack = stackAnalysis(crypt, muts, values);

				data(end + 1, :) = stack.avgStackHeight;

				obj.leg{end+1} = num2str(values);
			end

			obj.allStacks = data;

		end



		
		function h = makePlot(obj)

			h = figure;
			set(h,'Visible', 'off');

			plot(1:length(obj.allStacks), obj.allStacks, 'lineWidth', 4);
			xlabel('Cell Position','Interpreter','latex','FontSize',20);
			ylabel('Thickness','Interpreter','latex','FontSize',18);
			plotTitle = 'Average thickness for mutation to ';
			plotTitle = sprintf( '%s%s ', plotTitle, obj.getParamName(obj.muts{1}));
			if length(obj.muts) > 1
				plotTitle = sprintf( '%s and %s', plotTitle, obj.getParamName(obj.muts{2}));
			end
			title(plotTitle,'Interpreter','latex','FontSize',20);
			legend(obj.leg)
			ylim([0.6 5]);

		end

		function savePlot(obj)

			h = obj.makePlot();

			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

			print(obj.imageFile,'-dpdf');
		
		end

		function showPlot(obj)
			h = obj.makePlot();
			set(h,'Visible', 'on');

		end
		

		function name = getParamName(obj, I)

			switch I
				case 'Mnp'
					name = 'Compartment';
				case 'eesM'
					name = 'Stiffness';
				case 'msM'
					name = 'Adhesion';
				case 'cctM'
					name = 'Cycle';
				case 'wtM'
					name = 'Growth';
				case 'Mvf'
					name = 'Inhibition';
				otherwise
					error('Parameter type not found');
			end
		end

	end

end
