classdef clonalConversionPlot < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		outputTypes = clonalData();
		mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
		solverParams = containers.Map({'t', 'bt'}, {1000, 100});
		seedParams = containers.Map({'run'}, {1});
		simParams

		imageFile
		imageLocation

		simul
		mrange
		frac

	end


	methods
		function obj = clonalConversionPlot(simParams, mutation, mrange, reps)
			obj.simParams = simParams;
			% A weird bug where this object isn't remade when it's reused
			obj.mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
			rate = zeros(length(mrange),reps);
			for i=1:length(mrange)
				for k = 1:length(mutation)
					obj.mutantParams(mutation{k}) = mrange(i);
				end
				for j=1:reps
					obj.seedParams = containers.Map({'run'}, {j});
					s = simulateCryptColumnSingleMutation(obj.simParams, obj.mutantParams, obj.solverParams, obj.seedParams, obj.outputTypes);
					s.loadSimulationData();
					rate(i,j) = s.data.clonal_data;
				end
			end
			obj.simul = s;
			q = nansum(rate,2);
			r = sum(~isnan(rate),2);

			obj.frac  = q./r;
			obj.mrange = mrange;
		end

		function plotConversion(obj)
			% Plots and saves the clonal conversion rate plot
			h = figure();
			plot(obj.mrange, obj.frac, 'LineWidth', 3);
			xlim([min(obj.mrange) max(obj.mrange)]);
			ylim([0 1]);
            xlabel('Mutation factor','Interpreter','latex','FontSize',14);
            ylabel('Proportion','Interpreter','latex','FontSize',14);
            title('Proportion of mutant take-over vs mutation factor','Interpreter','latex','FontSize',20);
		end
		

	end


end
