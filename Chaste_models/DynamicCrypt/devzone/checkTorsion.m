% This script examines the separation drift of two cells when a torsion spring is applied
% Since the force applied moves linearly, the cell will not follow a circle
% as would happen in a rotation, hence a gap will appear between the two
% cells

cells(1).x = 0;
cells(1).y = 1;

cells(2).x = 0;
cells(2).y = 0;

cells(3).x = 1;
cells(3).y = 0;

cv = cell2mat(struct2cell(cells'));
viscircles(cv', [0.5,0.5,0.5]);

for i = 1:50
    
cells = updateCells(cells);
cv = cell2mat(struct2cell(cells'));
viscircles(cv', [0.5,0.5,0.5],'Color','b');
end


function cells = updateCells(cells)
    % Determines the new positions of the cells
    
    Fl12 = linearForce(cells(1),cells(2));
    Fl23 = linearForce(cells(2),cells(3));
    T = torsionForce(cells);
    
    l12 = getLength(cells(1), cells(2));
    l23 = getLength(cells(2), cells(3));
    
    v12 = getUnitVecAB(cells(1), cells(2));
    v23 = getUnitVecAB(cells(2), cells(3));
    
    vp1 = getPerpVector(v12);
    vp3 = -getPerpVector(v23);
    
    Ft1 = T*vp1/l12;
    Ft3 = T*vp3/l23;
    
    F1 = Fl12 - Ft1;
    F2 = -Fl12 + Fl23;
    F3 = -Fl23 + Ft3;
    
    
    dt = 0.02;
    eta = 1;
    
    d1 = dt * F1/eta;
    d2 = dt * F2/eta;
    d3 = dt * F3/eta;
    
    cells(1).x = cells(1).x + d1(1);
    cells(1).y = cells(1).y + d1(2);
    
    cells(2).x = cells(2).x + d2(1);
    cells(2).y = cells(2).y + d2(2);
    
    cells(3).x = cells(3).x + d3(1);
    cells(3).y = cells(3).y + d3(2);
        

end

function vp = getPerpVector(v)

    vp = [-v(2), v(1)];
end

function length = getLength(cellA, cellB)

    d.x = cellB.x - cellA.x;
    d.y = cellB.y - cellA.y;
    length = sqrt( d.x^2 + d.y^2 );
end

function unitVec = getUnitVecAB(cellA, cellB)

    d.x = cellB.x - cellA.x;
    d.y = cellB.y - cellA.y;
    l = sqrt( d.x^2 + d.y^2 );
    
    unitVec = [d.x, d.y] / l;
end


function force = linearForce(cellA, cellB)
    % Calculates the non-linear spring force that moves in a line
    % as opposed to rotationally
    
    l = getLength(cellA, cellB);
    force = getUnitVecAB(cellA, cellB);
    
    rl = 1; % rest length of the spring
    k = 1;
    
    dl = l - 1;
    
    if dl > 0
        f = k * rl * log(1 + dl/rl);
    else
        f = k * dl * exp(-5.0 * dl/rl);
    end
    
    force = force * f;
    

end

function torsion = torsionForce(cells)
    % Gives the naive returning force from torsion spring
    
    v12 = getUnitVecAB(cells(1), cells(2));
    v23 = getUnitVecAB(cells(2), cells(3));
    
    cosAngle = v12(1)*v23(1) + v12(2)*v23(2);
    
    k = 1;
    
    angle = acos(cosAngle);
    
    dAngle = pi - angle;
    
    %torsion = k * dAngle;
    torsion = k * angle;

end