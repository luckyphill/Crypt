function cryptName = getCryptName(crypt)

	switch crypt
		case 1
			cryptName = 'MouseColonDesc';
		case 2
			cryptName = 'MouseColonAsc';
		case 3
			cryptName = 'MouseColonTrans';
		case 4
			cryptName = 'MouseColonCaecum';
		case 5
			cryptName = 'RatColonDesc';
		case 6
			cryptName = 'RatColonAsc';
		case 7
			cryptName = 'RatColonTrans';
		case 8
			cryptName = 'RatColonCaecum';
		case 9
			cryptName = 'HumanColon';
		otherwise
			error('Crypt type not found');
	end
end