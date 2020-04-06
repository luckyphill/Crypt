classdef CornerForceFletcher < AbstractCellBasedForce
	% Applies a force to push the angle of a cell corner towards its prefered value


	properties

		cornerSpringRate

		preferedAngle

	end

	methods

		function obj = CornerForceFletcher(cornerP, angleP)

			obj.cornerSpringRate = cornerP;
			obj.preferedAngle = angleP;
		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.AddCornerForces(c);

			end

		end

		function AddCornerForces(obj, c)

			% Each element has a gradient according to NagaiHonda force that is used for calculating the contribution from adhesion
			% The gradient is the opposite sign at each node, so need to take care to make sure the sign is correct
			% for each node when the force is actually applied. To this end, we will always have the vector pointing from Node1 to Node2
			% This force always wants to shrink the element, so pushes the nodes together along the element's vector


			[angleTopLeft, angleBottomRight, angleBottomLeft, angleTopRight] 		= obj.GetCornerAngles(c);
			[vectorTopLeft, vectorBottomRight, vectorBottomLeft, vectorTopRight] 	= obj.GetCornerVectors(c);

			c.nodeTopLeft.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopLeft)^3 		* vectorTopLeft );
			c.nodeTopRight.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopRight)^3 		* vectorTopRight );
			c.nodeBottomLeft.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleBottomLeft)^3 	* vectorBottomLeft );
			c.nodeBottomRight.AddForceContribution( obj.cornerSpringRate * ( obj.preferedAngle - angleBottomRight)^3 	* vectorBottomRight );

		end


		function [atl, abr, abl, atr] = GetCornerAngles(obj, c)

			ntl = c.nodeTopLeft.position;
			ntr = c.nodeTopRight.position;
			nbl = c.nodeBottomLeft.position;
			nbr = c.nodeBottomRight.position;

			atl = acos(  dot(ntr - ntl, nbl - ntl) / ( norm(ntr - ntl) * norm( nbl - ntl) )  );
			atr = acos(  dot(ntl - ntr, nbr - ntr) / ( norm(ntl - ntr) * norm( nbr - ntr) )  );
			abl = acos(  dot(ntl - nbl, nbr - nbl) / ( norm(ntl - nbl) * norm( nbr - nbl) )  );
			abr = acos(  dot(ntr - nbr, nbl - nbr) / ( norm(ntr - nbr) * norm( nbl - nbr) )  );


		end

		function [vtl, vbr, vbl, vtr] = GetCornerVectors(obj, c)

			ntl = c.nodeTopLeft.position;
			ntr = c.nodeTopRight.position;
			nbl = c.nodeBottomLeft.position;
			nbr = c.nodeBottomRight.position;


			vtl = (ntr - ntl) / norm(ntr - ntl)  +  (nbl - ntl) / norm(nbl - ntl) ;
			vtr = (ntl - ntr) / norm(ntl - ntr)  +  (nbr - ntr) / norm(nbr - ntr) ;
			vbl = (ntl - nbl) / norm(ntl - nbl)  +  (nbr - nbl) / norm(nbr - nbl) ;
			vbr = (ntr - nbr) / norm(ntr - nbr)  +  (nbl - nbr) / norm(nbl - nbr) ;

			vtl = vtl / norm(vtl);
			vtr = vtr / norm(vtr);
			vbl = vbl / norm(vbl);
			vbr = vbr / norm(vbr);

		end



	end



end