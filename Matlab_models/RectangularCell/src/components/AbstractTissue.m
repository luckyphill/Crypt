classdef (Abstract) AbstractTissue < handle & matlab.mixin.Heterogeneous
	% A parent class for a generalised tissue. This will contain all
	% of the nodes elements and cells specific to a type of tissue,
	% for example epithelial, connective/stromal, etc. etc.
	% It will contain all of the intra-tissue force calculators

	% Tissues will interact via a super-tissue force calculator
	% based on the element node interaction. (E-N interaction can
	% still occur within a tissue)

	properties
        
		nodeList
		nextNodeId = 1

	end

	properties (Abstract)

		% Give each tissue a meaningful name maybe?
		name

		% Each tissue must have a pointer to a global space partition
		% This cannot be unique per tissue
		partition

	end

	methods (Abstract)

		% A method that checks the conditions for a tissue to
		% grow. This will most often be through cell division,
		% but can also be membrane/connective tissue increasing
		% in size
		MakeTissueGrow(obj)
		GenerateForces(obj)
		AdvanceAge(obj, dt)

	end

	methods	

		function AddNeighbourhoodBasedForce(obj, f)

			if isempty(obj.neighbourhoodBasedForces)
				obj.neighbourhoodBasedForces = f;
			else
				obj.neighbourhoodBasedForces(end + 1) = f;
			end

		end

		function AddTissueBasedForce(obj, f)

			if isempty(obj.tissueBasedForces)
				obj.tissueBasedForces = f;
			else
				obj.tissueBasedForces(end + 1) = f;
			end

		end

		function numNodes = GetNumNodes(obj)

			numNodes = length(obj.nodeList);

		end

	end


	methods (Access = protected)
		
		function id = GetNextNodeId(obj)
			
			id = obj.nextNodeId;
			obj.nextNodeId = obj.nextNodeId + 1;

		end

		function AddNodesToList(obj, listOfNodes)
			
			for i = 1:length(listOfNodes)
				% If any of the nodes are already in the list, don't add them
				if sum(ismember(listOfNodes(i), obj.nodeList)) == 0
					obj.nodeList = [obj.nodeList, listOfNodes(i)];
				end

			end

		end

	end

end