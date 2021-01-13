classdef MultiLine < LineSimulation

	% A proof of concept simulation with several free floating cells
	% This will break some functionality in AbstractCellSImulation
	% but it should be minor

	properties

		dt = 0.005
		t = 0
		eta = 1

		timeLimit = 2000

	end

	methods

		function obj = MultiLine(p, g, seed, varargin)
			% All the initilising
			obj.SetRNGSeed(seed);

						% We keep the option of diffent box sizes for efficiency reasons
			if length(varargin) > 0
				if length(varargin) == 3
					areaEnergy = varargin{1};
					perimeterEnergy = varargin{2};
					adhesionEnergy = varargin{3};
				else
					error('Error using varargin, must have 3 args, areaEnergy, perimeterEnergy, and adhesionEnergy');
				end
			else
				areaEnergy = 20;
				perimeterEnergy = 10;
				adhesionEnergy = 1;
			end



			%---------------------------------------------------
			% Make the cells
			%---------------------------------------------------

			% Gpoing to put a bunch of free cells together and see what happens
			% when they grow they will start to produce their own lines, but that is
			% something we can deal with later

			%---------------------------------------------------
			% Cell 1
			%---------------------------------------------------
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

			obj.cellList = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			%---------------------------------------------------
			% Cell 2
			%---------------------------------------------------
			nodeTopLeft 	= Node(0.6,0.5,obj.GetNextNodeId());
			nodeBottomLeft 	= Node(1.6,0.5,obj.GetNextNodeId());
			nodeTopRight 	= Node(0.6,1,obj.GetNextNodeId());
			nodeBottomRight	= Node(1.6,1,obj.GetNextNodeId());

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

			obj.cellList(2) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			%---------------------------------------------------
			% Cell 3
			%---------------------------------------------------
			nodeTopLeft 	= Node(-0.5,1.1,obj.GetNextNodeId());
			nodeBottomLeft 	= Node(0.5,1.1,obj.GetNextNodeId());
			nodeTopRight 	= Node(-0.5,1.6,obj.GetNextNodeId());
			nodeBottomRight	= Node(0.5,1.6,obj.GetNextNodeId());

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

			obj.cellList(3) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			%---------------------------------------------------
			% Cell 4
			%---------------------------------------------------
			nodeTopLeft 	= Node(0.6,2.1,obj.GetNextNodeId());
			nodeBottomLeft 	= Node(0.6,1.1,obj.GetNextNodeId());
			nodeTopRight 	= Node(1.1,2.1,obj.GetNextNodeId());
			nodeBottomRight	= Node(1.1,1.1,obj.GetNextNodeId());

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

			obj.cellList(4) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

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
			obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			% In this simulation we are fixing the size of the boxes

			obj.boxes = SpacePartition(0.5, 0.5, obj);

			%---------------------------------------------------
			% All done. Ready to roll
			%---------------------------------------------------

		end


	end

end
