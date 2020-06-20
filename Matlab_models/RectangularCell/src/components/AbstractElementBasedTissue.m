classdef (Abstract) AbstractElementBasedTissue < AbstractTissue
	% A parent class for a cell based tissue. This is used for things
	% like epithelia or anythign rally that is made up of cells

	properties

		elementList
		nextElementId = 1

		elementBasedForces AbstractElementBasedForce

		tissueBasedForces AbstractElementBasedTissueForce

	end

	methods

		function AddElementBasedForce(obj, f)

			if isempty(obj.elementBasedForces)
				obj.elementBasedForces = f;
			else
				obj.elementBasedForces(end + 1) = f;
			end

		end

		function numElements = GetNumElements(obj)

			numElements = length(obj.elementList);

		end

	end

	methods (Access = protected)

		function AddElementsToList(obj, listOfElements)
			
			for i = 1:length(listOfElements)
				% If any of the Elements are already in the list, don't add them
				if sum(ismember(listOfElements(i), obj.elementList)) == 0
					obj.elementList = [obj.elementList, listOfElements(i)];
				end

			end

		end

		function id = GetNextElementId(obj)
			
			id = obj.nextElementId;
			obj.nextElementId = obj.nextElementId + 1;

		end

	end

end


