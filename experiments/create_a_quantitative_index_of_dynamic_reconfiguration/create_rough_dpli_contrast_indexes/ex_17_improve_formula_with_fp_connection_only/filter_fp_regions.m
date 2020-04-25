function [f_dpli, f_x_region, f_y_region] = filter_fp_regions(dpli, region)
% FILTER FP REGIONS this will filter a dpli matrix by keeping only the
% fronto-parietal connection
%   This function is needed to only keep the frontal regions on the y axis
%   and the parietal regions on the x axis
%
%   input:
%   dpli: a N*N matrix
%   regions: category of regions 
%
%   output:
%   f_dpli: a N*M matrix with N being frontal and M being a parietal
%   regions
%   f_x_region/f_y_region: the x and y axis with the frontal/parietal
%   labels
    %% Variable Initiatlization
    num_channels = length(dpli);
    frontal_index = [];
    parietal_index = [];
    
    % Iterate over each channels and look at the regions
    for l = 1:num_channels
        label = region{l};
        
        % If the region is frontal or parietal we keep them
        if strcmp(label, "frontal")
            frontal_index = [frontal_index l];
        end
        
        if strcmp(label, "parietal")
            parietal_index = [parietal_index l];
        end
    end
    
    % Create a subset matrix which will contains only the fronto-parietal
    % connection
    f_dpli = dpli(frontal_index, parietal_index);
    f_x_region = region(parietal_index);
    f_y_region = region(frontal_index);
end