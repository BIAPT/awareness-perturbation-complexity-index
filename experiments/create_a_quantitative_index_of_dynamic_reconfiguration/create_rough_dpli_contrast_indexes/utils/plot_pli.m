function plot_pli(pli,regions,pli_all, color)
% PLOT PLI is a helper function to plot a pli/dpli matrix with the right
% format. It normalize the colormap between +-3 std deviation from the
% pli_all mean (which is all the pli values to be considered)
%
% pli: a N*N square matrix for pli or dpli
% regions: the regions label to put on the x and y axis
% pli_all: all of the pli values for the normalization
% color: this is the color we want for the matrix (jet or hot is usually a
% good default choice)
    imagesc(pli);
    xtickangle(90)
    xticklabels(regions);
    yticklabels(regions);  
    xticks(1:length(regions));
    yticks(1:length(regions));
    min_color = mean(pli_all) - 3*(std(pli_all));
    max_color = mean(pli_all) + 3*(std(pli_all));
    caxis([min_color max_color])
    colormap(color);    
end