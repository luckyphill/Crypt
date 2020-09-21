function [pillX,pillY] = drawPill(a,b,r)

    % Draws a pill shape where the centre of the circles are at
    % a and b and the radius is r

     AtoB = b - a;
     
     normAtoB = [-AtoB(2), AtoB(1)];
     
     normAtoB = normAtoB / norm(normAtoB);
     
     R = r*normAtoB;
    % Make n equally spaced points around a circle starting from R
    
    n = 10;
    apoints = [];
    bpoints = [];
    
    rot = @(theta) [cos(theta), -sin(theta); sin(theta), cos(theta)];
    
    for i=1:n-1
        
        theta = i*pi/n;
        apoints(i,:) = rot(theta)*R' + a';
        bpoints(i,:) = -rot(theta)*R' + b';
        
    end
    pill = [ a + R; apoints; a - R; b - R; bpoints;  b + R];
    
    pillX = pill(:,1);
    pillY = pill(:,2);

end