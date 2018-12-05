function write_cells(p)

    % Write cell positions to output_file.txt
    % File handling is done outside this function, so it expects a file ID
    % to be passed in
    num = 2 * length(p.x( ~isnan(p.x) )) + 1; %
    data(num) = nan;
    
    data(1) = p.t;
    data(2:2:num) = p.cell_IDs( ~isnan(p.x) );
    data(3:2:num) = p.x( ~isnan(p.x) );
    
    data_file = [p.output_file '.txt'];
    
    dlmwrite(data_file,data,'-append');
    
%     for i=1:p.n
%         str = strcat(str, sprintf(' %d, %.4f,', p.cell_IDs(i), p.x(i)));
%     end
%     str = strcat(str, '\n');
%     
%     fprintf(p.fid,str);


end