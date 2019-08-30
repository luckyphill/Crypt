

simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {1,12,1,1,1,1,0.675,'no mutation'});

location = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/MouseColonDesc/mutant_Mnp_12_Mvf_0.675_cctM_1_eesM_1.2_mpos_1_msM_1_wtM_1/numerics_bt_100_dt_0.0005_t_6000/';

PU = [];
for i = 1:10
    file = sprintf('run_%d/popup_location.txt',i);
    
    fullpath = [location, file];
    
    try
        data = csvread(fullpath);
        % Strip the time signatures
        data = data(:,2:end);
        % Strip the empty rows
        data( ~any(data,2), : ) = [];
        % handle twin nodes
        % for each row, compare each pair of nodes
        % if the two x positions are within a certain range
        % then remove the two, and replace it with an average
        [a,b]=size(data);
        for j = 1:a
            for k=1:b-1
                for l=k+1:b
                    if abs(data(j,k) - data(j,l)) < 0.8 && data(j,k) >0 && data(j,l) > 0
                        % nodes are probably part of the same cell
                        midpt = (data(j,k) + data(j,l)) / 2;
                        data(j,k) = midpt;
                        data(j,l) = 0;
                        break;
                    end
                end
            end
        end
        
        % Put the data in a column vector
        data = data(:);
        %strip the remaining zeros
        data( ~any(data,2), : ) = [];
        PU = [PU; data];
    end
    
end
figure

histogram(PU,0:19, 'Normalization','probability');
ylim([0 .12]);
title(sprintf('Pop up index: n = %d', length(PU)));