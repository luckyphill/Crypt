function p = slough(p)

% A function to kill off the cells that go past the top
% Cell positions at the end of the vector are the highest, so start from
% end and as soon as any cell is not past the top we are done

for i = p.n:-1:1
    if p.x(end,i) > p.top
        p.n = p.n - 1;
        p.n_dead = p.n_dead + 1;
        %fprintf('Cell %d died at t = %.2f\n', i,p.t);
        p.x = p.x(1:p.n);
        p.v = p.v(1:p.n);
        p.rest_lengths = p.rest_lengths(1:p.n-1);
    else
        break;
    end
end


end