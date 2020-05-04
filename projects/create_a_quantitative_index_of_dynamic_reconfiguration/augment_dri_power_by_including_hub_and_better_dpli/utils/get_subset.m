function [common_labels, common_region] = get_subset(baseline_location, anesthesia_location, recovery_location, baseline_regions, anesthesia_regions, recovery_regions)
% GET SUBSET is a helper function to get the subset of all the regions that
% are common across all three states
% 
% baseline_location, anesthesia_location, recovery_location: are all three
% array of structure containing channels location (eeglab way)
% baseline_regions, anesthesia_regions, recovery_regions: cell array of
% labels for the FTCPO ordering

    %% Variable initialization
    common_labels = {};
    common_region = {};
    
    % concatenate all three states to be easier to iterate through
    all_location = [baseline_location recovery_location anesthesia_location];
    all_regions = [baseline_regions, anesthesia_regions, recovery_regions];


    % Iterate over each label in the all_location array to find common
    % location in all three states
    for l = 1:length(all_location)
        % Get the current label and region
        label = all_location{l};
        region = all_regions{l};
        
        % get the Index of the label in each states (if exist)
        b_index = get_label_index(label, baseline_location);
        a_index = get_label_index(label, anesthesia_location);
        r_index = get_label_index(label, recovery_location);
        
        % to be common all index need to be != 0
        if(b_index ~= 0 && a_index ~= 0 && r_index ~= 0)
           % Save the location and the region
           common_labels = [common_labels all_location(l)];
           common_region = [common_region region];
           
           % Remove the data from the states to prevent duplication
           baseline_location(b_index) = [];
           anesthesia_location(a_index) = [];
           recovery_location(r_index) = [];
        end
    end

end