function loop_simulation(obj, time, n, np, ees, ms, vf, cct, wt)


	obj = str2func(obj);
	for e = (ees-35):5:(ees+35)
		for m = (ms-35):5:(ms+35)
			simulate(obj, time, n, np, ees, ms, vf, cct, wt);
		end
	end


end