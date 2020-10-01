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

			% Each corner has a preferred angle (usually pi/2), and any deviation from that produces a force
			% bisecting the angle in to the cell. This follows the work in Fletcher et al 2013


			[angleTopLeft, angleBottomRight, angleBottomLeft, angleTopRight] 		= obj.GetCornerAngles(c);
			[vectorTopLeft, vectorBottomRight, vectorBottomLeft, vectorTopRight] 	= obj.GetCornerVectors(c);

			c.nodeTopLeft.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopLeft)^3 		* vectorTopLeft );
			c.nodeTopRight.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopRight)^3 		* vectorTopRight );
			c.nodeBottomLeft.AddForceContribution( 	obj.cornerSpringRate * ( obj.preferedAngle - angleBottomLeft)^3 	* vectorBottomLeft );
			c.nodeBottomRight.AddForceContribution( obj.cornerSpringRate * ( obj.preferedAngle - angleBottomRight)^3 	* vectorBottomRight );

		end


		function [atl, abr, abl, atr] = GetCornerAngles(obj, c)

			% Calculate the angles at each corner
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

			% Finding a unit vector that bisects the angle two elements make
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