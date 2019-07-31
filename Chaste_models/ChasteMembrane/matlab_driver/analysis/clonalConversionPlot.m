classdef clonalConversionPlot < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		outputTypes = clonalData(  containers.Map( {'Sml', 'Scc'}, {1, 1} )  );
		mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
		solverParams = containers.Map({'t', 'bt', 'dt'}, {400, 40, 0.0005});
		seedParams = containers.Map({'run'}, {1});
		simParams

		chastePath = [getenv('HOME'), '/'];
		chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];

		imageFile
		imageLocation

		simul

	end


	methods
		function obj = clonalConversionPlot(simParams, mutation, mrange, reps, np, vf)
			obj.mutantParams('Mnp') = np;
			obj.mutantParams('Mvf') = vf;
			obj.simParams = simParams;
			rate = zeros(length(mrange),reps);
			for i=1:length(mrange)
				obj.mutantParams(mutation) = mrange(i);
				for j=1:reps
					obj.seedParams = containers.Map({'run'}, {j});
					s = simulateCryptColumnMutation(obj.simParams, obj.mutantParams, obj.solverParams, obj.seedParams, obj.outputTypes, obj.chastePath, obj.chasteTestOutputLocation);
					s.loadSimulationData();
					rate(i,j) = s.data.clonal_data;
				end
			end
			obj.simul = s;
			q = nansum(rate,2);
			r = sum(~isnan(rate),2);

			frac  = q./r;

			plot(mrange, frac)
		end

	end


end
