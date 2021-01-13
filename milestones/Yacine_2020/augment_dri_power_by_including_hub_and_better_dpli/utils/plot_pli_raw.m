function plot_pli_raw(pli,regions, color)
% PLOT PLI RAW is a helper function to plot a pli/dpli matrix with the right
% format. No normalization is done here
%
% pli: a N*N square matrix for pli or dpli
% regions: the regions label to put on the x and y axis
% color: this is the color we want for the matrix (jet or hot is usually a
% good default choice)
    imagesc(pli);
    xtickangle(90)
    xticklabels(regions);
    yticklabels(regions);  
    xticks(1:length(regions));
    yticks(1:length(regions));
    colormap(color);    
end