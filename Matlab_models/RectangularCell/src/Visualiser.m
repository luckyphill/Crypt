classdef Visualiser < matlab.mixin.SetGet
	% Stores the wiggle ratio

	properties

		pathToSpatialState
		nodes
		elements
		cells

		timeSteps

		cs = ColourSet()
		
	end

	methods

		function obj = Visualiser(ptss)

			obj.pathToSpatialState = ['/Users/phillip/Research/Crypt/Data/Matlab/SimulationOutput/',ptss];


			obj.LoadData();

			obj.RunVisualiserGUI();

		end

		function LoadData(obj)

			% For some reason matlab decides to ignore some lines
			% when using readmatrix, so to stop this, pass in the following options
			% See https://stackoverflow.com/questions/62399666/why-does-readmatrix-in-matlab-skip-the-first-n-lines?
			opts = detectImportOptions([obj.pathToSpatialState, 'nodes.csv']);
			opts.DataLines = [1 Inf];
			if strcmp(opts.VariableTypes{1}, 'char')
				opts = setvartype(opts, opts.VariableNames{1}, 'double');
			end
			nodeData = readmatrix([obj.pathToSpatialState, 'nodes.csv'],opts);

			opts = detectImportOptions([obj.pathToSpatialState, 'elements.csv']);
			opts.DataLines = [1 Inf];
			if strcmp(opts.VariableTypes{1}, 'char')
				opts = setvartype(opts, opts.VariableNames{1}, 'double');
			end
			elementData = readmatrix([obj.pathToSpatialState, 'elements.csv'],opts);

			opts = detectImportOptions([obj.pathToSpatialState, 'cells.csv']);
			opts.DataLines = [1 Inf];
			if strcmp(opts.VariableTypes{1}, 'char')
				opts = setvartype(opts, opts.VariableNames{1}, 'double');
			end
			cellData = readmatrix([obj.pathToSpatialState, 'cells.csv'],opts);
			% cellData = csvread([obj.pathToSpatialState, 'cells.csv']);

			obj.timeSteps = nodeData(:,1);
			nodeData = nodeData(:,2:end);
			elementData = elementData(:,2:end);
			cellData = cellData(:,2:end);

			[m,~] = size(nodeData);

			% Need to get the max ID
			allIDS = nodeData(:,1:3:end);
			maxID = max(max(allIDS));

			nodes = nan(maxID,m,2);

			for i = 1:m
				nD  = nodeData(i,:);
				nD = reshape(nD,3,[])';
				% First column is ID, then x and y
				
				% For each node, use the id as the first index,
				% and the second index is the time step. In that
				% position is stored the (x,y) coords
				for j = 1:length(nD)
					n = nD(j,:);
					if ~isnan(n(1))
						nodes(n(1),i,:) = [n(2), n(3)];
					end

				end

			end

			% This 3D array gives the (x,y) position of each node at each point in time
			% First dimension, id, second dimension, time, third dimension position data
			obj.nodes = nodes;

			% Now make an array the cells and elements
			% First dimension, time, second dimension, cell or element, third dimension, node id
			% so to get the nodes for a given time,t, and a given cell, c, it's accessed
			% cellData(t,c,:)
			obj.elements = permute(reshape(elementData,m,2,[]),[1,3,2]);
			% obj.cells = permute(reshape(cellData,m,obj.nEntriesCell,[]),[1,3,2]);
			
			
			% Each row in the matrix lists the nodes for each cell. The first number is the number
			% of nodes in the cell, call it jump, then the nodes for the cell are listed, followed by
			% the cell colour
			[m,~] = size(cellData);
			cells = {};
			for i = 1:m
				a = cellData(i,:);
				j = 1;
				counter = 1;
				while j <= length(a) && ~isnan(a(j))
					jump = a(j);
					cells{i,counter} = a(j+1:j+jump+1);
					j = j + jump + 2;
					counter = counter + 1;
				end

			end

			obj.cells = cells;

		end

		function RunVisualiserGUI(obj)

			% This will take the formatted data and produce an interactive
			% plot of the simulation. At the minute it just runs a for loop

			% Components:
			% Play/Pause button
			% Speed control (how long between each frame)
			% Slide bar to choose position
			% Time stamp in a corner (maybe title)
			% Reload data button

			% The number of values in a row that correspond to
			% one cell

			h = figure();
			axis equal
			hold on

			[I,~] = size(obj.cells);

			% Initialise the array with anything
			fillObjects(1) = fill([1,1],[2,2],'r');

			for i = 1:I
				% i is the time steps
				[~,J] = size(obj.cells);
				j = 1;
				while j <= J && ~isempty(obj.cells{i,j})

					c = obj.cells{i,j};
					ids = c(1:end-1);
					colour = c(end);
					nodeCoords = squeeze(obj.nodes(ids,i,:));

					x = nodeCoords(:,1);
					y = nodeCoords(:,2);

					if j > length(fillObjects)
						fillObjects(j) = fill(x,y,obj.cs.GetRGB(colour));
					else
						fillObjects(j).XData = x;
						fillObjects(j).YData = y;
						fillObjects(j).FaceColor = obj.cs.GetRGB(colour);
					end

					j = j + 1;

				end
				% j will always end up being 1 more than the total number of non empty cells

				for k = length(fillObjects):-1:j
					fillObjects(k).delete;
					fillObjects(k) = [];
				end

				drawnow
				title(sprintf('t = %g',obj.timeSteps(i)),'Interpreter', 'latex');
				pause(0.1);

			end

		end

	end


end