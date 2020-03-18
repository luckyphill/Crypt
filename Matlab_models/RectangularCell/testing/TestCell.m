classdef TestCell < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n1,n3,2);
			e3 = Element(n2,n4,3);
			e4 = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(e2, e4, e3, e1, 1);


			

		end

	end

end