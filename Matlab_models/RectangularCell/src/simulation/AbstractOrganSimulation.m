classdef (Abstract) AbstractOrganSimulation < matlab.mixin.SetGet
	% A parent class that contains all the functions for running a simulation
	% with a collection of tissues. Each tissue can have it's own force calculations
	% but interaction between tissues will be handled here

	properties

		tissueList AbstractTissue
		nextTissueId = 1

		organBasedForces AbstractOrganBasedForce

		organLevelKillers AbstractOrganLevelCellKiller


		seed

		stopped = false
		stoppingConditions AbstractStoppingCondition
	
		simulationModifiers AbstractSimulationModifier

		% A collection of objects that store data over multiple time steps
		% with also the potential to write to file
		dataStores AbstractDataStore

		dataWriters AbstractDataWriter

		% A collection of objects for calculating data about the simulation
		% stored in a map container so each type of data can be given a
		% meaingful name
		simData = containers.Map;

		partition SpacePartition;

		usingBoxes = true;

		writeToFile = true;

		stochasticJiggle = true
		
	end

	properties (Abstract)

		dt
		t
		step

	end

	methods

		% Organ methods

		function AddOrganBasedForce(obj, f)

			if isempty(obj.organBasedForces)
				obj.organBasedForces = f;
			else
				obj.organBasedForces(end + 1) = f;
			end

		end

		function AddOrganLevelKiller(obj, k)

			if isempty(obj.organLevelKillers)
				obj.organLevelKillers = k;
			else
				obj.organLevelKillers(end + 1) = k;
			end

		end

		function KillCells(obj)

			% Loop through the cell killers

			for i = 1:length(obj.organLevelKillers)
				obj.organLevelKillers(i).KillCells(obj);
			end

		end

		% Simulation methods

		function SetRNGSeed(obj, seed)

			obj.seed = seed;
			rng(seed);

		end

		function NextTimeStep(obj)
			
			% First do the things to advance the simulation
			obj.Movement();

			obj.Growth();

			obj.Death();

			% Make any specific changes, i.e. boundary conditions
			obj.Modify();

			obj.AdvanceAge();

			obj.CollateData();

			if obj.IsStoppingConditionMet()
				obj.stopped = true;
			end

		end

		function NTimeSteps(obj, n)
			% Advances a set number of time steps
			
			for i = 1:n
				% Do all the calculations
				obj.NextTimeStep();

				if mod(obj.step, 1000) == 0
					fprintf('Time = %3.3fhr\n',obj.t);
				end

				if obj.stopped
					fprintf('Stopping condition met at t=%3.3f\n', obj.t);
					break;
				end

			end
			
		end

		function RunToTime(obj, t)

			% Given a time, run the simulation until we reach said time
			if t > obj.t
				n = ceil((t-obj.t) / obj.dt);
				NTimeSteps(obj, n);
			end

		end

		function Movement(obj)

			% Function related to movement

			obj.GenerateForcesInTissues();
			obj.GenerateNeighbourhoodBasedForces();
			obj.GenerateOrganBasedForces();

			obj.MakeNodesMove();

		end

		function Growth(obj)

			% Cells or other tissue components divide or
			% increase their number here

			newNodes 	= Node.empty();
			newElements = Element.empty();
			
			removedNodes 	= Node.empty();
			removedElements = Element.empty();
			

			for i = 1:length(obj.tissueList)
				
				[newNodeList, newElementList, removedNodeList, removedElementList] = obj.tissueList(i).TissueGrowth(obj);
				
				newNodes = [newNodes, newNodeList];
				newElements = [newElements, newElementList];
				
				removedNodes = [removedNodes, removedNodeList];
				removedElements = [removedElements, removedElementList];

			end

			obj.AddComponents(newNodes, newElements);
			obj.DeleteComponents(removeNodes, removeElements);

		end

		function Death(obj)

			% Cells or other tissue components are
			% removed from the simulation here

			newNodes 	= Node.empty();
			newElements = Element.empty();
			
			removedNodes 	= Node.empty();
			removedElements = Element.empty();
			

			for i = 1:length(obj.tissueList)
				
				[newNodeList, newElementList, removedNodeList, removedElementList] = obj.tissueList(i).TissueDeath(obj);
				
				newNodes = [newNodes, newNodeList];
				newElements = [newElements, newElementList];
				
				removedNodes = [removedNodes, removedNodeList];
				removedElements = [removedElements, removedElementList];

			end

			obj.AddComponents(newNodes, newElements);
			obj.DeleteComponents(removeNodes, removeElements);

		end

		function AdvanceAge(obj)

			obj.t = obj.t + obj.dt;
			obj.step = obj.step + 1;

			for i = 1:length(obj.tissueList)
				obj.tissueList(i).AdvanceAge(obj.dt);
			end

		end

		function CollateData(obj)

			% All the processing to track and write data
			obj.StoreData();
			
			if obj.writeToFile
				obj.WriteData();
			end

		end

		function GenerateOrganBasedForces(obj)
			
			for i = 1:length(obj.organBasedForces)
				obj.organBasedForces(i).AddOrganBasedForces(obj);
			end

		end

		function GenerateNeighbourhoodBasedForces(obj)
			
			if isempty(obj.partition)
				error('AOS:NoBoxes','Space partition required for NeighbourhoodForces, but none set');
			end

			for i = 1:length(obj.neighbourhoodBasedForces)
				obj.neighbourhoodBasedForces(i).AddNeighbourhoodBasedForces(obj.nodeList, obj.partition);
			end

		end

		function GenerateForcesInTissues(obj)
			
			for i = 1:length(obj.tissueList)
				obj.tissueList(i).GenerateForces(obj);
			end

		end

		function MakeNodesMove(obj)

			for i = 1:length(obj.nodeList)
				
				n = obj.nodeList(i);

				eta = n.eta;
				force = n.force;
				if obj.stochasticJiggle
					% Add in a tiny amount of stochasticity to the force calculation
					% to nudge it out of unstable equilibria

					% Make a random direction vector
					v = [rand-0.5,rand-0.5];
					v = v/norm(v);

					% Add the random vector, and make sure it is orders of magnitude
					% smaller than the actual force
					force = force + v * norm(force) / 10000;

				end

				newPosition = n.position + obj.dt/eta * force;

				n.MoveNode(newPosition);

				if obj.usingBoxes
					obj.partition.UpdateBoxForNode(n);
				end
			end

		end

		function AddComponents(obj, newNodes, newElements)

			% Add components to the space partition


		end

		function DeleteComponents(obj, removeNodes, removeElements)

			% Delete components from the space partition

		end

		function AdjustNodePosition(obj, n, newPos)

			% Only used by modifiers. Do not use to
			% progress the simulation

			% This will move a node to a given position regardless
			% of forces, but after all force movement has happened

			% Previous position and previous force are not modified

			% Make sure the node and elements are in the correct boxes
			n.AdjustPosition(newPos);
			if obj.usingBoxes
				obj.partition.UpdateBoxForNodeAdjusted(n);
			end

		end

		function AddStoppingCondition(obj, s)

			if isempty(obj.stoppingConditions)
				obj.stoppingConditions = s;
			else
				obj.stoppingConditions(end + 1) = s;
			end

		end

		function AddSimulationModifier(obj, m)

			if isempty(obj.simulationModifiers)
				obj.simulationModifiers = m;
			else
				obj.simulationModifiers(end + 1) = m;
			end

		end

		function AddDataStore(obj, d)

			if isempty(obj.dataStores)
				obj.dataStores = d;
			else
				obj.dataStores(end + 1) = d;
			end

		end

		function AddDataWriter(obj, w)

			if isempty(obj.dataWriters)
				obj.dataWriters = w;
			else
				obj.dataWriters(end + 1) = w;
			end

		end

		function AddSimulationData(obj, d)

			% Add the simulation data calculator to the map
			% this will necessarily allow only one instance
			% of a given type of SimulationData, since the 
			% names are immutable

			% This is calculate-on-demand, so it does not have
			% an associated 'use' method here
			obj.simData(d.name) = d;

		end

		function StoreData(obj)

			for i = 1:length(obj.dataStores)
				obj.dataStores(i).StoreData(obj);
			end

		end

		function WriteData(obj)

			for i = 1:length(obj.dataWriters)
				obj.dataWriters(i).WriteData(obj);
			end

		end

		function ModifySimulationState(obj)

			for i = 1:length(obj.simulationModifiers)
				obj.simulationModifiers(i).ModifySimulation(obj);
			end

		end

		function stopped = IsStoppingConditionMet(obj)

			stopped = false;
			for i = 1:length(obj.stoppingConditions)
				if obj.stoppingConditions(i).CheckStoppingCondition(obj)
					stopped = true;
					break;
				end
			end

		end

		% Visulaisation methods

		function Visualise(obj, varargin)

			h = figure();
			hold on

			% Intitialise the vector
			fillObjects(length(obj.cellList)) = fill([1,1],[2,2],'r');

			for i = 1:length(obj.cellList)
				c = obj.cellList(i);

				x = [c.nodeList.x];
				y = [c.nodeList.y];	

				fillObjects(i) = fill(x,y,c.GetColour());
			end

			axis equal

			if ~isempty(varargin)
				cL = obj.simData('centreLine').GetData(obj);
				plot(cL(:,1), cL(:,2), 'k');
			end

		end

		function VisualiseWireFrame(obj, varargin)

			% plot a line for each element

			h = figure();
			hold on
			for i = 1:length(obj.elementList)

				x1 = obj.elementList(i).Node1.x;
				x2 = obj.elementList(i).Node2.x;
				x = [x1,x2];
				y1 = obj.elementList(i).Node1.y;
				y2 = obj.elementList(i).Node2.y;
				y = [y1,y2];

				line(x,y)
			end

			axis equal

			if ~isempty(varargin)
				cL = obj.simData('centreLine').GetData(obj);
				plot(cL(:,1), cL(:,2), 'k');
			end

		end

		function VisualiseWireFramePrevious(obj, varargin)

			% plot a line for each element

			h = figure();
			hold on
			for i = 1:length(obj.elementList)

				if ~isempty(obj.elementList(i).Node1.previousPosition) && ~isempty(obj.elementList(i).Node2.previousPosition)
					x1 = obj.elementList(i).Node1.previousPosition(1);
					x2 = obj.elementList(i).Node2.previousPosition(1);
					x = [x1,x2];
					y1 = obj.elementList(i).Node1.previousPosition(2);
					y2 = obj.elementList(i).Node2.previousPosition(2);
					y = [y1,y2];

					line(x,y)
				else
					% There are three cases, where one or both nodes are new i.e. have no previous position
					if isempty(obj.elementList(i).Node1.previousPosition) && ~isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.position(1);
						x2 = obj.elementList(i).Node2.previousPosition(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.position(2);
						y2 = obj.elementList(i).Node2.previousPosition(2);
						y = [y1,y2];

						line(x,y)
					end

					if ~isempty(obj.elementList(i).Node1.previousPosition) && isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.previousPosition(1);
						x2 = obj.elementList(i).Node2.position(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.previousPosition(2);
						y2 = obj.elementList(i).Node2.position(2);
						y = [y1,y2];

						line(x,y)
					end

					if isempty(obj.elementList(i).Node1.previousPosition) && isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.position(1);
						x2 = obj.elementList(i).Node2.position(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.position(2);
						y2 = obj.elementList(i).Node2.position(2);
						y = [y1,y2];
 
						line(x,y,'LineStyle',':')
					end

				end
			end

			axis equal

			if ~isempty(varargin)
				cL = obj.simData('centreLine').GetData(obj);
				plot(cL(:,1), cL(:,2), 'k');
			end

		end

		function Animate(obj, n, sm)
			% Since we aren't storing data at this point, the only way to animate is to
			% calculate then plot

			% Set up the line objects initially

			% Initialise an array of line objects
			h = figure();
			hold on

			fillObjects(length(obj.cellList)) = fill([1,1],[2,2],'r');

			for i = 1:length(obj.cellList)
				c = obj.cellList(i);

				x = [c.nodeList.x];
				y = [c.nodeList.y];

				fillObjects(i) = fill(x,y,c.GetColour());
			end

			totalSteps = 0;
			while totalSteps < n

				obj.NTimeSteps(sm);
				totalSteps = totalSteps + sm;

				for j = 1:length(obj.cellList)
					c = obj.cellList(j);

					x = [c.nodeList.x];
					y = [c.nodeList.y];

					if j > length(fillObjects)
						fillObjects(j) = fill(x,y,c.GetColour());
					else
						fillObjects(j).XData = x;
						fillObjects(j).YData = y;
						fillObjects(j).FaceColor = c.GetColour();
					end
				end

				% Delete the line objects when there are too many
				for j = length(fillObjects):-1:length(obj.cellList)+1
					fillObjects(j).delete;
					fillObjects(j) = [];
				end
				drawnow
				title(sprintf('t=%g',obj.t),'Interpreter', 'latex');

			end

		end

		function AnimateWireFrame(obj, n, sm)
			% Since we aren't storing data at this point, the only way to animate is to
			% calculate then plot

			% Set up the line objects initially

			% Initialise an array of line objects
			h = figure();
			hold on

			lineObjects(length(obj.elementList)) = line([1,1],[2,2]);

			for i = 1:length(obj.elementList)
				
				x1 = obj.elementList(i).Node1.x;
				x2 = obj.elementList(i).Node2.x;
				x = [x1,x2];
				y1 = obj.elementList(i).Node1.y;
				y2 = obj.elementList(i).Node2.y;
				y = [y1,y2];

				lineObjects(i) = line(x,y);
			end

			totalSteps = 0;
			while totalSteps < n

				obj.NTimeSteps(sm);
				totalSteps = totalSteps + sm;

				for j = 1:length(obj.elementList)
				
					x1 = obj.elementList(j).Node1.x;
					x2 = obj.elementList(j).Node2.x;
					x = [x1,x2];
					y1 = obj.elementList(j).Node1.y;
					y2 = obj.elementList(j).Node2.y;
					y = [y1,y2];

					if j > length(lineObjects)
						lineObjects(j) = line(x,y);
					else
						lineObjects(j).XData = x;
						lineObjects(j).YData = y;
					end
				end

				% Delete the line objects when there are too many
				for j = length(lineObjects):-1:length(obj.elementList)+1
					lineObjects(j).delete;
					lineObjects(j) = [];
				end
				drawnow
				title(sprintf('t=%g',obj.t));

			end

		end

	end

	methods (Access = protected)
		
		function id = GetNextTissueId(obj)
			
			id = obj.nextTissueId;
			obj.nextTissueId = obj.nextTissueId + 1;

		end

	end

end