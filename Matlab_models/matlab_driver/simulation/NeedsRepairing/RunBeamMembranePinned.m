classdef RunBeamMembranePinned < MatlabSimulation
	% Runs the CellGrowing simulation and handles all of the 
	% data processing and storage


	properties (SetAccess = immutable)
		% The name of the actual chaste test function as a string. This will
		% be used to build the simulation command and directory structure

		% Since this is a concrete implementation of a chasteSimulation the
		% name of the test will never be changed

		matlabTest = 'BeamMembranePinned'

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
		w			double {mustBeNonnegative}
		b			double {mustBeNonnegative}

		% These are solver parameters
		t 			double {mustBeNonnegative}
		dt 	= 0.001

		% This is the RNG seed parameter
		rngSeed 	double {mustBeNumeric}

		outputLocation
	end

	methods
		function obj = RunBeamMembranePinned(n, p, g, w, b, seed)
			% The constructor for the runBeamMembranePinned object
			% This expects the variables to be handed in as maps, which helps
			% make some of the generation functions easier and less cluttered to write
			% In addition, it needs to know where to find the 'Research' folder
			% so the functions can be used on multiple different machines
			% without needing to manually change
			% the path each time the script moves to another computer

			obj.n 		= n;
			obj.p 		= p;
			obj.g 		= g;
			obj.w 		= w;
			obj.b 		= b;
			obj.rngSeed = seed;

			obj.researchPath = getenv('HOME');
			if isempty(obj.researchPath)
				error('HOME environment variable not set');
			end
			if ~strcmp(obj.researchPath(end),'/')
				obj.researchPath(end+1) = '/';
			end

			obj.GenerateSaveLocation();

			obj.simObj = BeamMembranePinned(n, p, g, w, b, seed);
			obj.simObj.dt = obj.dt;

			obj.outputTypes = {WiggleData, TopWiggleData, BottomWiggleData};

		end

	end


	methods (Access = protected)
		% Helper methods to build the class


		function GenerateSaveLocation(obj)
			% This generates the full path to the specific data file for the simulation
			% If the path doesn't exist it creates the missing folder structure

			obj.saveLocation = [obj.researchPath, 'Research/Crypt/Data/Matlab/SimulationOutput/', obj.matlabTest, '/'];


			if exist(obj.saveLocation,'dir')~=7
				mkdir(obj.saveLocation);
			end

		end

		function SimulationCommand(obj)

			obj.simObj.RunToBuckle(1.5);

		end

	end

end








