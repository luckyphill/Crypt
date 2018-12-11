function p = grow(p)
	% For each newly divided cell, increases the spring length between them

	p.rest_lengths(p.rest_lengths<p.l) = p.rest_lengths(p.rest_lengths<p.l) + p.dt * (p.l - p.division_rest_length)/p.growth_time;

	assert(prod(p.rest_lengths > p.l) == 0);
end