function params = getCryptParams(crypt)

	cryptName = getCryptName(crypt);

	param_file = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/test/params/', cryptName, '.txt'];

	params = csvread(param_file);

end