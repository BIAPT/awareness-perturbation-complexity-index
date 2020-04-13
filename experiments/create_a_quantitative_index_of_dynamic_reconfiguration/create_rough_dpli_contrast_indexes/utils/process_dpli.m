function [r_dpli, r_location, r_regions] = process_dpli(filename)
% PROCESS dPLI is a helper function to load and process the dPLI given a
% filename
%
% filename: filename of the dPLI data to load and process

    % If we are dealing with WSAS02 we need to go through process_bp_dpli 
    % instead of the normal process
    % TODO: fix this
    if contains(filename, 'WSAS02')
       MAP_FILE = "bp_to_egi_mapping.csv";
       [r_dpli, r_location, r_regions] = process_bp_dpli(filename, MAP_FILE);
       return
    end

   %Load the data at the right spot on disk
   data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.avg_dpli;
   location = data.result_dpli.metadata.channels_location;

   % Reordering the channels and returning
   [r_dpli, r_location, r_regions] = reorder_channels(dpli, location, ...
                                                     'biapt_egi129.csv');
end