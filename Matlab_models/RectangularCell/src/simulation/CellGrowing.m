classdef CellGrowing < LineSimulation

	% This simulation is the most basic - a simple row of cells growing on
	% a plate. It allows us to choose the number of initial cells
	% the force related parameters, and the cell cycle lengths

	properties

		dt = 0.005
		t = 0
		eta = 1

		timeLimit = 200

	end

	methods

		function obj = CellGrowing(nCells, p, g, areaEnergy, perimeterEnergy, adhesionEnergy, seed, varargin)
			% All the initilising
			obj.SetRNGSeed(seed);

			%---------------------------------------------------
			% Make all the cells
			%---------------------------------------------------

			% The first cell needs all elements and nodes created
			% subsequent cells will have nodes and elements from their
			% neighbours

			% Make the nodes

			nodeTopLeft 	= Node(0,1,obj.GetNextNodeId());
			nodeBottomLeft 	= Node(0,0,obj.GetNextNodeId());
			nodeTopRight 	= Node(0.5,1,obj.GetNextNodeId());
			nodeBottomRight	= Node(0.5,0,obj.GetNextNodeId());

			obj.AddNodesToList([nodeBottomLeft, nodeBottomRight, nodeTopRight, nodeTopLeft]);

			% Make the elements

			elementBottom 	= Element(nodeBottomLeft, nodeBottomRight, obj.GetNextElementId());
			elementRight 	= Element(nodeBottomRight, nodeTopRight, obj.GetNextElementId());
			elementTop	 	= Element(nodeTopLeft, nodeTopRight, obj.GetNextElementId());
			elementLeft 	= Element(nodeBottomLeft, nodeTopLeft, obj.GetNextElementId());

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			% Cell cycle model

			ccm = SimplePhaseBasedCellCycle(p, g);

			% Assemble the cell

			obj.cellList = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());


			for i = 2:nCells
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeTopRight 	= Node(i*0.5,1,obj.GetNextNodeId());
				nodeBottomRight	= Node(i*0.5,0,obj.GetNextNodeId());
				

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				% Critical for joined cells
				elementLeft.internal = true;
				
				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = SimplePhaseBasedCellCycle(p, g);

				obj.cellList(i) = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(NagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% Corner force to prevent very sharp corners
			obj.AddCellBasedForce(CornerForceCouple(0.1,pi/2));

			% Element force to stop elements becoming too small
			obj.AddElementBasedForce(EdgeSpringForce(@(n,l) 20 * exp(1-25 * l/n)));

			% Node-Element interaction force - requires a SpacePartition
			% obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			% We keep the option of diffent box sizes for efficiency reasons
			if length(varargin) > 0
				obj.boxes = SpacePartition(varargin{1}, varargin{2}, obj);
			else
				obj.boxes = SpacePartition(0.5, 0.5, obj);
			end

			%---------------------------------------------------
			% Add the data we'd like to store
			%---------------------------------------------------

			obj.AddDataStore(StoreWiggleRatio(20));


			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20,'CellGrowing/'));

			%---------------------------------------------------
			% All done. Ready to roll
			%---------------------------------------------------

		end


		function RunToBuckle(obj)

			% This function runs the simulation until just after buckling has occurred
			% Buckling is defined by the wiggle ratio, i.e. epithelial length/domain width

			obj.AddStoppingCondition(BuckledStoppingCondition(1.1));

			obj.RunToTime(obj.timeLimit);

		end

	end

end
