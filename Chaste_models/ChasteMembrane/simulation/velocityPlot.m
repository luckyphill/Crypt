classdef velocityPlot < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		
		imageFile
		imageLocation

		velocityData

		simul

	end

	methods

		function obj = velocityPlot(n,np,ees,ms,cct,wt,vf,t,dt,bt,sm,run_number)

			outputType = positionData(containers.Map({'sm'},{10}));

			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n, np, ees, ms, cct, wt, vf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {t, bt, dt});
			seedParams = containers.Map({'run'}, {run_number});

			chastePath = [getenv('HOME'), '/'];
			chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];


			obj.simul = simulateCryptColumn(simParams, solverParams, seedParams, outputType, chastePath, chasteTestOutputLocation);
			
			if obj.simul.generateSimulationData()
				obj.processData();
			else
				error('Failed to get the data')
			end

		end

		function h = showPlot(obj)
			% Displays a plot of the velocity data
			[upper, average, lower] = obj.get_quantiles();

			h = figure;
		    hold on;
		    plot(average, 'LineWidth', 4);
		    plot(upper,'k:');
		    plot(lower,'k:');

		    ylim([-0.1, max(average) * 1.1]);
    		xlim([0, obj.simul.simParams('n')]);

    		ylabel('Cell velocity','Interpreter','latex');
    		xlabel('Cell height','Interpreter','latex');
    		title('Cell velocity as a function of height from the crypt base','Interpreter','latex');

    		set(h,'Units','Inches');
		    pos = get(h,'Position');
		    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

		end

	end


	methods (Access = private)

		function processData(obj)
			% Turns the raw position data into (y_pos, y_vel) data format
    
		    times = obj.simul.data(:,1);
		    dt = obj.simul.solverParams('dt');
		    nt = length(times);
		    pos_data = obj.simul.data(:,2:end);
		    max_cell_ID = max(pos_data(:));
		    
		    y_pos = nan(length(times), max_cell_ID);
		    
		    for i = 1:nt
		       % At each time step, read all the IDs and y positions
		       % Put these into y_pos using the ID as the index
		       entries = length(pos_data(i,:));
		       IDs = pos_data(i, 1:3:entries);
		       nz = find(IDs, 1, 'last');
		       positions = pos_data(i, 3:3:entries);
		       % Start from 2 here because the first cell ID is always 0 and matlab
		       % doesn't like 0 indices. Luckily this cell is the fixed cell that
		       % doesn't divide
		       y_pos(i,IDs(2:nz)) = positions(2:nz);
		        
		    end

		    y_vel = nan(size(y_pos));
		    for i = 2:nt
		        y_vel(i, :) = (y_pos(i, :) - y_pos(i-1, :))/dt; % could be vectorised, but matlab will handle this
		    end
		    
		    v = [0; 0];
		    [m,n] = size(y_vel);
		    
		    
		    % Construct a 2 x n array
		    for i = ceil(nt/2):nt
		        ind = ~isnan(y_vel(i,:));
		        
		        pos = y_pos(i,ind);
		        vel = y_vel(i,ind);
		             
		        v = cat(2, v, cat(1,pos,vel));
		        
		    end

		    obj.velocityData = v;

		end


		function [upper, average, lower] = get_quantiles(obj)
		    % This function takes the velocity data with a position (continuous or discrete)
		    % and returns lines that represent the 75th, 50th and 25th quantiles
		    
		    q_u = 0.75;
		    q_a = 0.50;
		    q_l = 0.25;

		    v = obj.velocityData;
		    
		    n_points = length(v);
		    
		    top = ceil(max(v(1,:)));
		    
		    edges = 0.5:1:(top + 0.5);
		    
		    n = length(edges);
		    
		    bins{n} = [];
		    
		    for i = 1:n_points
		        for j = 1:n-1
		            if v(1,i) > edges(j) && v(1,i) < edges(j+1)
		                bins{j} = [bins{j},v(2,i)];
		                break;
		            end
		        end
		    end
		    
		    for i = 1:length(bins)
		        output = quantile(bins{i}, [q_u, q_a, q_l]);
		        upper(i) = output(1);
		        average(i) = output(2);
		        lower(i) = output(3);
		    end

		end


	end


end