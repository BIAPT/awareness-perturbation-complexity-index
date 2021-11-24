function [r_dpli, r_location, r_regions] = process_dpli(filename)
% PROCESS dPLI is a helper function to load and process the dPLI given a
% filename
%
% filename: filename of the dPLI data to load and process
   %Load the data at the right spot on disk
   data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.avg_dpli;
   location = data.result_dpli.metadata.channels_location;

   % Reordering the channels and returning
   [r_dpli, r_location, r_regions] = reorder_channels(dpli, location, ...
                                                     'biapt_egi129.csv');
end