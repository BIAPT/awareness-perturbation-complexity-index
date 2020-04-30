function [r_wpli, r_labels, r_regions, r_location] = process_bp_wpli(filename, map_file)
% PROCESS BP wPLI is a helper function to load the data from the filename,
% translate it in the right format (bp -> egi) nomenclature, to reorder the
% channels and to finally filter out non-scalp electrodes
%
% filename: the location on disk of where to find the dpli matrix
% map_file: the name of the mapping file that is used for the convertion
% from bp to egi nomenclature.
    
   % Load and extract the data/channel location
   data = load(filename);
   wpli = data.result_wpli.data.avg_wpli;
   location = data.result_wpli.metadata.channels_location;
   
   % Load the convertion table from bp_location -> egi_location
   % nomenclature
   bp_to_egi_convertion_table = readtable(map_file);
   bp_labels = bp_to_egi_convertion_table.bp_location;
   egi_labels = bp_to_egi_convertion_table.egi_location;
   
   % Iterate over the location file and figure out if we need to remove
   % a given channel
   index_to_remove = [];
   for i = 1:length(location)
      label = location(i).labels; 
      index = get_label_index(label, bp_labels);
      
      % Removing all the channels that are not in the convertion table
      % i.e. non-scalp channels
      if index == 0
         index_to_remove = [index_to_remove i];
      else 
         % Modify the label for this particular channel
         location(i).labels = egi_labels{index};
      end
      
   end
   
   % Delete struct at given location to remove
   location(index_to_remove) = [];
   
   % Fix the dpli matrix
   wpli(index_to_remove,:) = [];
   wpli(:, index_to_remove) = [];
   
   % Reorder the channels and return 
   [r_wpli, r_labels, r_regions, r_location] = reorder_channels(wpli, location, ...
                                                     'biapt_egi129.csv');
end