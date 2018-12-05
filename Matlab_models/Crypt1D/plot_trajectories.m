function plot_trajectories(file)
%% Takes a test file of cell positions and plots the trajectories

	file = [file '.txt'];
    data = csvread(file);

    [t_steps, n] = size(data);


    max_ID = max(max(data(:,2:2:n)));

    cell_IDs = 1:max_ID;

    clean_data = nan(t_steps,max_ID);

    for i = 1:t_steps

    	row = data(i,2:n);
    	positions = row(2:2:n-1);
    	positions = positions(positions>0); % Unfortunately csvread pads with zeros, this line gets rid of the padding
    										% but at the same time gets rid of the legitimate cell with position = 0.0
    	indices = row(3:2:n-1);				% Hence on this line we have to skip the first cell index
    	indices = indices(indices >0);

   		clean_data(i, indices) = positions;
   	end

   	plot(clean_data);
   	xlim([0 t_steps]);

end



