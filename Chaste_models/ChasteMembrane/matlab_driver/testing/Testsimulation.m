classdef Testsimulation < matlab.unittest.TestCase


	methods (Test)
		% This tests various features of the simpoint class

		function testSetting(testCase)

			% Tests error catching for dataType
			testCase.verifyError(@()dummySimulation('wronginput'), 'sim:dataType');

			testCase.verifyError(@()dummySimulation({dummyDataType,'wronginput'}), 'MATLAB:invalidType');

			testCase.verifyError(@()dummySimulation({dummyDataType, dummyDataType}),'sim:TwoOfTheSameDataType');

			% Test that numOutputTypes is set correctly
			testSimulation = dummySimulation(dummyDataType);
			testCase.verifyEqual(testSimulation.numOutputTypes, 1);

			testSimulation = dummySimulation({dummyDataType, positionData(containers.Map({'sm'},{10}))});
			testCase.verifyEqual(testSimulation.numOutputTypes, 2);
			
			% Test that oveWrite is set correctly
			testSimulation.overWrite = true;
			testCase.verifyEqual(testSimulation.overWrite, true);

			

		end

		function testRunning(testCase)
			% Tests that the correct success codes are returned in given situations

			% Test that it generates the file when it doesn't exist
			testSimulation = dummySimulation(dummyDataType);
			file = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];
			[~,~] = system(['rm ',file]);
			code = testSimulation.generateSimulationData();
			testCase.verifyEqual(code, 1);

			% Test that it find the file when it does exist
			testSimulation = dummySimulation(dummyDataType);
			code = testSimulation.generateSimulationData();
			testCase.verifyEqual(code, 2);

			% Test that it overwrites the file if given overWrite = true
			testSimulation = dummySimulation(dummyDataType);
			testSimulation.overWrite = true;
			code = testSimulation.generateSimulationData();
			testCase.verifyEqual(code, 3);

			% Test that it give the correct code when something goes wrong with data writing
			testSimulation = dummySimulation({dummyDataType, positionData(containers.Map({'sm'},{10}))});
			code = testSimulation.generateSimulationData();
			testCase.verifyEqual(code, 0);

			% Should have only been trying to run the positionData part
			testCase.verifyEqual(length(testSimulation.outputTypesToRun), 1);

			% And the same again if overwriting
			testSimulation.overWrite = true;
			code = testSimulation.generateSimulationData();
			testCase.verifyEqual(code, 0);

			% Should have been trying to run both
			testCase.verifyEqual(length(testSimulation.outputTypesToRun), 2);

		end

		function testLoading(testCase)
			% Tests that loading operates correctly

			testSimulation = dummySimulation( {dummyDataType, positionData( containers.Map({'sm'},{10}) )});
			code = testSimulation.generateSimulationData();

			testSimulation.loadSimulationData();
			testCase.verifyEqual(testSimulation.data.dummy, [1,2;3,4]);
			testCase.verifyEqual(testSimulation.data.position_data, nan);

		end


	end


end