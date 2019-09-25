function time_series = make_pulses(n, speed, s, h, g)

    % Takes the pulse height data and collates it into a time series of
    % multiple pulses defined by the input parameters
    % n - the number of pulses
    % speed - the speed that a pulse moves at. at this point it will be
    % constant for all pulses to reflect the fact that the cell velocity should
    % be relatively constant. must be in the set [0.1,0.2,0.5]
    % s - a vector of pulse sizes. each pulse in order will take a size from
    % the vector. if there are more pulses than sizes, then it will start from
    % the beginning. sizes must be in the set [2,4,6,8]
    % h - a vector of pulse heights, built in the same way as s. heights must
    % be in the set [2,4,6]
    % g - a vector of gap sizes between pulses. the numbers will be positive
    % integers, and will determine the total length of time. gaps go in front 
    % of pulses in all cases. if g is a negative
    % number, then the pulses will overlap and the maximum of the two possible
    % values will be used in the time series. if using negative numbers care
    % must be taken to make sure the number is not too small, especially in the
    % first few pulses

    path = [getenv('HOME'), '/Research/Crypt/Data/Chaste/MutationBaseline/'];

    l_s = length(s);
    l_h = length(h);
    l_g = length(g);
    
    time_series = [];

    % Force everything to be a column vector
    for i = 1:n
        file = [path, sprintf('size_%d_speed_%.1f_height_%d.txt',s(mod(i,l_s)+1),speed,h(mod(i,l_h)+1))];
        pulse = csvread(file);
        
        % gap size
        g_s = g(mod(i,l_g)+1);
        if g_s >=0
            % Tack the gap and pulse onto the end
            gp = zeros(g_s, 1);
            time_series = [time_series; gp; pulse];
        else
            % Overlap the previous and new pulse
            last = time_series(end+g_s:end);
            l_p = length(pulse);
            
            lap = min(abs(g_s), l_p);
            
            paired = [pulse(1:lap),last(1:lap)];
            out = max(paired,[],2);
            
            % We have the overlap now need to reconstruct the time series
            
            % Overwrite the overlapped part
            time_series((end+g_s+1):(end+g_s + lap)) = out;
            % If there is part of the new pulse that is not overlapping
            % tack it on to the end
            if lap == abs(g_s)
                time_series = [time_series; pulse(lap+1:end)];
            end
            
            
        end

    end
    
    L = length(time_series); % Number of samples
    Fs = 2; % Two samples every hour
    
    t = (0:L-1)/Fs;
    
    figure(1)
    plot(t, time_series);
    
    
    
    
    Y = fft(time_series);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    
    figure(2)
    plot(f,P1);



end
