
rb = 1; % radius of bottom/niche
re = 0.5; % radius of the edge

h = 5; % height of the crypt from cb to ce
w = 10; % width from edge to edge of sim domain

cb = [0,0];
cel = cb - [(rb+re), 0] + [0,h];
cer = cb + [(rb+re), 0] + [0,h];

d = 5; % divisions in a quater of a circle

pos = []; % a vector of all the positions

% We start from the right and work our way to the left to make an
% anticlockwise loop.

x = linspace(w/2,(rb+re),10);

pos = [x',(h + re)*ones(size(x'))];

% First curve
% Theta goes from pi/2 to pi in d steps
for i = 1:d-1
    theta = pi/2 + i * pi / (2*d);
    pos(end+1,:) = cer + [re*cos(theta), re*sin(theta)];
end

y = linspace(h,0,20);

temp = [rb * ones(size(y')), y'];

pos = [pos;temp];


% Second curve
% Theta goes from 0 to -pi/2 in d steps
for i = 1:d
    theta = 0 - i * pi / (2*d);
    pos(end+1,:) = cb + [re*cos(theta), re*sin(theta)];
end


% The line is symetrical so just duplicate and reflect the x values
% except for the very bottom

rpos = flipud(pos);
rpos(:,1) = -rpos(:,1);
rpos(1,:) = [];

pos = [pos;rpos];


