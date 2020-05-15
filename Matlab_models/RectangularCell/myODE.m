function dydt = myODE(x, y)
    
    % y = [y1; y2];
    
    % dydt = [y1'; y2']
    
    dydt = [ y(2) ; x*y(1) + 1/(1+x^2) ];

end