classdef (Abstract) AbstractLineSimulation < AbstractCellSimulation

	% This type of simulation is a row of cells with two distinct ends

	properties

		wiggleRatio = 1;

		avgYDeviation
		alphaWrinkleParameter

		storeWiggleRatio = []
		
		leftBoundaryCell
		rightBoundaryCell

		storeAvgYDeviation = []
		storeAlphaWrinkleParameter = []

	end

	methods

		function UpdateAlphaWrinkleParameter(obj)

			% Calculates the alpha wrinkliness parameter from Dunn 2011 eqn 10

			r = 0;

			for i = 1:obj.GetNumCells()

				c = obj.cellList(i);

				dy = c.elementTop.Node1.y - c.elementTop.Node2.y;
				dx = c.elementTop.Node1.x - c.elementTop.Node2.x;

				r = r + abs(dy/dx);

			end

			obj.alphaWrinkleParameter = r / obj.GetNumCells();

		end

		function UpdateAverageYDeviation(obj)

			% Go through each cell along the top and calculate the average distance
			% from the x axis

			heightSum = abs(obj.cellList(1).nodeTopLeft.y) + abs(obj.cellList(1).nodeTopRight.y);

			for i = 2:obj.GetNumCells()

				heightSum = heightSum + abs(obj.cellList(i).nodeTopRight.y);

			end

			obj.avgYDeviation = heightSum / ( obj.GetNumCells() + 1 );

		end

		function UpdateCentreLine(obj)

			% Makes a sequence of points that defines the centre line of the cells
			cL = [];

			obj.UpdateBoundaryCells();

			c = obj.leftBoundaryCell;

			cL(end + 1, :) = c.elementLeft.GetMidPoint();
			e = c.elementRight;

			cL(end + 1, :) = e.GetMidPoint();

			% Jump through the cells until we hit the right most cell
			c = e.GetOtherCell(c);

			while ~isempty(c) 

				e = c.elementRight;
				cL(end + 1, :) = e.GetMidPoint();
				c = e.GetOtherCell(c);
			end

			obj.centreLine = cL;

		end

		function UpdateWiggleRatio(obj)

			obj.UpdateCentreLine();

			l = 0;

			for i = 1:length(obj.centreLine)-1
				l = l + norm(obj.centreLine(i,:) - obj.centreLine(i+1,:));
			end

			w = obj.centreLine(end,1) - obj.centreLine(1,1);

			obj.wiggleRatio = l / w;
		
		end

		function CentreLineFFT(obj)

			obj.UpdateCentreLine();

			% To do a FFT, we need the space steps to be even,
			% so we need to interpolate between points on the
			% centre line to get the additional points


			newPoints = [];

			dx = obj.cellList(1).newCellTopLength / 10;

			% Discretise the centre line in steps of dx between the endpoints
			% This usually won't hit the exact end, but we don't care about a tiny piece at the end
			x = obj.centreLine(1,1):dx:obj.centreLine(end,1);
			y = zeros(size(x));

			j = 1;
			i = 1;
			while j < length(obj.centreLine) && i <= length(x)

				cl = obj.centreLine([j,j+1],:);
					
				m = (cl(2,2) - cl(1,2)) / (cl(2,1) - cl(1,1));
				
				c = cl(1,2) - m * cl(1,1);


				f = @(x) m * x + c;

				while i <= length(x) && x(i) < obj.centreLine(j+1,1)

					y(i) = f(x(i));
					newPoints(i,:) = [x(i), y(i)];

					i = i + 1;
				end

				j = j + 1;


			end

			Y = fft(y);

			L = ceil(- obj.centreLine(1,1) + obj.centreLine(end,1));
			P2 = abs(Y/L);
			P1 = P2(1:L/2+1);
			P1(2:end-1) = 2*P1(2:end-1);

			f = (0:(L/2))/(L/dx);
			figure
			plot(f,P1)
			figure
			plot(x,y)

		end

		function UpdateBoundaryCells(obj)

			if isempty(obj.leftBoundaryCell)
				% Probably the first time this has been run,
				% so need to find the boundary cells first
				% This won't work in general, but will be the case most of the time at this point
				obj.leftBoundaryCell 	= obj.cellList(1);
				obj.rightBoundaryCell 	= obj.cellList(end);
			end



			while length(obj.leftBoundaryCell.elementLeft.cellList) > 1
				% The left element of the cell is part of at least two cells
				% So need to replace the leftBoundaryCell
				if obj.leftBoundaryCell == obj.leftBoundaryCell.elementLeft.cellList(1)
					obj.leftBoundaryCell = obj.leftBoundaryCell.elementLeft.cellList(2);
				else
					obj.leftBoundaryCell = obj.leftBoundaryCell.elementLeft.cellList(1);
				end

			end


			while length(obj.rightBoundaryCell.elementRight.cellList) > 1
				% The right element of the cell is part of at least two cells
				% So need to replace the rightBoundaryCell
				if obj.rightBoundaryCell == obj.rightBoundaryCell.elementRight.cellList(1)
					obj.rightBoundaryCell = obj.rightBoundaryCell.elementRight.cellList(2);
				else
					obj.rightBoundaryCell = obj.rightBoundaryCell.elementRight.cellList(1);
				end

			end

		end
	end


end