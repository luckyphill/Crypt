function params = getNewCryptParams(crypt, version)

	cryptName = getCryptName(crypt);

	param_file = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/analysis/basin/', cryptName, '_', num2str(version),'.txt'];

	params = csvread(param_file);

end