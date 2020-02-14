classdef basinAnalysisGrid < matlab.mixin.SetGet

	% Change into a function that handles the new stepping from optimal params
	% Used to then create a plot of the objective function space

	properties
		crypt
		cryptName
		objectiveFunction
		A

		% Assuming the order is nM,npM,eesM,msM,cctM,wtM,vfM
		X % The index of the parameter on the x axis
		Y % ditto

		griD % Unfortunately grid is a keyword...

		imageLocation
		imageFile

		axisNameX
		axisNameY


	end

	methods

		function obj = basinAnalysisGrid(crypt, A)
			% A is a cell array that contains the mutation fraction values to be examined
			% It is a cell array so the two axes can have their full range provided

			% The function will detect which parameters are the axis parameters and
			% produce a plot with the appropriate labels

			
			

			obj.crypt = crypt;
			obj.cryptName = getCryptName(crypt);
			obj.objectiveFunction = str2func(obj.cryptName);

			if length(A)~=7
				error('Must have 7 element in the A cell array')
			end

			obj.A = A;

			% Need to find the two parameters that are varied

			firstParameter = nan;
			secndParameter = nan;

			for i = 1:length(A)
				if length(A{i}) > 1 && isnan(firstParameter)
					firstParameter = i;
				else
					if length(A{i}) > 1
						secndParameter = i;
						break;
					end
				end
			end

			obj.Y = firstParameter;
			obj.X = secndParameter;

			obj.axisNameX = obj.getParamName(obj.X);
			obj.axisNameY = obj.getParamName(obj.Y);

			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/basinAnalysisGrid/', obj.cryptName, '/', obj.axisNameX, '-', obj.axisNameY, '/'];
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			if obj.X~=1 && obj.Y~=1
				obj.imageFile = sprintf('%snM%.1f',obj.imageLocation,A{1});
			end
			if obj.X~=2 && obj.Y~=2
				obj.imageFile = sprintf('%snpM%.1f',obj.imageFile,A{2});
			end
			if obj.X~=3 && obj.Y~=3
				obj.imageFile = sprintf('%seesM%.1f',obj.imageFile,A{3});
			end
			if obj.X~=4 && obj.Y~=4
				obj.imageFile = sprintf('%smsM%.1f',obj.imageFile,A{4});
			end
			if obj.X~=5 && obj.Y~=5
				obj.imageFile = sprintf('%scctM%.1f',obj.imageFile,A{5});
			end
			if obj.X~=6 && obj.Y~=6
				obj.imageFile = sprintf('%swtM%.1f',obj.imageFile,A{6});
			end
			if obj.X~=7 && obj.Y~=7
				obj.imageFile = sprintf('%svfM%.1f',obj.imageFile,A{7});
			end

			obj.imageFile = strrep(obj.imageFile, '.', '_');


			obj.makeGrid();

		end

		function makeGrid(obj)
			% Uses the cell array A to make the grid
			% Each element of A is either a single number, or (only two elements) is a vector
			% As such, this will only create a 2D array
			% 
			data = [];
			A = obj.A;
			
			for a = A{1}
				for b = A{2}
					for c = A{3}
						for d = A{4}
							for e = A{5}
								for f = A{6}
									for g = A{7}

										try
											b = basinObjective(obj.objectiveFunction, obj.crypt, a, b, c, d, e, f, g, 'varargin');
											data(end + 1) = b.penalty;
										catch
											data(end + 1) = nan;
										end

									end
								end
							end
						end
					end
				end
			end

			obj.griD = reshape(data, [length(A{obj.Y}), length(A{obj.X})]);


		end

		function savePlot(obj)
			h = obj.makePlot();


			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print(obj.imageFile,'-dpdf')

			close(h);

		end

		function showPlot(obj)
			h = obj.makePlot();
			set(h,'Visible', 'on');

		end

		function h = makePlot(obj)
			% Takes a 5x5 slice of parameter space and plots it with the correct
			% axes and stuff

			A = obj.A;

			tickLabelX = num2cell(A{obj.X});
			tickLabelY = num2cell(A{obj.Y});

			numX = length(tickLabelX);
			numY = length(tickLabelY);

			
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			imagesc(obj.griD,'AlphaData',~isnan(obj.griD), [0,10])
			colormap parula
			set(gca, 'XTick', 1:numX)
			set(gca, 'XTickLabel', tickLabelX)
			set(gca, 'YTick', 1:numY)
			set(gca, 'YTickLabel', tickLabelY)
			xlabel(obj.axisNameX,'Interpreter','latex','FontSize',20);
			ylabel(obj.axisNameY,'Interpreter','latex','FontSize',20);
			title('Perturbation objective function value','Interpreter','latex','FontSize',20);
			colorbar;
		end

		function name = getParamName(obj, I)

			switch I				
				case 1
					name = 'Height';
				case 2
					name = 'Compartment';
				case 3
					name = 'Stiffness';
				case 4
					name = 'Adhesion';
				case 5
					name = 'Cycle';
				case 6
					name = 'Growth';
				case 7
					name = 'Inhibition';
				otherwise
					error('Parameter type not found');
			end
		end

	end

end