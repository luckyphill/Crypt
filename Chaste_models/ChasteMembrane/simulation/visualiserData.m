classdef visualiserData < dataType
	% This class moves the visualiser data to a fixed location

	properties (Constant = true)
		name = 'visualiser_data';
	end

	methods

		function obj = visualiserData(typeParams)
			% Constructor needs to be given the parameters that the particular chasteTest
			% needs in order to generate the expected output format
			obj.typeParams = typeParams;
		end

	end

	methods (Access = protected)
		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			if exist(sp.dataFile)
				data = 1;
			else
				error('vD:LoadError', 'Check file doesnt exist');
			end

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the output
			% and put it in the expected location, in the expected format

			%%-----------------------------------------------------------------------
			%%-----------------------------------------------------------------------
			%% move vizboundarynodes

			outputFile = [sp.simOutputLocation, 'results.vizboundarynodes'];
			saveFile = [sp.saveLocation, 'results.vizboundarynodes'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');

			if status
				error('vD:MoveError', 'Move failed: results.vizboundarynodes')
			end


			%%-----------------------------------------------------------------------
			%%-----------------------------------------------------------------------
			%% move results.vizcelltypes
			outputFile = [sp.simOutputLocation, 'results.vizcelltypes'];
			saveFile = [sp.saveLocation, 'results.vizcelltypes'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');

			if status
				error('vD:MoveError', 'Move failed: results.vizcelltypes')
			end

			%%-----------------------------------------------------------------------
			%%-----------------------------------------------------------------------
			%% move results.viznodes
			outputFile = [sp.simOutputLocation, 'results.viznodes'];
			saveFile = [sp.saveLocation, 'results.viznodes'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');

			if status
				error('vD:MoveError', 'Move failed: results.viznodes')
			end

			%%-----------------------------------------------------------------------
			%%-----------------------------------------------------------------------
			% move results.vizsetup
			outputFile = [sp.simOutputLocation, 'results.vizsetup'];
			saveFile = [sp.saveLocation, 'results.vizsetup'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');

			if status
				error('vD:MoveError', 'Move failed: results.vizsetup')
			end


			%%-----------------------------------------------------------------------
			%%-----------------------------------------------------------------------
			% At this point in time, the file name is handled by the simulation
			% and it doesn't allow multiple files, so need to make a dummy file to 
			% keep the work flow happy

			[status,cmdout] = system(['touch ',  saveFile],'-echo');

			if status
				error('vD:TouchError', 'Move failed: failed to create success marker file')
			end

			
			

		end

	end

end