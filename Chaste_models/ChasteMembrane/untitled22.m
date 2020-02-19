
mut = {'nM', 'npM', 'eesM', 'msM', 'cctM', 'wtM', 'vfM'};
for i = [1:6, 8]
    for j = 1:7
        obj = basinAnalysisLine(i, mut{j}, 0.5:0.01:1.5);
        obj.saveCountPlot();
        obj.saveDivisionPlot();
    end
end

        
        
        