function conv_shape(s,sp,h)
    file = sprintf('/Users/phillipbrown/testoutput/TestCryptColumnShape/Pulse/n_40_size_%d_speed_%.1f_height_%d/results_from_time_0/results.viznodes', s,sp,h);
    data = dlmread(file);

    times = data(:,1);


    steps = -0.5:40.5;
    nn = length(steps)-1;

    pos_max_t = nan(length(times),nn);


    for i=1:length(times)
        clear sortedbypos;
        nz = find(data(i,:), 1, 'last');
        x = data(i,2:2:nz);
        y = data(i,3:2:nz);
        sortedbypos{nn} = [];
        for j = 1:length(x)
            for k=2:length(steps)
                if steps(k) >= y(j) && y(j) > steps(k-1)
                    sortedbypos{k-1}(end + 1) = x(j);
                end
            end
        end

        for j = 1:nn
            temp = max(sortedbypos{j});
            if ~isempty(temp)
                pos_max_t(i,j) = temp;
            end
        end

    end

    % exract the non zero segment from positoin 32

    pos32 = pos_max_t(:,32);
    for i = 1:length(pos32)-1
        if isnan(pos32(i))
            pos32(i) = (pos32(i-1) + pos32(i+1))/2;
        end
    end

    nzf = find(pos32, 1, 'first');
    nzl = find(pos32, 1, 'last');

    want = pos32(nzf:nzl);
    
    out = '/Users/phillipbrown/Research/Crypt/Data/Chaste/MutationBaseline/';
    mkdir(out)
    outfile = sprintf('%ssize_%d_speed_%.1f_height_%d.txt', out,s,sp,h);
    csvwrite(outfile,want);
end
    