file = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation/MouseColonDesc/mutant_Mnp_12_Mvf_0.675_cctM_1_eesM_1_msM_1_wtM_1/numerics_bt_100_t_6000/run_2/popup_location.txt';
 
data = csvread(file);
data = data(:,2:end);

data( ~any(data,2), : ) = [];

[a,b]=size(data);
all_pos = [];
for j = 1:a
    
    % for each line grab the position and parent
    % for unique parents, just dump the position
    % for pairs, take the average
    
    pos = data(j,1:4:end);
    par = data(j,2:4:end);
    pha = data(j,4:4:end);
    
    for k = 1:length(par)
        if pha(k) == 2
            for l = 2:length(par)
                if par(k) == par(l)
                    all_pos(end+1) = (pos(k)+pos(l))/2;
                    break;
                end
            end
        else
            all_pos(end+1) = pos(k);
        end
            
    end
end
% This will catch a lot of zeros, so need to strip them
all_pos(:, ~any(all_pos,1)) = [];
