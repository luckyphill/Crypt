classdef DifferentialAdhesionForce < AbstractNodeElementForce

	% This force joins cells together with different strenghts depending
	% on their type.
	% The attraction force uses one spring type topull them together,
	% and the repulsion force uses another, hence the attraction and repulsion
	% spring constants are different

	properties

		repulsion
		attraction1
		attraction2

	end

	methods
		
		function obj = DifferentialAdhesionForce(r, repulsion, attraction1, attraction2, dt)

			% r is the resting separation. Adhesion attraction starts
			% at 2r and is 0 at r. The repulsion
			% force increases between r and -r
			obj.r = r;
			obj.dt = dt;
			obj.repulsion = repulsion;
			obj.attraction1 = attraction1; % Attraction1 is for cells of the same type
			obj.attraction2 = attraction2; % Attraction2 is for cell of different types
			% We need the time step size in order to properly
			% calculate the rotations, and produce their equivalent
			% force.

		end

		function AddNeighbourhoodBasedForces(obj, nodeList, p)

			% p is the space partition

			press = 1.2; % Store the variable for the force law here temporarily
			for i = 1:length(nodeList)
				n = nodeList(i);
				% elementList = p.GetNeighbouringElements(n, 2 * obj.r);
				[elementList, nList] = p.GetNeighbouringNodesAndElements(n, 3 * obj.r);

				for j = 1:length(elementList)
					e = elementList(j);

					if e.cellList.id ~= n.cellList.id
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

						% Default is same to same
						attraction = obj.attraction1;
						if n.cellList.cellType ~= e.cellList.cellType
							attraction = obj.attraction2;
						end

						% The goal is to have the resting separation at r apart
						% The force points towards the element
						if d - obj.r > 0
							% Attraction dependent on type
							Fa = attraction * d * v * exp(-press * d/obj.r);
						else
							% Repulsion
							Fa = obj.repulsion * v * (d - obj.r);
						end

						obj.ApplyForcesToNodeAndElement(n,e,Fa,n1toA);

					end

				end

				% Now handle any node that we need to interact with
				for i = 1:length(nList)

					n1 = nList(i);

					if n1.cellList.id ~= n.cellList.id
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

						% Default is same to same
						attraction = obj.attraction1;
						if n.cellList.cellType ~= n1.cellList.cellType
							attraction = obj.attraction2;
						end

						% v points from n1 to n, so the resulting force
						% has a positive sense towards n
						% To pull together, n1 has +ve v and n has -ve v
						% to push apart, n1 has -ve v and n has +ve v

						if d - obj.r > 0
							% Attraction dependent on type
							Fa = attraction * d * v * exp(-press * d/obj.r);
						else
							% Repulsion
							Fa = obj.repulsion * v * (d - obj.r);
						end

						n.AddForceContribution(-Fa);
						n1.AddForceContribution(Fa);

					end
					

				end

			end

		end

	end

end