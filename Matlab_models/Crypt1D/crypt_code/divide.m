function p = divide(p)

    cells_to_divide = []; % initialise list of cells to divide
    temp = 1:p.n; % used to get the indices
    proliferative_zone = temp(p.x(end,:)<p.cut_out_height); %determines cells that can proliferate
    
    cells_to_divide = temp(p.ages(proliferative_zone) > p.divide_age(proliferative_zone)); % determines cells ready to divide

    % Process the cells ready to divide
    if ~isempty(cells_to_divide)
        p = divide_cells(cells_to_divide,p);
    end

end
