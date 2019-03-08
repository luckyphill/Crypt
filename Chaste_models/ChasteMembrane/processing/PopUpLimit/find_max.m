function theta_trial = find_max(l)

    %f = @(x,l) ( 2 / (2-l.*sec(x)) ) .* sin(x) .* exp( 5.*l.*tan(x) ) + 2.*log(2-l.*sec(x)) .* (   cos(x).*exp(5.*l.*tan(x)) + sin(x).*5.*l.*sec(x).*sec(x).*exp(5.*l.*tan(x))   ) / (l.*tan(x))  - (1/(l.*sec(x)^4)) .* (   2.*log(2-l.*sec(x)).*sin(x).*exp( 5.*l.*tan(x) )   );
    f = @(x,l) exp(5.*l.*tan(x)).*((2.*sin(x))/(l - 2.*cos(x)) + (10.*sec(x) - (2.*sin(x))/l).*log(sec(x).*(2.*cos(x) - l)));
    
    % run the bisction method
    root_found = false;
    
    % from inspection, the maximum occurs between 0 and 1
    theta_lower = 0;
    theta_upper = 1.57;
    
    if (l < 0.12)
        theta_lower = 1.4;
    end
    
    if( l < 0.055)
        theta_lower = 0;
        theta_upper = 0.5;
    end

    theta_trial = (theta_upper - theta_lower)/2 + theta_lower;

    f_trial = f(theta_trial,l);

    it = 0;
    tol = 1e-6;
    lim = 1000;




    while (abs(f_trial) > tol && it < lim)
        theta_trial = (theta_upper - theta_lower)/2 + theta_lower;

        f_trial = f(theta_trial,l);

        if f_trial > 0
            theta_lower = theta_trial;
        else
            theta_upper = theta_trial;
        end

        it = it + 1;
        
        %fprintf('[%.5f, %.5f]\n', x_lower, x_upper);

    end

    if (abs(f_trial) < tol)
        root_found = true;
    end
end