function [dpli, location] = process_dpli_unaveraged(filename)
% PROCESS wPLI is a helper function to load and process the wPLI given a
% filename
%
% filename: filename of the dPLI data to load and process
   %Load the data at the right spot on disk
   data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.dpli;
   location = data.result_dpli.metadata.channels_location;
   
   
end