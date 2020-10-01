classdef RandomMotionForce < AbstractCellBasedForce
	% Randomly moves cells. Each node in a cell experiences to same
	% force, hence this is like a body force


	properties

		% The magnitude of the random movements
		dt
		magnitude

	end

	methods


		function obj = RandomMotionForce(magnitude, dt)

			obj.dt = dt;
			obj.magnitude = magnitude;

		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.ApplySpringForce(c);

			end

		end


		function ApplySpringForce(obj, c)

			% Generates a random direction force and applies it to the entire cell
			% The magnitude of the force is the same a in Osborne et al 2017 pp. 10
			theta = rand * 2 * pi;
			F = sqrt(2*obj.magnitude / obj.dt) * [cos(theta), sin(theta)] * normrnd(0,0.5);

			for i = 1:length(c.nodeList)

				n = c.nodeList(i);
				n.AddForceContribution(F);

			end

		end

	end



end