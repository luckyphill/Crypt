function dydt = myFun(t, y)
    
    dydt = y*cos(t*y) + cos(t);

end