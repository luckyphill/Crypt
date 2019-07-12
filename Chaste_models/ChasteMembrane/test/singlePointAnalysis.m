classdef singlePointAnalysis


	properties
		
		% SAVE THIS FILE UNTIL ABSTRACTION IS NEEDED


	end

	methods

		function spA = singlePointAnalysis()

			p.outputType = positionData;

        	p.simParams = containers.Map({'n','np','ees','ms','cct','wt','vf'},{30,12,58,216,23,12,0.75});
        	p.solverParams = containers.Map({'t','bt','dt','sm'},{400,40,0.001,100});
        	p.seedParams = containers.Map({'run'},{10});

        	p.pathToFunction = '/Users/phillip/chaste_build/projects/ChasteMembrane/test/';
			p.pathToSimOutput = '/tmp/phillip/testoutput/';
			p.pathToDatabase = '/Users/phillip/Research/Crypt/Data/Chaste/';


		end
		% 
		function generateData()
			% A method to make the simpoints run their respective simulations 

		end
	end


end