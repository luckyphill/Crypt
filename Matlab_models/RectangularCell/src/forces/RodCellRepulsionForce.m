classdef RodCellRepulsionForce < AbstractNeighbourhoodBasedForce
	% Applies a force to push the angle of a cell corner towards its prefered value

	properties

		r
		dt

	end


	methods

		function obj = RodCellRepulsionForce(r, dt)

			% r is the radius in which we search for interactions
			% it will be 2x the searching radius of a single cell
			% assuming all cells are searching at the same distance
			obj.r = r;
			obj.dt = dt;
			% We need the time step size in order to properly
			% calculate the rotations, and produce their equivalent
			% force.

		end

		function AddNeighbourhoodBasedForces(obj, nodeList, p)

			% p is the space partition

			for i = 1:length(nodeList)
				n = nodeList(i);

				[elementList, nList] = p.GetNeighbouringNodesAndElements(n, obj.r);

				for j = 1:length(elementList)

					e = elementList(j);
					% fprintf('Node %d interacting with element %d\n', n.id,e.id);

					% Claculate distance between node and edge
					u = e.GetVector1to2();
					v = e.GetOutwardNormal();

					% Since we know the node is within the range of
					% the element, we can project a vector that we know
					% goes from the element to node onto the element system
					% of coordinates

					n1ton = n.position - e.Node1.position;
					d = dot(n1ton, v);

					% Encroaching amount
					dr = obj.r - abs(d);
					% dr = obj.r - d;

					% This gives us the quantity for the force calculation

					% We still need a point on the element to apply the force

					% Taking this dot product projects n1ton onto the element
					n1toA = u * dot(n1ton, u);

					% The force points towards the element
					% Fa = -v * sign(d) * atanh(dr/obj.r);
					Fa = -v * sign(d) * (  exp( (dr/obj.r)^2 ) - 1  );

					obj.ApplyForcesToNodeAndElement(n,e,Fa,n1toA);
					% fprintf('Magnitude of force applied = %.4f\n', norm(Fa));

				end

				% Now handle any node that we need to interact with
				for i = 1:length(nList)

					n1 = nList(i);
					% fprintf('Node %d interacting with node %d\n', n.id,n1.id);
					nton1 = n1.position - n.position;

					d = norm(nton1);

					v = nton1 / d;

					% Encroaching amount
					dr = obj.r - abs(d);
					% dr = obj.r - d;

					% v points at n1, so the resulting force
					% has a positive sense towards n1
					% hence to push the ndoes apart, the for is + ve
					% for n1 and -ve for n2
					% Fa = 10 * v * atanh(dr/obj.r);
					Fa = v * (  exp( (dr/obj.r)^2 ) - 1  );

					n.AddForceContribution(-Fa);
					n1.AddForceContribution(Fa);

				end

			end

		end

	end

end