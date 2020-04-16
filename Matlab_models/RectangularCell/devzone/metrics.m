l = 20;
dx = 0.6;
x1 = 0:dx:l;
y1 = ones(size(x1));
% y2 = 0.5 * sin(x1);
% x3 = [0:dx:0.8*l/2, (0.8*l/2 + dx):dx/2:(1.2*l/2 - dx), 1.2*l/2:dx:l];
% y3 = 4 * exp( -(x3-l/2).^2);

f2 = @(x) 0.5 * sin(x);
df2 = @(x) 0.5 * cos(x);
d2f2 = @(x) -0.5 * sin(x);

f3 = @(x)  4 * exp( -(x-l/2).^2);
df3 = @(x) 4 * (-2 * (x-l/2).* exp( -(x-l/2).^2));
d2f3 = @(x) 4 * (4 * (x-l/2).* exp( -(x-l/2).^2) - 2 * exp( -(x-l/2).^2));


[x2,y2] = makeXY(f2,df2,d2f2,0,l,0.5);
[x3,y3] = makeXY(f3,df3,d2f3,0,l,0.5);

w1 = wiggles(x1,y1);
w2 = wiggles(x2,y2);
w3 = wiggles(x3,y3);

a1 = wrinkles(x1,y1);
a2 = wrinkles(x2,y2);
a3 = wrinkles(x3,y3);

d1 = ydev(x1,y1);
d2 = ydev(x2,y2);
d3 = ydev(x3,y3);

ta1 = totalAngle(x1,y1);
ta2 = totalAngle(x2,y2);
ta3 = totalAngle(x3,y3);

ds1 = dumbsum(x1,y1);
ds2 = dumbsum(x2,y2);
ds3 = dumbsum(x3,y3);

close all

figure
plot(x1,y1,x2,y2,x3,y3);


function [x,y] = makeXY(f,df,d2f,x0,xf,step)

    % args are function handles
    
    % curvature
    curve = @(x) d2f(x)./(1+df(x).^2).^(3/2);
    
    % step size function produced empirically
    % Gives the relative change fo step size from a zero curvature region
    % so, to get the actual step size use ds * standard step size
    ds = @(k) ( exp(-(2*k+0.75).^2) + ((2*k+0.75)+4)./(2*(1+exp(-(2*k+0.75)))))./2.91 + 0.25;
    
    x(1) = x0;
    y(1) = f(x0);
    
    while x(end) < xf
        
        k = curve(x(end));
        s = step * ds(k);
        
        m = df(x(end));
        
        theta = atan(m);
        x(end+1) = x(end) +s*cos(theta);
        y(end+1) = y(end) +s*sin(theta);
        
    end

end

function wiggle = wiggles(x,y)
    
    len = 0;
    for i = 1:length(x) - 1
        len = len + sqrt( (x(i+1) - x(i))^2 + (y(i+1) - y(i))^2 ) ;

    end
    
    wiggle = len/(x(end) - x(1));
    
end

function alpha = wrinkles(x,y)

    grad = 0;
    for i = 1:length(x) - 1
        grad = grad + abs( (y(i+1) - y(i)) / (x(i+1) - x(i)) ) ;
    end

    alpha = grad / (length(x) - 1);
end

function dev = ydev(x,y)

    dev = mean(abs(y));

end

function ta = totalAngle(x,y)

    ta = 0;
    for i = 2:length(x)-1
        v1 = [x(i-1) - x(i), y(i-1) - y(i)];
        v2 = [x(i+1) - x(i), y(i+1) - y(i)];
        
        ta = ta + acos(  dot(v1, v2) / ( norm(v1) * norm(v2) )  );
    end
    % Makes this the average angle
    ta = ta/(length(x)-1);
end

function ds = dumbsum(x,y)

    ds = (sum(abs(x)) + sum(abs(y))) / length(x);

end