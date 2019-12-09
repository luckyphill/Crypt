

funcs = {	@MouseColonDesc
			@MouseColonAsc
			@MouseColonTrans
			@MouseColonCaecum
			@RatColonDesc
			@RatColonAsc
			@RatColonTrans
			@RatColonCaecum
			@HumanColon};

for i = 1:length(funcs)
	best(i).func = funcs{i};

	[best(i).penalty, best(i).params] = findBestLHSResult(funcs{i});
end