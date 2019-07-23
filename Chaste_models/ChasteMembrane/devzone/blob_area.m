

file = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/position_data/params_cct_15_ees_58_ms_216_n_29_np_12_vf_0.675_wt_9/mutant_Mnp_12_Mvf_0.675_cctM_1_eesM_1_mpos_1_msM_0.9_wtM_1/numerics_bt_40_dt_0.001_t_1000/position_data_run_1.txt';




data = csvread(file);


times = data(:,1);

i = 1254;

cell_area = pi*0.5^2;

blobArea{4}=0;

pop_up_height = 1.35;
neighbour_distance = 1.15;

A = zeros(size(times));
B = zeros(size(times));
C = zeros(size(times));
total = zeros(size(times));


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
        total(i) = total(i) + cell_area;
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
size_of_regions(i) = length(all_regions);
if ~isempty(all_regions)
    A(i) = cell_area * length(all_regions{1});
    if length(all_regions) > 1
        B(i) = cell_area * length(all_regions{2});
        if length(all_regions) > 2
            C(i) = cell_area * length(all_regions{2});
        end
    end
end




figure
hold on
for k = 1:length(all_regions)
    scatter(pos.x(all_regions{k}),pos.y(all_regions{k}),'.');
end
title(num2str(times(i)));
xlim([0 max(pos.x)+1]);
ylim([0 max(pos.y)+1]);

% plot(times,A,times,B,times,total)
% figure
% plot(times,size_of_regions)


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
