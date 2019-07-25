classdef clonalConversionPlot < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		outputTypes = clonalData;
		simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});
		mutationParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
		solverParams = containers.Map({'t', 'bt', 'dt'}, {400, 40, 0.001});
		seedParams = containers.Map({'run'}, {1});

		chastePath = [getenv('HOME'), '/'];
		chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];

		imageFile
		imageLocation

	end


	methods
		function obj = clonalConversionPlot(mutation, mrange, reps)

			rate = zeros(length(mrange),reps);
			for i=1:length(mrange)
				obj.mutationParams(mutation) = mrange(i);
				for j=1:reps
					obj.seedParams = containers.Map({'run'}, {j});
					s = simulateCryptColumnMutation(obj.simParams, obj.mutationParams, obj.solverParams, obj.seedParams, obj.outputTypes, obj.chastePath, obj.chasteTestOutputLocation);
					s.loadSimulationData();
					rate(i,j) = s.data.clonal_data;
				end
			end

			q = nansum(rate,2);
			r = sum(~isnan(rate),2);

			frac  = q./r;

			plot(mrange, frac)
		end

	end


end
