

file = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/visualiser_data/n_29_np_12_EES_58_MS_216_CCT_15_WT_9_VF_0.675_run_21/mpos_1_Mnp_12_eesM_1_msM_0.9_cctM_1_wtM_1_Mvf_0.675/results_from_time_40/cell_positions.dat';




data = csvread(file);


times = data(:,1);

%i = 1501;
%i = 3333;

cell_area = pi*0.5^2;

blobArea{4}=0;

A = zeros(size(times));
B = zeros(size(times));
C = zeros(size(times));
    
for i = 1:length(times)

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
        if pos.x(j) > 1.3 % The cell has popped up
            for k = 1:length(pos.x)

                if j~=k && pos.x(k) > 1.3
                    l = distance(pos.x(j),pos.y(j), pos.x(k),pos.y(k));

                    if l < 1.1
                        % k is a neighbour of j
                        cells{j} = [cells{j}, k];
                    end
                end
            end
        end
    end


    found = zeros(size(pos.x));
    k=1;
    all_regions = {};
    for j = 1:length(pos.x)
        if found(j) == 0 && pos.x(j) > 1.3
            found(j) = 1;
            [all_regions{k}, found] = recursive_region(cells, found, [j], cells{j});
            k=k+1;
        end

    end

    % claculate the area of the blobs and store it in an appropriate vector
    if ~isempty(all_regions)
        A(i) = cell_area * length(all_regions{1});
        total(i) = A(i);
        if length(all_regions) > 1
            B(i) = cell_area * length(all_regions{2});
            total(i) = total(i) + B(i);
            if length(all_regions) > 2
                C(i) = cell_area * length(all_regions{2});
                total(i) = total(i) + C(i);
                if length(all_regions) > 3
                    D(i) = cell_area * length(all_regions{2});
                    total(i) = total(i) + D(i);
                end
            end
        end
    end

end


% figure
% hold on
% for k = 1:length(all_regions)
%     scatter(pos.x(all_regions{k}),pos.y(all_regions{k}),'.');
% end
% xlim([0 max(pos.x)+1]);
% ylim([0 max(pos.y)+1]);




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
