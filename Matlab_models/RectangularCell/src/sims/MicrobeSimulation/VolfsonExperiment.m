classdef VolfsonExperiment < FreeCellSimulation

	% This uses rod cells to reproduce the experiment by Volfson et al.
	% in which a population of E. coli cells are confined to a channel
	% 30um x 500um x 1um. The height of the channel forces the cells to grow as
	% monlayer, since the cells have a thickness about 1 um.
	% To replicate this, we choose a preferred separation of 1um
	% meaning the rod cells will be measured 1um apart by their centre line (the edge)
	% in other words, the boundary of the cell will be 0.5um either side of the rod
	% The cells are stated to have a maximum aspect ratio of 5, so this determines the
	% rod length

	properties

		% None yet...

	end

	methods

		function obj = VolfsonExperiment(n, l, r, s, tg, d, w, seed)

			% n is the number of cells to seed the experiment with
			% l is the length of the cell. This includes the radius around the
			% end points, so the rod length will l - dSep
			% r is the rod growing force
			% s is the force pushing cells apart to their preferred distance
			% tg is the time to grow from new cell to full size
			% d division threshold for the Bernoulli trial
			% w is the width of the channel - the centre line will be y=0, so xmax = +/- w/2
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
			dSep = 1;%0.2;
			dLim = dSep;

			% Rod attraction force (irrelevant unless dLim > dSep)
			a = 0;

			obj.SetRNGSeed(seed);

			% Make a grid of starting points
			% we make them in steps of 2l to prevent cells overlapping
			% in the initialisation stage
			x = -80:l:80;
			y = -(w/2):l:(w/2);
			% x = -5:5;
			% y = 0.5:(w-0.5);

			[X,Y] = meshgrid(x,y);

			% Make a vector of possible coordinates for the cells to start in
			% and randomly sample n locations for the n cells
			pairs = [X(:),Y(:)];
			pairs = datasample(pairs, n, 1, 'Replace', false);

			% The rod length will need to be l - dSep
			% since the node interaction will effectively introduce
			% an extra 0.5um at each end
			rodLength = l - dSep;

			for i = 1:n

				% pairs has the starting points, then pick a random angle
				% to choose the orientation of the rod
				theta = 2*pi*rand;

				x1 = pairs(i,1);
				y1 = pairs(i,2);

				x2 = x1 + 0.5*rodLength*cos(theta); % Factor of 1 half because new cells are half the full length
				y2 = y1 + 0.5*rodLength*sin(theta);

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
				
				ccm.preGrowthColour = ccm.colourSet.GetNumber('ECOLI');
				ccm.growthColour = ccm.colourSet.GetNumber('ECOLI');
				ccm.postGrowthColour = ccm.colourSet.GetNumber('ECOLI');
				ccm.inhibitedColour = ccm.colourSet.GetNumber('ECOLISTOPPED');

				c = RodCell(e,ccm,obj.GetNextCellId());
				c.newCellTargetArea = 0.5 * rodLength;
				c.grownCellTargetArea = rodLength;
				
				obj.cellList = [obj.cellList, c];

			end


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(CellCellInteractionForce(a, s, dAsym, dSep, dLim, obj.dt, false));

			% A force to keep the rod cell at its preferred length
			obj.AddCellBasedForce(RodCellGrowthForce(r));

			obj.AddSimulationModifier(HorizontalChannel(-w/2, w/2));
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(2, 2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			pathName = sprintf('VolfsonExperiment/n%gl%gr%gs%gtg%gd%gw%gf%gt0%gtm%gda%gds%gdl%ga%g_seed%g/',n, l, r, s, tg, d, w, f, t0, tm, dAsym,  dSep, dLim, a, seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));



		end
		
	end

end