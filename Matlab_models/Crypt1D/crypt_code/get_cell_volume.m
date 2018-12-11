function vol = get_cell_volume(p)
    
    j = 2:p.n;
    lengths = p.x(end,j) - p.x(end,j-1);
   
    i = 2:p.n-1;
    vol(1) = 2 * lengths(1);
    vol(i) = lengths(i-1) + lengths(i);
    vol(p.n) = lengths(p.n-1) + p.l;



end