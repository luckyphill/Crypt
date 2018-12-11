function p = move(p)
    

    % Refresh the indices of alive and dead cells
    alive = 1:p.n;
    dead = p.n+1:p.n+p.n_dead;
    
    % Force calculations only for the live cells
    f = force(p.x(end,alive),p);
    
    % New positions for live cells
    % Time stepping using the effective displacement given in Meineke et al
    % 2001 (eqn 2)
    p.x(alive) = p.x(alive) + f * p.dt/p.damping;
    p.x(dead) = nan(1,p.n_dead); % bookkeeping for the dead cells
    
    p.v(alive) =  f/p.damping;
    p.v(dead) = nan(1,p.n_dead); % bookkeeping for the dead cells (not end+1 because previous command created the new row)
 

end