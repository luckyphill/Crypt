classdef TestdataType < matlab.unittest.TestCase
   
	methods (Test)
		% This tests the error catching ability of the dataType class
		% using a dummy concrete class implementation
		function testReadingErrors(testCase)

			% Test that file reading errors throw correctly
			testType = dummyDataType;

			file = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];
			
			[~,~] = system(['rm ',file]);
			sp.dataFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummyDNE.txt'];
			testCase.verifyError(@()testType.loadData(sp), 'dt:FileDNE');

			[~,~] = system(['touch ',file]);
			sp.dataFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummyCantRead.txt'];
			testCase.verifyError(@()testType.loadData(sp), 'dt:RetreivalFail');

			sp.dataFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummyInvalidData.txt'];
			testCase.verifyError(@()testType.loadData(sp), 'dt:VerificationFail');

		end

		%% testWritingErrors: function description
		function testWritingErrors(testCase)
			
			%Test that file writing errors throw correctly
			testType = dummyDataType;

			sp.data = {@plus};
			sp.saveFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummySaveFail.txt'];
			testCase.verifyError(@()testType.saveData(sp), 'dt:ProcessingFail');
		end

		function testReading(testCase)
			% Test that reading is successful
			testType = dummyDataType;

			sp.dataFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];
			csvwrite(sp.dataFile, [1,2;3,4]);
			data = testType.loadData(sp);

			testCase.verifyEqual(data, [1,2;3,4]);

		end
		
		function testWriting(testCase)
			% Test that writing is successful
			testType = dummyDataType;

			sp.data = [1,2;3,4];
			sp.saveFile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];
			status = testType.saveData(sp);

			testCase.verifyEqual(status, 1);

		end
		
	end
end