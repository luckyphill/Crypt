classdef LineSimulation < AbstractCellSimulation

	% This type of simulation is a row of cells with two distinct ends
	% I wanted to call this an abstract class, but I can't make the constructor
	% I need, so here we are...

	properties

		step = 0

	end

	methods

		function obj  = LineSimulation()

			obj.AddSimulationData(WiggleRatio());
			obj.AddSimulationData(CentreLine());
			obj.AddSimulationData(BoundaryCells());

		end

		function KillCells(obj)

			KillCells@AbstractCellSimulation(obj);
			if obj.usingBoxes && strcmp(class(obj.cellList(1)), 'SquareCellJoined')
				% Make sure that the boundary cells have their outer
				% elements in the space partition, only needs to be updated
				% when cells are actually killed.

				% This will most likely update the time step after death occurs
				% so there could be some buggyness

				bcs = obj.simData('boundaryCells').GetData(obj);

				l = bcs('left');
				r = bcs('right');

				if l.elementLeft.internal
					l.elementLeft.internal = false;
					obj.boxes.PutElementInBoxes(l.elementLeft);
				end

				if r.elementRight.internal
					r.elementRight.internal = false;
					obj.boxes.PutElementInBoxes(r.elementRight);
				end

			end

		end
		
	end

end