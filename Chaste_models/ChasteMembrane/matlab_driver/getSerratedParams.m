function params = getSerratedParams(crypt, version)

	cryptName = getCryptName(crypt);

	param_file = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/optimal/serrated/', cryptName,'.txt'];

	data = csvread(param_file);

	try
		params = data(version,:);
	catch
		error('There are only %d optimal (hence serrated) parameters', size(data,1));
	end

end