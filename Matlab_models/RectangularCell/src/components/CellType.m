classdef CellType < matlab.mixin.SetGet
	% The colours for rendering cells

	properties

		typeMap

		numToName

		nameToNum
		
	end

	methods

		function obj = CellType()

			names = {'EPI','STROMAL'};

			values = {1,2};

			obj.typeMap = containers.Map(names,values);

		end

	end