classdef RodsInChannel < FreeCellSimulation

	% This uses rod cells

	properties

		% None yet...

	end

	methods

		function obj = RodsInChannel(n, r, s, g, d, w, seed)

			% r is the rod growing force
			% s is the force pushing cells apart to their preferred distance
			% g is the time to grow from new cell to full size
			% d is the division probability for an hour
			% w is the width of the channel
			% The channel is represented by two infinitely long horizontal boundaries
			% set a width w apart

			obj.SetRNGSeed(seed);

			% Make a grid of starting points
			x = -5:5;
			y = 0.5:(w-0.5);

			[X,Y] = meshgrid(x,y);

			pairs = [X(:),Y(:)];
			pairs = datasample(pairs,10,1, 'Replace',false);

			rodLength = 0.5;

			for i = 1:n

				% pairs has the starting points, then pick a random angle
				theta = 2*pi*rand;

				x1 = pairs(i,1);
				y1 = pairs(i,2);

				x2 = x1 + rodLength*cos(theta);
				y2 = y1 + rodLength*sin(theta);

				n1 = Node(x1, y1, obj.GetNextNodeId());
				n2 = Node(x2, y2, obj.GetNextNodeId());

				e = Element(n1,n2,obj.GetNextElementId());

				obj.nodeList = [obj.nodeList, n1, n2];
				obj.elementList = [obj.elementList, e];
				
				c = RodCell(e,SimpleRodCellCycle(g, d, obj.dt,0.7),obj.GetNextCellId());
				c.newCellTargetArea = 0.5 * rodLength;
				c.grownCellTargetArea = rodLength;
				
				obj.cellList = [obj.cellList, c];

			end


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(RodCellRepulsionForce(0.2, s, obj.dt));

			% A force to keep the rod cell at its preferred length
			obj.AddCellBasedForce(RodCellGrowthForce(r));

			obj.AddSimulationModifier(HorizontalChannel(0, w));
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			pathName = sprintf('RodsInChannel/n%gr%gs%gg%gd%gw%g_seed%g/',n, r, s, g, d, w, seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));



		end
		
	end

end