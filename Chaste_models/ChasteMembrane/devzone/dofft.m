function dofft(dt, L, amp, fr, up, ph, n, me)

    % Plots the magnitude of the coefficients in the fft
    % dt - the time step, hence sampling frequency is 1/dt
    % L - the length of the signal in samples
    % amp,fr,up and ph are vectors of the same length giving the components of
    % the function to be added
    % amp - the amplitude
    % fr - the time multiplier
    % ph - the phase shift
    % up - the vertical shift

    Fs = 1/dt;            % Sampling frequency                    
    t = (0:L-1)*dt;
    y = zeros(size(t));
    for i = 1:length(amp)
        y = y + amp(i) * sin(2*pi*(fr(i) * t + ph(i))) + up(i);
    end

    noise = normrnd(me,n,size(t));
    y = y + noise;
        
    Y = fft(y);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    figure(1)
    plot(t,y);
    figure(2)
    plot(f,P1);

end

