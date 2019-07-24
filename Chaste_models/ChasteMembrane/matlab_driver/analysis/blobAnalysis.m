classdef blobAnalysis < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		
		chastePath
		chasteTestOutputLocation

		imageFile
		imageLocation

		blobData
		times

		A
		B
		C
		total
		number_of_regions

		simul

	end

	methods

		function obj = blobAnalysis(simParams,mpos,Mnp,eesM,msM,cctM,wtM,Mvf,t,dt,bt,sm,run_number)

			outputType = positionData(containers.Map({'sm'},{10}));
			mutationParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {mpos,Mnp,eesM,msM,cctM,wtM,Mvf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {t, bt, dt});
			seedParams = containers.Map({'run'}, {run_number});

			obj.chastePath = [getenv('HOME'), '/'];
			obj.chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];


			obj.simul = simulateCryptColumnMutation(simParams, mutationParams, solverParams, seedParams, outputType, obj.chastePath, obj.chasteTestOutputLocation);
			
			if obj.simul.generateSimulationData()
				obj.blobArea();
			else
				error('Failed to get the data')
			end

		end

		function blobArea(obj)
			data = obj.simul.data;

			obj.times = data(:,1);
			obj.total = zeros(size(obj.times));
			obj.A = zeros(size(obj.times));
			obj.B = zeros(size(obj.times));
			obj.C = zeros(size(obj.times));

			cell_area = pi*0.5^2;

			pop_up_height = 1.3;
			neighbour_distance = 1.3;

			A = zeros(size(obj.times));
			B = zeros(size(obj.times));
			C = zeros(size(obj.times));
			total = zeros(size(obj.times));
			    
			for i = 1:length(obj.times)

			    position = data(i,2:end);


			    pos.x = position(2:3:end);
			    pos.y = position(3:3:end);
			    nz = find(pos.x, 1, 'last');

			    pos.x = pos.x(1:nz);
			    pos.y = pos.y(1:nz);

			    % for each cell, grab it's neighbours
			    clear cells
			    cells{length(pos.x)} = [];
			    for j = 1:length(pos.x)
			        if pos.x(j) > pop_up_height % The cell has popped up
			            for k = 1:length(pos.x)

			                if j~=k && pos.x(k) > pop_up_height
			                    l = distance(pos.x(j),pos.y(j), pos.x(k),pos.y(k));

			                    if l < neighbour_distance
			                        % k is a neighbour of j
			                        cells{j} = [cells{j}, k];
			                    end
			                end
			            end
			            obj.total(i) = obj.total(i) + cell_area;
			        end
			    end


			    found = zeros(size(pos.x));
			    k=1;
			    all_regions = {};
			    for j = 1:length(pos.x)
			        if found(j) == 0 && pos.x(j) > pop_up_height
			            found(j) = 1;
			            [all_regions{k}, found] = recursive_region(cells, found, [j], cells{j});
			            k=k+1;
			        end

			    end

			    % claculate the area of the blobs and store it in an appropriate vector
			    obj.number_of_regions(i) = length(all_regions);
			    if ~isempty(all_regions)
			        obj.A(i) = cell_area * length(all_regions{1});
			        if length(all_regions) > 1
			            obj.B(i) = cell_area * length(all_regions{2});
			            if length(all_regions) > 2
			                obj.C(i) = cell_area * length(all_regions{2});
			            end
			        end
			    end

			end

			obj.blobData{i} = all_regions;


		end

		function plotBlobArea(obj)
		
			plot(obj.times, obj.A, obj.times, obj.B, obj.times, obj.C, obj.times, obj.total)
			figure()
			plot(obj.times,obj.number_of_regions)
		end

	end
	
end
function [region, found] = recursive_region(cells, found, region, neighbours)
    % recursively finds regions
	for i=1:length(neighbours)
		if found(neighbours(i)) == 0
			found(neighbours(i)) = 1;
			region = [region, neighbours(i)];
			[region,found] = recursive_region(cells, found, region, cells{neighbours(i)});
		end
	end
end

function l = distance(x1,y1,x2,y2)
    % Returns the euclidean distance between two points
    l = sqrt((x1-x2)^2 + (y1 - y2)^2);

end