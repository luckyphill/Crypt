% A script that that takes the cell pois

close all;
clear all;

data_s = [];
data_m = [];
data_wc = [];

LI_M = [];
LI_G1 = [];
LI_S = [];
LI_G2 = [];
LI_G0 = [];

width = 0.5;

s_length = 1;
count = 0;
for i = 0:4000
   
    s_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/sphase_s' num2str(s_length) 'run_' num2str(i) '.txt'];
    wc_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/whole_crypt_s' num2str(s_length) 'run_' num2str(i) '.txt'];

    try
        data_s_temp = dlmread(s_file);
        data_wc = dlmread(wc_file);

        bottomY = 0;
        topY = 12;
        bottomX = data_s_temp(1,1); 
        topX = data_s_temp(1,2);
        
        % Work out length from cell centre to score line
        
        % Run through whole crypt, check if cell centre is is within r of
        % the score line. If so, add it to the list, then order the list
        % from bottom to top. Pick out G1 and G2 phases.
        
        list = [];
        for i = 1:length(data_wc)
            cell = data_wc(i,:);
            
            if isCellInSection(bottomX, topX, topY, [cell(3), cell(4)], width)
                list = [list; cell];
            end
        end
        % Order the list by height above the crypt base
        sorted_list = sortrows(list,4);
        
        % Extract the indices of the cells in each phase
        LI_M =  [LI_M;  find(~(sorted_list(:,2) - 4)) - 1];
        LI_G1 = [LI_G1; find(~(sorted_list(:,2) - 1)) - 1];
        LI_S =  [LI_S;  find(~(sorted_list(:,2) - 2)) - 1];
        LI_G2 = [LI_G2; find(~(sorted_list(:,2) - 3)) - 1];
        LI_G0 = [LI_G0; find(~(sorted_list(:,2) - 0)) - 1];
        
        
        
    catch e
        e
        s_file
    end

end

makeHistogram(LI_M, 'M', s_length);
makeHistogram(LI_G1, 'G1', s_length);
makeHistogram(LI_S, 'S', s_length);
makeHistogram(LI_G2, 'G2', s_length);
makeHistogram(LI_G0, 'G0', s_length);
        
        
        
        

function is_in_section = isCellInSection(xBottom, xTop, yTop, rCellPosition, width)
    
    if (xBottom == xTop)
        intercept(1) = xTop;
        intercept(2) = rCellPosition(2);
    else
        m = (yTop)/(xTop-xBottom);

        intercept(1) = (m*m*xBottom + rCellPosition(1) + m*rCellPosition(2))/(1+m*m);
        intercept(2) = m*(intercept(1) - xBottom);
    end
    
    vec = intercept - rCellPosition;
    length = sqrt(vec(1)^2 + vec(2)^2);
    is_in_section = length <= width;
    
end

function makeHistogram(data, phase, s_length)
    
    max_pos = max(data);
    edges = -0.5:1:(max_pos + 0.5);
    if strcmp(phase, 'G0'), min_pos = min(data);edges = -0.5:1:(max_pos + 0.5); end;
    figure;
    histogram(data,edges,'Normalization' ,'probability');
    
    title(['Labelling index from ' phase ' phase'], 'Interpreter' ,'latex');
    
    xlabel('Cell position number', 'Interpreter' ,'latex');
    ylabel('Cell proportion', 'Interpreter' ,'latex');
    xlim([-0.5 11.5]);
    if strcmp(phase, 'G0'), xlim([min_pos-0.5 max_pos+0.5]); end
    ylim([0 .14]);
    
    h = gcf;
    h.Units = 'centimeters';
    fig_size = h.Position;
    h.PaperSize = fig_size(3:4);
    h.PaperUnits = 'centimeters';
    file_name = ['/Users/phillipbrown/Research/Crypt/Images/Chaste/LabellingIndex/s' num2str(s_length) '/LI_' phase '_s' num2str(s_length)];
    print(file_name,'-dpdf');
end