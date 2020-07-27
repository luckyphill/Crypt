classdef StromaAdhesionForce < AbstractNodeElementForce

	% This force is intended to keep the epithelial layer attached to
	% the bulk stroma

	properties

		springRate

	end

	methods
		
		function obj = StromaAdhesionForce(r, s,dt)

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
					if (e.cellList.cellType == 1 &&  d - obj.r <= 0) || e.cellList.cellType == 2
						Fa = obj.springRate * v * (d - obj.r);
					else
						Fa = [0,0];
					end


					obj.ApplyForcesToNodeAndElement(n,e,Fa,n1toA);


				end

			end

		end

	end

end