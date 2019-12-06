function P = makeLHSParams(N,lb,ub)
    % Makes a latin hypercube sample in parameter range. Produces N
    % parameter sets that fall between lb and ub
    
    % The last line sets the number of decimal/sig figs for TestCryptColumn
    % As a rule, aiming for 3 sig figs, but if most of the range has a
    % certain number of decimals, then keep that number if we straddle
    % orgers of magnitude
    
    m = length(lb);
    rng default
    A = lhsdesign(N,m,'iterations',100);

    dp = ub - lb;

    p = A .* dp + lb;

    P = [ round(p(:,1),1) ,round(p(:,2),1),round(p(:,3)),round(p(:,4)),round(p(:,5),1),round(p(:,6),3),round(p(:,7),3) ];

end