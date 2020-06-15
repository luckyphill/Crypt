classdef ColourSet < matlab.mixin.SetGet
	% The colours for rendering cells

	properties

		colourMap

		numToName

		nameToNum
		
	end

	methods

		function obj = ColourSet()

			% Don't really know a better way to set the property 
			names = {'PAUSE','GROW','STOPPED','DYING','STROMA'};

			values ={[0.9375 0.7383 0.6562],
						[0.6562 0.8555 0.9375],
						[0.6680 0.5430 0.4883],
						[0.5977 0.5859 0.5820],
						[ 0.9453, 0.9023, 0.6406]};

			obj.colourMap = containers.Map(names,values);

			obj.numToName = containers.Map( {1,2,3,4,5}, names);

			obj.nameToNum = containers.Map( names, {1,2,3,4,5});

		end

		function colour = GetRGB(obj, c)

			% Returns the RGB vector

			if isa(c, 'double')
				c = obj.numToName(c);
			end

			colour = obj.colourMap(c);

		end

		function colour = GetNumber(obj, c)

			% Returns the number matching the name
			colour = obj.nameToNum(c);

		end

	end

end
