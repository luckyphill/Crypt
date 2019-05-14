function loop_simulation(obj, time, n, np, ees, ms, vf, cct, wt)


	for e = (ees-35):5:(ees+35)
		for m = (ms-35):5:(ms+35)
			fprintf('\n Running simulation for %s with parameters n=%g, np=%g, ees=%g, ms=%g, vf=%g, cct=%g, wt=%g\n',func2str(obj), n, np, e, m, vf, cct, wt)
			simulate(obj, time, n, np, e, m, vf, cct, wt);
		end
	end


end