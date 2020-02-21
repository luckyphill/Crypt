classdef basinAnalysisLine < matlab.mixin.SetGet

	% Change into a function that handles the new stepping from optimal params
	% Used to then create a plot of the objective function space

	properties
		crypt
		optimalPoint
		cryptName
		objectiveFunction
		healthyParams
		mutation
		values

		penaltyLine
		anoikisLine
		countLine
		turnoverLine
		compartmentLine

		imageLocation
		
		imageFilePenalty
		imageFileAnoikis
		imageFileCount
		imageFileTurnover
		imageFileCompartment


	end

	methods

		function obj = basinAnalysisLine(crypt, optimalPoint, mutation, values)
			% Performs a parameter sweep in a single parameter for crypt with optimalPointion optimalPoint
			% Mutation is a string with the usual mutation flag,
			% Values is an array of mutation factors to be plotted
			% Only one mutation is considered in this analysis


			obj.crypt = crypt;
			obj.optimalPoint = optimalPoint;
			obj.cryptName = getCryptName(crypt);
			obj.objectiveFunction = str2func(obj.cryptName);
			obj.healthyParams = getOptimalParams(crypt, optimalPoint);

			obj.mutation = mutation;
			obj.values = values;


			obj.imageLocation = sprintf('%s/Research/Crypt/Images/basinAnalysisLine/%s/optimalPoint%d/%s/',getenv('HOME'), obj.cryptName, obj.optimalPoint, getMutationName(obj.mutation) );
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.imageFilePenalty 		= sprintf('%sPenaltyFunction',obj.imageLocation);
			obj.imageFileAnoikis 		= sprintf('%sAnoikisRate',obj.imageLocation);
			obj.imageFileCount 			= sprintf('%sCellCount',obj.imageLocation);
			obj.imageFileTurnover 		= sprintf('%sCellTurnoverRate',obj.imageLocation);
			obj.imageFileCompartment 	= sprintf('%sCompartmentCount',obj.imageLocation);
			
			obj.makeLine();

		end

		function makeLine(obj)
			% Gets all the data for the short sweep
			% 
			penalty = [];
			anoikis = [];
			count = [];
			turnover = [];
			compartment = [];

			% The mutation factors value. All should be 1 except the mutation of interest
			f = ones(1,7);
			i = getMutationNumber(obj.mutation);

			for j = 1:length(obj.values)
				f(i) = obj.values(j);
				try
					b = basinObjective(obj.crypt, obj.optimalPoint, f(1), f(2), f(3), f(4), f(5), f(6), f(7), 'varargin');
					penalty(end + 1) 		= b.penalty;
					anoikis(end + 1) 		= b.simul.data.behaviour_data(1);
					count(end + 1) 			= b.simul.data.behaviour_data(2);
					turnover(end + 1) 		= b.simul.data.behaviour_data(3);
					compartment(end + 1) 	= b.simul.data.behaviour_data(4);
				catch
					penalty(end + 1) 		= nan;
					anoikis(end + 1) 		= nan;
					count(end + 1) 			= nan;
					turnover(end + 1) 		= nan;
					compartment(end + 1)	= nan;
				end
			end

			obj.penaltyLine 		= penalty;
			obj.anoikisLine 		= anoikis;
			obj.countLine 			= count;
			obj.turnoverLine		= turnover;
			obj.compartmentLine		= compartment;

		end

		

		function savePlots(obj)
			h = obj.makePlots();


			% Set the size of the output file
			for i = 1:5
				set(h(i),'Units','Inches');
				pos = get(h(i),'Position');
				set(h(i),'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
			end
			
			% Must match the order in make plots
			print(h(1), obj.imageFilePenalty, '-dpdf');
			print(h(2), obj.imageFileAnoikis, '-dpdf');
			print(h(3), obj.imageFileCount, '-dpdf');
			print(h(4), obj.imageFileTurnover, '-dpdf');
			print(h(5), obj.imageFileCompartment, '-dpdf');

			close(h);

		end

		function showPlots(obj)
			h = obj.makePlots();
			for i = 1:5
				set(h(i),'Visible', 'on');
			end

		end

		function h = makePlots(obj)
		
			% Plot the figure and set axis labels etc.
			hPenalty 		= figure('Visible', 'off');
			plot(obj.values, obj.penaltyLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Penalty','Interpreter','latex','FontSize',20);
			title(['Objective function penalty for mutation to ', getMutationName(obj.mutation)],'Interpreter','latex','FontSize',20);


			hAnoikis 		= figure('Visible', 'off');
			plot(obj.values, obj.anoikisLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Anoikis rate','Interpreter','latex','FontSize',20);
			title(['Measured anoikis rate for mutation to ', getMutationName(obj.mutation)],'Interpreter','latex','FontSize',20);


			hCount 			= figure('Visible', 'off');
			plot(obj.values, obj.countLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Average cell count','Interpreter','latex','FontSize',20);
			title(['Average cell count for mutation to ', getMutationName(obj.mutation)],'Interpreter','latex','FontSize',20);


			hTurnover 		= figure('Visible', 'off');
			plot(obj.values, obj.turnoverLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Turnover','Interpreter','latex','FontSize',20);
			title(['Measured cell turnover rate for mutation to ', getMutationName(obj.mutation)],'Interpreter','latex','FontSize',20);


			hCompartment 	= figure('Visible', 'off');
			plot(obj.values, obj.compartmentLine, 'LineWidth', 4);
			xlabel('Mutation factor','Interpreter','latex','FontSize',20);
			ylabel('Compartment size','Interpreter','latex','FontSize',20);
			title(['Maximum compartment size for mutation to ', getMutationName(obj.mutation)],'Interpreter','latex','FontSize',20);

			h = [hPenalty, hAnoikis, hCount, hTurnover, hCompartment];

		end

	end

end