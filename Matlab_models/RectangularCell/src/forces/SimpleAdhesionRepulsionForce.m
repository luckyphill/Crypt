classdef SimpleAdhesionRepulsionForce < AbstractNodeElementForce

	% This force is intended to keep the epithelial layer attached to
	% the membrane, so it doesn't allow detatchment. The force law is
	% linear, and puts the resting position at r

	properties

		springRate

	end

	methods
		
		function obj = SimpleAdhesionRepulsionForce(r, s,dt)

			% r is the resting separation. Adhesion attraction starts
			% at 2r and is 0 at r. The repulsion
			% force increases between r and -r
			obj.r = r;
			obj.dt = dt;
			obj.springRate = s;
			% We need the time step size in order to properly
			% calculate the rotations, and produce their equivalent
			% force.

		end

		function AddNeighbourhoodBasedForces(obj, nodeList, p)

			% p is the space partition

			for i = 1:length(nodeList)
				n = nodeList(i);
				elementList = p.GetNeighbouringElements(n, 2 * obj.r);
				nList = [];
				% [elementList, nList] = p.GetNeighbouringNodesAndElements(n, 2 * obj.r);

				for j = 1:length(elementList)
					e = elementList(j);

					% Calculate distance between node and edge
					u = e.GetVector1to2();
					v = e.GetOutwardNormal();

					% Since we know the node is within the range of
					% the element, we can project a vector that we know
					% goes from the element to node onto the element system
					% of coordinates

					n1ton = n.position - e.Node1.position;
					d = dot(n1ton, v);

					% Taking this dot product projects n1ton onto the element
					% Here, A is the point on the element perpendicular to the node
					n1toA = u * dot(n1ton, u);

					% The goal is to have the resting separation at r apart
					% The force points towards the element
					Fa = obj.springRate * v * (d - obj.r);

					obj.ApplyForcesToNodeAndElement(n,e,Fa,n1toA);

				end

				% Now handle any node that we need to interact with
				for i = 1:length(nList)

					n1 = nList(i);

					n1ton = n.position - n1.position;

					% Need to decide if the node is inside or outside the
					% cell because there is no way to orient a point
					inside = false;
					for j = 1:length(n1.cellList)
						if n1.cellList(j).IsNodeInsideCell(n);
							inside = true;
							break;
						end
					end

					% d is always +ve
					d = norm(n1ton);

					if inside
						% +ve sense is outside, -ve sense is inside
						d = -d;
					end

					v = n1ton / d;


					% v points from n1 to n, so the resulting force
					% has a positive sense towards n
					% To pull together, n1 has +ve v and n has -ve v
					% to push apart, n1 has -ve v and n has +ve v
					Fa = obj.springRate * v * (d - obj.r);

					n.AddForceContribution(-Fa);
					n1.AddForceContribution(Fa);

				end

			end

		end

	end

end