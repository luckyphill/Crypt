function params = getSerratedParams2(crypt, version,n)

	cryptName = getCryptName(crypt);

	param_file = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/optimal/serrated/', cryptName,'_',num2str(n),'.txt'];

	data = csvread(param_file);

	try
		params = data(version,:);
	catch
		error('There are only %d optimal (hence serrated) parameters', size(data,1));
	end

end