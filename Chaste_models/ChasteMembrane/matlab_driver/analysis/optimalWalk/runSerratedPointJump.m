Pvalues = {};
for i = 1:8
    for j = 1:27
        try
            b = serratedPointJump2(i, j, 1, 'varargin');
            b.tTestResults();
            Pvalues{i,j} = [b.pValues];
            
            b = serratedPointJump2(i, j, 2, 'varargin');
            b.tTestResults();
            Pvalues{i,j} = [Pvalues{i,j}; b.pValues];
        end
    end
end