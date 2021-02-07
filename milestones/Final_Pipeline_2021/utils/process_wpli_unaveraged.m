function [wpli, location] = process_wpli_unaveraged(filename)
% PROCESS wPLI is a helper function to load and process the wPLI given a
% filename
%
% filename: filename of the dPLI data to load and process
   %Load the data at the right spot on disk
   data = load(filename);

   % Extracting the data and channel location
   wpli = data.result_wpli.data.wpli;
   location = data.result_wpli.metadata.channels_location;
   
   
end