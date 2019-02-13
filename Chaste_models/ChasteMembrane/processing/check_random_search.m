param_files = dir('/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/');

for i = 1:length(param_files)
        
    try
        file_name = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/' param_files(i).name];
        data = csvread(file_name,1,0);
        total_count = data(1);
        slough = data(2);
        anoikis = data(3);
        prolif = data(4);
        differ = data(5);
        total_end = data(6);
        obj = objective_function(total_count, slough, anoikis, prolif, differ, total_end);
        if obj < 10
            fprintf('%s\n',param_files(i).name);
            fprintf('%d\n',obj);
        end
    end
        
end



function obj = objective_function(total_count, slough, anoikis, prolif, differ, total_end)

    obj =  penalty(anoikis,0,4,1) + penalty(total_end,31,35,1) + penalty(prolif,20,24,1) + penalty(anoikis + slough,85,95,1);


end

function pen = penalty(value, min, max, ramp)
    % If value is between min and max, penalty is 0
    % Otherwise it ramps up like a polynomial of order ramp
    
    if (value <= max && value >= min)
        pen = 0;
    end
    
    if value > max
        
        pen = abs(value - max) ^ ramp;
    end
    
    if value < min
        
        pen = abs(min - value) ^ ramp;
    end
    
    
end
