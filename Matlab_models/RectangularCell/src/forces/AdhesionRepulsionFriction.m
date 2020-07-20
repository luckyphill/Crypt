classdef AdhesionRepulsionFriction < AbstractNodeElementForce

	% This force has a linear adhesion/repulsion force
	% for movement normal to an edge, and a friction force
	% for movement parallel to the edge when close enough

	properties

		springRate
		frictionRate

	end

	methods
		
		function obj = AdhesionRepulsionFriction(r, s, f, dt)

			% r is the resting separation. Adhesion attraction starts
			% at 2r and is 0 at r. The repulsion
			% force increases between r and -r
			obj.r = r;
			obj.dt = dt;
			obj.springRate = s;
			obj.frictionRate = f;
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

					% Now that all of the forces have been applied (NOTE: if there are still
					% some forces added after this point in ANY part of the simulation, then
					% this will not work), we can introduce friction transfer between node and
					% element

					Fn = n.force;
					Fe1 = e.Node1.force;
					Fe2 = e.Node2.force;

					Fnp = u * dot(Fn,u);
					Fe1p = u * dot(Fe1,u);
					Fe2p = u * dot(Fe2,u);

					e.Node1.AddForceContribution(-obj.frictionRate*Fnp);
					e.Node2.AddForceContribution(-obj.frictionRate*Fnp);

					% x is the position along the length of the edge where the
					% node is found
					x = dot(n1ton, u);
					l = e.GetLength();

					FeOnn = (Fe2p - Fe1p) *  x/l + Fe1p;

					n.AddForceContribution(-obj.frictionRate * FeOnn);


				end

				
			end

		end

	end

end