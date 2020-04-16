classdef CornerForceCouple < AbstractCellBasedForce
	% Applies a force to push the angle of a cell corner towards its prefered value


	properties

		cornerSpringRate

		preferedAngle

	end

	methods

		function obj = CornerForceCouple(cornerP, angleP)

			obj.cornerSpringRate = cornerP;
			obj.preferedAngle = angleP;
		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.AddCouples(c);

			end

		end

		function AddCouples(obj, c)

			% Each corner has a preferred angle (usually pi/2), and any deviation from that produces a force couple
			% that rotates the elements back towards their preferred angle


			[angleTopLeft, angleBottomRight, angleBottomLeft, angleTopRight] 	= obj.GetCornerAngles(c);

			% The vectors calculated below assume that we are traversing the corners in a clockwise fashion
			[vectorTop, vectorBottom, vectorLeft, vectorRight] 					= obj.GetElementNormalVectors(c);


			% Cubed power will keep the sign correct. If this changes to an even power need to be careful
			torqueTopLeft = 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopLeft);
			torqueTopRight = 	obj.cornerSpringRate * ( obj.preferedAngle - angleTopRight);
			torqueBottomLeft = 	obj.cornerSpringRate * ( obj.preferedAngle - angleBottomLeft);
			torqueBottomRight = obj.cornerSpringRate * ( obj.preferedAngle - angleBottomRight);

			% Forces due to top left angle
			c.nodeBottomLeft.AddForceContribution(  torqueTopLeft * vectorLeft  / c.elementLeft.GetLength() );
			c.nodeTopLeft.AddForceContribution(    -torqueTopLeft * vectorLeft  / c.elementLeft.GetLength() );

			c.nodeTopLeft.AddForceContribution(    -torqueTopLeft * vectorTop   / c.elementTop.GetLength() );
			c.nodeTopRight.AddForceContribution(    torqueTopLeft * vectorTop   / c.elementTop.GetLength() );

			% Forces due to top right angle
			c.nodeTopLeft.AddForceContribution(     torqueTopRight * vectorTop  / c.elementTop.GetLength() );
			c.nodeTopRight.AddForceContribution(   -torqueTopRight * vectorTop  / c.elementTop.GetLength() );
			
			c.nodeTopRight.AddForceContribution(   -torqueTopRight * vectorRight / c.elementRight.GetLength() );
			c.nodeBottomRight.AddForceContribution( torqueTopRight * vectorRight / c.elementRight.GetLength() );

			% Forces due to bottom right angle
			c.nodeTopRight.AddForceContribution(    torqueBottomRight * vectorRight  / c.elementRight.GetLength() );
			c.nodeBottomRight.AddForceContribution(-torqueBottomRight * vectorRight  / c.elementRight.GetLength() );
			
			c.nodeBottomRight.AddForceContribution(-torqueBottomRight * vectorBottom / c.elementBottom.GetLength() );
			c.nodeBottomLeft.AddForceContribution(  torqueBottomRight * vectorBottom / c.elementBottom.GetLength() );

			% Forces due to bottom left angle
			c.nodeBottomRight.AddForceContribution( torqueBottomLeft * vectorBottom  / c.elementBottom.GetLength() );
			c.nodeBottomLeft.AddForceContribution( -torqueBottomLeft * vectorBottom  / c.elementBottom.GetLength() );
			
			c.nodeBottomLeft.AddForceContribution( -torqueBottomLeft * vectorLeft / c.elementLeft.GetLength() );
			c.nodeTopLeft.AddForceContribution(     torqueBottomLeft * vectorLeft / c.elementLeft.GetLength() );

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

		function [nvt, nvb, nvl, nvr] = GetElementNormalVectors(obj, c)

			% This returns vectors normal to the element axis that in a force couple will
			% produce anti-clockwise rotation if applied to the starting node

			vt = c.nodeTopRight.position - c.nodeTopLeft.position;
			vr = c.nodeBottomRight.position - c.nodeTopRight.position;
			vl = c.nodeTopLeft.position - c.nodeBottomLeft.position;
			vb = c.nodeBottomLeft.position - c.nodeBottomRight.position;

			nvt = -[vt(2), -vt(1)];
			nvr = -[vr(2), -vr(1)];
			nvl = -[vl(2), -vl(1)];
			nvb = -[vb(2), -vb(1)];
			
			nvt = nvt / norm(nvt);
			nvr = nvr / norm(nvr);
			nvl = nvl / norm(nvl);
			nvb = nvb / norm(nvb);

		end



	end



end