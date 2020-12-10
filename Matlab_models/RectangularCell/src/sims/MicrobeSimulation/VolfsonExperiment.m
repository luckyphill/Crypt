classdef VolfsonExperiment < FreeCellSimulation

	% This uses rod cells to reproduce the experiment by Volfson et al.
	% in which a population of E. coli cells are confined to a channel
	% and are allowed to grow.

	properties

		% None yet...

	end

	methods

		function obj = VolfsonExperiment(n, r, s, tg, d, w, seed)

			% n is the number of cells to seed the experiment with
			% r is the rod growing force
			% s is the force pushing cells apart to their preferred distance
			% tg is the time to grow from new cell to full size
			% d division threshold for the Bernoulli trial
			% w is the width of the channel
			% The channel is represented by two infinitely long horizontal boundaries
			% set a width w apart

			% Other parameters
			% Growth start time and minimum division time
			t0 = 0;
			tm = tg;
			% Contact inhibition fraction
			f = 0.7;

			% The asymptote, separation, and limit distances for the interaction force
			dAsym = 0;
			dSep = 0.2;
			dLim = dSep;

			% Rod attraction force (irrelevant unless dLim > dSep)
			a = 0;

			obj.SetRNGSeed(seed);

			% Make a grid of starting points
			x = -5:5;
			y = 0.5:(w-0.5);

			[X,Y] = meshgrid(x,y);

			% Make a vector of possible coordinates for the cells to start in
			% and randomly sample n locations for the n cells
			pairs = [X(:),Y(:)];
			pairs = datasample(pairs, n, 1, 'Replace', false);

			rodLength = 0.5;

			for i = 1:n

				% pairs has the starting points, then pick a random angle
				% to choose the orientation of the rod
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
				
				ccm = LinearGrowthCellCycle(t0, tg, tg, f, obj.dt);
				ccm.stochasticGrowthStart = true;
				ccm.stochasticGrowthEnd = true;
				ccm.stochasticDivisionAge = true;
				ccm.SetRandomTrialDivisionCondition(@rand, d);

				c = RodCell(e,ccm,obj.GetNextCellId());
				c.newCellTargetArea = 0.5 * rodLength;
				c.grownCellTargetArea = rodLength;
				
				obj.cellList = [obj.cellList, c];

			end


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(CellCellInteractionForce(a, s, dAsym, dSep, dLim, obj.dt, false));

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

			pathName = sprintf('VolfsonExperiment/n%gr%gs%gtg%gd%gw%gf%gt0%gtm%gda%gds%gdl%ga%g_seed%g/',n, r, s, tg, d, w, f, t0, tm, dAsym,  dSep, dLim, a, seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));



		end
		
	end

end