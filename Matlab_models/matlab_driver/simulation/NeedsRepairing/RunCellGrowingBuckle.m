classdef RunCellGrowingBuckle < MatlabSimulation
	% Runs the CellGrowing simulation and handles all of the 
	% data processing and storage


	properties (SetAccess = immutable)
		% The name of the actual chaste test function as a string. This will
		% be used to build the simulation command and directory structure

		% Since this is a concrete implementation of a chasteSimulation the
		% name of the test will never be changed

		matlabTest = 'CellGrowing'

	end

	properties (SetAccess = private)
		% These are the input variables for CellGrowing
		% If new input variables are added, this may
		% need to be updated

		% Number of cells
		n 			double {mustBeNonnegative}

		% Cell cycle pahse lengths
		p 			double {mustBeNonnegative}
		g 			double {mustBeNonnegative}

		% Force parameters. Area energy, Perimeter energy, Adhesion energy
		Pa 			double {mustBeNonnegative}
		Pp 			double {mustBeNonnegative}
		Padh 		double {mustBeNonnegative}

		% These are solver parameters
		t 			double {mustBeNonnegative}
		dt 	= 0.005

		% This is the RNG seed parameter
		rngSeed 	double {mustBeNumeric}

		outputLocation
	end

	methods
		function obj = RunCellGrowingBuckle(n, p, g, Pa, Pp, Padh, seed)
			% The constructor for the runCellGrowingBuckle object
			% This expects the variables to be handed in as maps, which helps
			% make some of the generation functions easier and less cluttered to write
			% In addition, it needs to know where to find the 'Research' folder
			% so the functions can be used on multiple different machines
			% without needing to manually change
			% the path each time the script moves to another computer

			obj.n 		= n;
			obj.p 		= p;
			obj.g 		= g;
			obj.Pa 		= Pa;
			obj.Pp 		= Pp;
			obj.Padh 	= Padh;
			obj.rngSeed = seed;

			obj.researchPath = getenv('HOME');
			if isempty(obj.researchPath)
				error('HOME environment variable not set');
			end
			if ~strcmp(obj.researchPath(end),'/')
				obj.researchPath(end+1) = '/';
			end

			obj.GenerateSaveLocation();

			obj.simObj = CellGrowing(n, p, g, Pa, Pp, Padh, seed);
			obj.simObj.dt = obj.dt;

			obj.outputTypes = BuckleData;

		end

	end


	methods (Access = protected)
		% Helper methods to build the class


		function GenerateSaveLocation(obj)
			% This generates the full path to the specific data file for the simulation
			% If the path doesn't exist it creates the missing folder structure

			obj.saveLocation = [obj.researchPath, 'Research/Crypt/Data/Matlab/', obj.matlabTest, '/'];

			% Build the folder structure with the parameter names
			% This uses the order that the map puts it in
			% and it doesn't account for the default value of parameters when they
			% aren't in the simParams keys

			obj.saveLocation = [obj.saveLocation, sprintf('n_%d_p_%g_g_%g_Pa_%g_Pp_%g_Padh_%g',obj.n,obj.p,obj.g,obj.Pa,obj.Pp,obj.Padh)];
			obj.saveLocation = [obj.saveLocation, sprintf('/Buckle_%g',obj.dt)];
			obj.saveLocation = [obj.saveLocation, sprintf('/rng_%g/',obj.rngSeed)];


			if exist(obj.saveLocation,'dir')~=7
				mkdir(obj.saveLocation);
			end

		end

		function SimulationCommand(obj)

			obj.simObj.RunToBuckle();

		end

	end

end








