function [r_wpli, r_labels, r_regions, r_location] = process_wpli(filename)
% PROCESS wPLI is a helper function to load and process the wPLI given a
% filename
%
% filename: filename of the dPLI data to load and process
   %Load the data at the right spot on disk
   data = load(filename);

   % Extracting the data and channel location
   wpli = data.result_wpli.data.avg_wpli;
   location = data.result_wpli.metadata.channels_location;

   % Reordering the channels and returning
   [r_wpli, r_labels, r_regions, r_location] = reorder_channels(wpli, location, ...
                                                     'biapt_egi129.csv');
end