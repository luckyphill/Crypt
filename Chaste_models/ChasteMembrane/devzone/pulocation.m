

simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {1,12,1,1,1,1,0.675,'no mutation'});

location = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/MouseColonDesc/mutant_Mnp_15_Mvf_0.675_cctM_1_eesM_1_mpos_1_msM_1_wtM_1/numerics_bt_100_dt_0.0005_t_6000/';

PU = [];
for i = 1:10
    file = sprintf('run_%d/popup_location.txt',i);
    
    fullpath = [location, file];
    
    try
        data = csvread(fullpath);
        % Strip the time signatures
        data = data(:,2:end);
        % Strip the empty rows
        data = data(:);
        data( ~any(data,2), : ) = [];
        PU = [PU, data];
    end
    
end
figure

histogram(PU,0:19, 'Normalization','probability');