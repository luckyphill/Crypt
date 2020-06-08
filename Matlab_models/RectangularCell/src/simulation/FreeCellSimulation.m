classdef FreeCellSimulation < AbstractCellSimulation

	% This uses free cells, i.e. cells that never share
	% elemetns or node with other cells

	properties

		dt = 0.005
		t = 0
		step = 0

	end

	methods

		function obj  = FreeCellSimulation()

			% Special initialisation when I work out what it needs
		end
		
	end

end