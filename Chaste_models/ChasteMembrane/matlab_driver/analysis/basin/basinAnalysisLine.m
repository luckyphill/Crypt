classdef basinAnalysisLine < matlab.mixin.SetGet

	% Change into a function that handles the new stepping from optimal params
	% Used to then create a plot of the objective function space

	properties
		crypt
		cryptName
		objectiveFunction
		healthyParams
		mutation
		values

		linE % Unfortunately line is a keyword...
		anoikisLine
		birthLine
		countLine
		divisionLine

		imageLocation
		imageFile

	end

	methods

		function obj = basinAnalysisLine(crypt, mutation, values)
			% Mutation is a string with the usual mutation flag,
			% Values is an array of mutation factors to be plotted
			% Only one mutation is considered in this analysis


			obj.crypt = crypt;
			obj.cryptName = getCryptName(crypt);
			obj.objectiveFunction = str2func(obj.cryptName);
			obj.healthyParams = getNewCryptParams(crypt, 1);

			obj.mutation = mutation;
			obj.values = values;


			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/basinAnalysisLine/', obj.cryptName, '/'];
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.imageFile = sprintf('%s%s',obj.imageLocation,obj.getParamName(mutation));
			

			obj.imageFile = strrep(obj.imageFile, '.', '_');


			obj.makeLine();

		end

		function makeLine(obj)
			% Gets all the data for the short sweep
			% 
			data = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = obj.getParamNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.objectiveFunction, obj.crypt, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					data(end + 1) = b.penalty;
				catch
					data(end + 1) = nan;
				end
			end

			obj.linE = data;



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
			% Plot the line

		
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			plot(obj.values, obj.linE, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Objective value','Interpreter','latex','FontSize',20);
			title(['Objective function for mutation to ', obj.getParamName(obj.mutation)],'Interpreter','latex','FontSize',20);

		end

		function name = getParamName(obj, I)

			switch I
				case 'nM'
					name = 'Height';
				case 'npM'
					name = 'Compartment';
				case 'eesM'
					name = 'Stiffness';
				case 'msM'
					name = 'Adhesion';
				case 'cctM'
					name = 'Cycle';
				case 'wtM'
					name = 'Growth';
				case 'vfM'
					name = 'Inhibition';
				otherwise
					error('Parameter type not found');
			end
		end

		function number = getParamNumber(obj, I)

			switch I
				case 'nM'
					number = 1;
				case 'npM'
					number = 2;
				case 'eesM'
					number = 3;
				case 'msM'
					number = 4;
				case 'cctM'
					number = 5;
				case 'wtM'
					number = 6;
				case 'vfM'
					number = 7;
				otherwise
					error('Parameter type not found');
			end
		end



		% THis is a quick copy-paste-replace way of making plots for different parts of the objective function
		function makeAnoikisLine(obj)
			% Makes a line of how anoikis varies with mutation factor
			data = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = obj.getParamNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.objectiveFunction, obj.crypt, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					data(end + 1) = b.simul.data.behaviour_data(1);
				catch
					data(end + 1) = nan;
				end
			end

			obj.anoikisLine = data;

		end

		function h = makeAnoikisPlot(obj)
			% Plot the line

			obj.makeAnoikisLine();
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			plot(obj.values, obj.anoikisLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Anoikis rate','Interpreter','latex','FontSize',20);
			title(['Measured anoikis rate for mutation to ', obj.getParamName(obj.mutation)],'Interpreter','latex','FontSize',20);

		end
		function saveAnoikisPlot(obj)
			h = obj.makeAnoikisPlot();


			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print([obj.imageFile, '-Anoikis'],'-dpdf')

			close(h);

		end


		

		function makeBirthLine(obj)
			% Makes a line of how Birth varies with mutation factor
			data = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = obj.getParamNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.objectiveFunction, obj.crypt, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					data(end + 1) = b.simul.data.behaviour_data(3);
				catch
					data(end + 1) = nan;
				end
			end

			obj.birthLine = data;

		end

		function h = makeBirthPlot(obj)
			% Plot the line

			obj.makeBirthLine();
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			plot(obj.values, obj.birthLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Turnover rate','Interpreter','latex','FontSize',20);
			title(['Measured turnover rate for mutation to ', obj.getParamName(obj.mutation)],'Interpreter','latex','FontSize',20);

		end
		function saveBirthPlot(obj)
			h = obj.makeBirthPlot();


			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print([obj.imageFile, '-Birth'],'-dpdf')

			close(h);

		end



		function makeCountLine(obj)
			% Makes a line of how Count varies with mutation factor
			data = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = obj.getParamNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.objectiveFunction, obj.crypt, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					data(end + 1) = b.simul.data.behaviour_data(2);
				catch
					data(end + 1) = nan;
				end
			end

			obj.countLine = data;

		end

		function h = makeCountPlot(obj)
			% Plot the line

			obj.makeCountLine();
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			plot(obj.values, obj.countLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Cell count','Interpreter','latex','FontSize',20);
			title(['Crypt cell count for mutation to ', obj.getParamName(obj.mutation)],'Interpreter','latex','FontSize',20);

		end
		function saveCountPlot(obj)
			h = obj.makeCountPlot();


			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print([obj.imageFile, '-CellCount'],'-dpdf')

			close(h);

		end




		function makeDivisionLine(obj)
			% Makes a line of how Division varies with mutation factor
			data = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = obj.getParamNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.objectiveFunction, obj.crypt, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					data(end + 1) = b.simul.data.behaviour_data(4);
				catch
					data(end + 1) = nan;
				end
			end

			obj.divisionLine = data;

		end

		function h = makeDivisionPlot(obj)
			% Plot the line

			obj.makeDivisionLine();
			% Plot the figure and set axis labels etc.
			h = figure();
			set(h,'Visible', 'off');
			plot(obj.values, obj.divisionLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Cell count','Interpreter','latex','FontSize',20);
			title(['Compartment cell count for mutation to ', obj.getParamName(obj.mutation)],'Interpreter','latex','FontSize',20);

		end
		function saveDivisionPlot(obj)
			h = obj.makeDivisionPlot();


			% Set the size of the output file
			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			
			print([obj.imageFile, '-CompartmentCount'],'-dpdf')

			close(h);

		end

	end





	

end