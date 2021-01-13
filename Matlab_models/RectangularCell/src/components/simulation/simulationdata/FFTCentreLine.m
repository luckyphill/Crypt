classdef FFTCentreLine < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'fftCentreLine'
		data = [];

	end

	methods

		function obj = FFTCentreLine
			% No special initialisation
			
		end

		function CalculateData(obj, t)

			% Calculates the average y deviation from the starting position
			centreLine = t.simData('centreLine').GetData(t);

			% To do a FFT, we need the space steps to be even,
			% so we need to interpolate between points on the
			% centre line to get the additional points


			newPoints = [];

			dx = t.cellList(1).newCellTopLength / 10;

			% Discretise the centre line in steps of dx between the endpoints
			% This usually won't hit the exact end, but we don't care about a tiny piece at the end
			x = centreLine(1,1):dx:centreLine(end,1);
			y = zeros(size(x));

			j = 1;
			i = 1;
			while j < length(centreLine) && i <= length(x)

				cl = centreLine([j,j+1],:);
				
				% Finc the equation of the line segment in the centre line
				m = (cl(2,2) - cl(1,2)) / (cl(2,1) - cl(1,1));
				
				c = cl(1,2) - m * cl(1,1);

				f = @(x) m * x + c;

				% Step along this line and evaluate it at the x positions
				while i <= length(x) && x(i) < centreLine(j+1,1)

					y(i) = f(x(i));
					newPoints(i,:) = [x(i), y(i)];

					i = i + 1;
				end

				j = j + 1;

			end

			% Fourier transform analysis as taken from the matlab
			% help page
			Y = fft(y);

			L = ceil(- centreLine(1,1) + centreLine(end,1));
			P2 = abs(Y/L);
			P1 = P2(1:L/2+1);
			P1(2:end-1) = 2*P1(2:end-1);
			f = (0:(L/2))/(L/dx);


			obj.data = {f,P1,x,y};


		end
		
	end

end