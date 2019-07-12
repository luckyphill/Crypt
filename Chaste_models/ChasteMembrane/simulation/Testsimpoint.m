classdef Testsimpoint < matlab.unittest.TestCase
   
    properties

    		p.chasteTest = 'TestCryptColumn';
        	p.outputType = positionData;

        	p.simParams = containers.Map({'n','np','ees','ms','cct','wt','vf'},{30,12,58,216,23,12,0.75});
        	p.solverParams = containers.Map({'t','bt','dt','sm'},{400,40,0.001,100});
        	p.seedParams = containers.Map({'run'},{10});

        	p.pathToFunction = '/Users/phillip/chaste_build/projects/ChasteMembrane/test/';
			p.pathToSimOutput = '/tmp/phillip/testoutput/';
			p.pathToDatabase = '/Users/phillip/Research/Crypt/Data/Chaste/';

    end

    methods (Test)
        % This tests various features of the simpoint class

        function testInputString(testCase)


        	correctInputString = ' -cct 23 -ees 58 -ms 216 -n 30 -np 12 -vf 0.75 -wt 12 -bt 40 -dt 0.001 -sm 100 -t 400 -run 10';

        	testsp = simpoint(p);

        	testCase.verifyEqual(testsp.inputString, correctInputString);

        end


    end


end