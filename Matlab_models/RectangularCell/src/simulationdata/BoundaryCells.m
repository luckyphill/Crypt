classdef BoundaryCells < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'boundaryCells'

	end

	methods

		function obj = BoundaryCells
			% No special initialisation
			obj.data = containers.Map{};
		end

		function CalculateData(obj, t)

			if isempty(obj.data)
				% Probably the first time this has been run,
				% so need to find the boundary cells first
				% This won't work in general, but will be the case most of the time at this point
				obj.data{'left'} 	= t.cellList(1);
				obj.data{'right'} 	= t.cellList(end);
			end



			while length(obj.data{'left'}.elementLeft.cellList) > 1
				% The left element of the cell is part of at least two cells
				% So need to replace the leftBoundaryCell
				if obj.data{'left'} == obj.data{'left'}.elementLeft.cellList(1)
					obj.data{'left'} = obj.data{'left'}.elementLeft.cellList(2);
				else
					obj.data{'left'} = obj.data{'left'}.elementLeft.cellList(1);
				end

			end


			while length(obj.data{'right'}.elementRight.cellList) > 1
				% The right element of the cell is part of at least two cells
				% So need to replace the rightBoundaryCell
				if obj.data{'right'} == obj.data{'right'}.elementRight.cellList(1)
					obj.data{'right'} = obj.data{'right'}.elementRight.cellList(2);
				else
					obj.data{'right'} = obj.data{'right'}.elementRight.cellList(1);
				end

			end

		end
		
	end


end