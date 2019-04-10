for i = 18231:18262
    title1 = sprintf('Data 1 step %d',i);
    title2 = sprintf('Data 2 step %d',i);
    visualise_cells(data1(i,2:end),title1);
    visualise_cells(data2(i,2:end),title2);
end
