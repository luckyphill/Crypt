classdef optimalPointWalk < matlab.mixin.SetGet

	% Change into a function that handles the new stepping from optimal params
	% Used to then create a plot of the objective function space

	properties
		crypt
		optimalPoint1
		optimalPoint2
		steps
		cryptName
		objectiveFunction
		healthyParams1
		healthyParams2

		points


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

		function obj = optimalPointWalk(crypt, optimalPoint1, optimalPoint2, steps, varargin)
			% Starting at optimalPoint1, we walk to optimalPoint2 in a straight line
			% in a number of hops determined by steps


			obj.crypt 				= crypt;
			obj.optimalPoint1 		= optimalPoint1;
			obj.optimalPoint2 		= optimalPoint2;
			obj.steps 				= steps;
			obj.cryptName 			= getCryptName(crypt);
			obj.objectiveFunction 	= str2func(obj.cryptName);

			obj.healthyParams1 		= getOptimalParams(crypt, optimalPoint1);
			obj.healthyParams2 		= getOptimalParams(crypt, optimalPoint2);


			obj.imageLocation = sprintf('%s/Research/Crypt/Images/optimalPointWalk/%s/Point%dto%din%d/',getenv('HOME'), obj.cryptName, obj.optimalPoint1, obj.optimalPoint2, obj.steps);
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.imageFilePenalty 		= sprintf('%sPenaltyFunction',obj.imageLocation);
			obj.imageFileAnoikis 		= sprintf('%sAnoikisRate',obj.imageLocation);
			obj.imageFileCount 			= sprintf('%sCellCount',obj.imageLocation);
			obj.imageFileTurnover 		= sprintf('%sCellTurnoverRate',obj.imageLocation);
			obj.imageFileCompartment 	= sprintf('%sCompartmentCount',obj.imageLocation);
			
			obj.makeLine(varargin);

		end

		function makePointsToVisit(obj)
			% Starting from point 1 and going to point 2 in steps
			% Make an array of the points that will be visited

			pRange = obj.healthyParams2 - obj.healthyParams1;

			pSteps = pRange/obj.steps;

			for i=0:obj.steps
				points(i+1,:) = obj.healthyParams1 + i * pSteps;
			end

			obj.points = points;

		end


		function makeLine(obj, varargin)
			% Gets all the data for the short sweep
			penalty = [];
			anoikis = [];
			count = [];
			turnover = [];
			compartment = [];

			obj.makePointsToVisit();


			for j = 1:length(obj.steps)
				try
					n 						= obj.points(j,1);
					np						= obj.points(j,2);
					ees						= obj.points(j,3);
					ms						= obj.points(j,4);
					cct						= obj.points(j,5);
					wt						= obj.points(j,6);
					vf						= obj.points(j,7);

					b 						= setBehaviour(obj.objectiveFunction,n,np,ees,ms,cct,wt,vf,varargin);

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
			xlabel('Step Number','Interpreter','latex','FontSize',20);
			ylabel('Penalty','Interpreter','latex','FontSize',20);
			title('Objective function penalty between optimal points','Interpreter','latex','FontSize',20);


			hAnoikis 		= figure('Visible', 'off');
			plot(obj.values, obj.anoikisLine, 'LineWidth', 4);
			xlabel('Step Number','Interpreter','latex','FontSize',20);
			ylabel('Anoikis rate','Interpreter','latex','FontSize',20);
			title('Measured anoikis rate between optimal points','Interpreter','latex','FontSize',20);


			hCount 			= figure('Visible', 'off');
			plot(obj.values, obj.countLine, 'LineWidth', 4);
			xlabel('Step Number','Interpreter','latex','FontSize',20);
			ylabel('Average cell count','Interpreter','latex','FontSize',20);
			title('Average cell count between optimal points','Interpreter','latex','FontSize',20);


			hTurnover 		= figure('Visible', 'off');
			plot(obj.values, obj.turnoverLine, 'LineWidth', 4);
			xlabel('Step Number','Interpreter','latex','FontSize',20);
			ylabel('Turnover','Interpreter','latex','FontSize',20);
			title('Measured cell turnover rate between optimal points','Interpreter','latex','FontSize',20);


			hCompartment 	= figure('Visible', 'off');
			plot(obj.values, obj.compartmentLine, 'LineWidth', 4);
			xlabel('Step Number','Interpreter','latex','FontSize',20);
			ylabel('Compartment size','Interpreter','latex','FontSize',20);
			title('Maximum compartment size between optimal points','Interpreter','latex','FontSize',20);

			h = [hPenalty, hAnoikis, hCount, hTurnover, hCompartment];

		end

	end

end