

points = [];
for i = 1:8
	% Open the optimal point file and check how many there are

	fileLocation = 'Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/optimal/';
	file = [fileLocation, getCryptName(i),'.txt'];
	data = csvread(file);
	numOptimals = size(data, 1);

	for j = 1:numOptimals
		for k = j+1:numOptimals
			obj = optimalPointWalk(i, j, k, 10, 'varargin');
			points(end+1:end+11,:) = obj.points;
		end
	end
end

points = unique(points,'rows');

csvwrite('optimalWalkPoints.txt', points);