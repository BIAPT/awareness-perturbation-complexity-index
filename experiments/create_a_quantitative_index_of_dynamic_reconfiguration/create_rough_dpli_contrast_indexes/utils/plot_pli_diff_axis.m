function plot_pli_diff_axis(pli,x_regions, y_regions, pli_all, color)
% PLOT PLI DIFF AXIS is a helper function to plot a pli/dpli matrix with the right
% format. It normalize the colormap between +-3 std deviation from the
% pli_all mean (which is all the pli values to be considered)
% the difference between this and the other plot_pli is that we have a
% different x and y regions
%
% pli: a N*N square matrix for pli or dpli
% regions: the regions label to put on the x and y axis
% pli_all: all of the pli values for the normalization
% color: this is the color we want for the matrix (jet or hot is usually a
% good default choice)
    imagesc(pli);
    xtickangle(90)
    xticklabels(x_regions);
    yticklabels(y_regions);  
    xticks(1:length(x_regions));
    yticks(1:length(y_regions));
    min_color = mean(pli_all) - 3*(std(pli_all));
    max_color = mean(pli_all) + 3*(std(pli_all));
    caxis([min_color max_color])
    colormap(color);    
end