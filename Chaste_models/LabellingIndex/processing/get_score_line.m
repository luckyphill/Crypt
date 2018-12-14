close all;
clear all;

data_s = [];
data_m = [];
data_wc = [];

width = 0.5;

s_length = 5;
count = 0;
for i = 0:4000
   
    s_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/sphase_s' num2str(s_length) 'run_' num2str(i) '.txt'];
    wc_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/whole_crypt_s' num2str(s_length) 'run_' num2str(i) '.txt'];

    try
        data_s_temp = dlmread(s_file);
        data_wc_temp = dlmread(wc_file);

        bottomY = 0;
        topY = 12;
        [bottomX, topX] = data_s_temp(1,:);
        data_wc = cat(1, data_wc, [data_wc_temp(:,2), data_wc_temp(:,4)]);
        
        % Work out length from cell centre to score line
        
        % Run through whole crypt, check if cell centre is is within r of
        % the score line. If so, add it to the list, then order the list
        % from bottom to top. Pick out G1 and G2 phases.
        
        list = [];
        for i = 1:length(data_wc)
            cell = data_wc(i);
            
            if isCellInSection(bottomX, topX, topY, cell, width)
                list = [list, cell];
            end
        end
        % Order the list by height
        
    catch e
        e
        s_file
    end

end

function is_in_section = isCellInSection(xBottom, xTop, yTop, rCellPosition, width)
    
    if (xBottom == xTop)
        intercept(0) = xTop;
        intercept(1) = rCellPosition(1);
    else
        m = (yTop)/(xTop-xBottom);

        intercept(0) = (m*m*xBottom + rCellPosition(0) + m*rCellPosition(1))/(1+m*m);
        intercept(1) = m*(intercept(0) - xBottom);
    end
    
    vec = intercept - rCellPosition;
    length = sqrt(vec(1)^2 + vec(2)^2);
    is_in_section = length <= width;
    
end