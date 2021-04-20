classdef KMeansCheck < Analysis

	% This is for the optimal point analysis from the Chaste model
	% mainly used here to keep in the format and stop loose files floating around

	properties

		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		targetTime = 500;

		analysisName = 'KMeansCheck';

		parameterSet = []
		missingParameterSet = []

		simulationRuns = 50
		slurmTimeNeeded = 12
		simulationDriverName = 'ManageDynamicLayer'
		simulationInputCount = 7
		

	end

	methods

		function obj = KMeansCheck()

			obj.seedIsInParameterSet = false; % The seed not given in MakeParameterSet, it is set in properties
			obj.seedHandledByScript = false; % The seed will be in the parameter file, not the job script
			obj.usingHPC = false;

		end

		function MakeParameterSet(obj)

			params = [];

			obj.parameterSet = params;

		end

		

		function BuildSimulation(obj)

			% obj.MakeParameterSet();
			% obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Load the specific file that contains the optimal points
			data = readmatrix('/Users/phillip/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/analysis/OptimalProcessing/output.txt');

			f = {@MouseColonDesc,@MouseColonTrans,@MouseColonAsc,@MouseColonCaecum,@RatColonDesc,@RatColonTrans,@RatColonAsc,@RatColonCaecum};


			for i = 1:length(data)
				for j = 1:8
					output(i,j) = f{j}(data(i,:));
				end
			end


			obj.result = {output};
			

		end

		function PlotData(obj)

			params = obj.result{1};

			h = figure;

			i = 3;

			vals = params{i};

			paramNames = {'Sloughing height', 'Differentiation height', 'Cell interaction stiffness', 'Memebrane adhesion stiffness',...
							'Cell cycle duration', 'Growth duration', 'Contact inhibition fraction'};

			for j = 1:7
				for k = j+1:7
					for l = k+1:7

					h = figure;

					scatter3(vals(:,j),vals(:,k),vals(:,l));
					
					xlabel(paramNames{j},'Interpreter', 'latex', 'FontSize', 15);
					ylabel(paramNames{k},'Interpreter', 'latex', 'FontSize', 15);
					zlabel(paramNames{l},'Interpreter', 'latex', 'FontSize', 15);
					title('Parameters for optimal crypts','Interpreter', 'latex', 'FontSize', 22);
					
					x_r = max(vals(:,j)) - min(vals(:,j));
					y_r = max(vals(:,k)) - min(vals(:,k));
					z_r = max(vals(:,l)) - min(vals(:,l));
					
					xlim([min(vals(:,j))-x_r*0.1, max(vals(:,j))+x_r*0.1]);
					ylim([min(vals(:,k))-y_r*0.1, max(vals(:,k))+y_r*0.1]);
					zlim([min(vals(:,l))-z_r*0.1, max(vals(:,l))+z_r*0.1]);

					end

				end

			end

			% SavePlot(obj, h, sprintf(''));



		end

	end

end