function [r_wpli, r_location, r_regions] = process_wpli(filename)
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
   [r_wpli, r_location, r_regions] = reorder_channels(wpli, location, ...
                                                     'biapt_egi129.csv');
end