%% Yacine Mahdid April 08 2020
% This script is addressing a part of this task : https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/10

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";
MAP_FILE = "bp_to_egi_mapping.csv";

%% Fixing the participant data
[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_bp_dpli(strcat(IN_DIR,"WSAS02",filesep,'baseline_alpha_dpli.mat'), MAP_FILE);

% Here this is what we will be modifying to get a translated version
% of the bp headset
function [r_dpli, r_location, r_regions] = process_bp_dpli(filename, map_file)
   data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.avg_dpli;
   location = data.result_dpli.metadata.channels_location;
   
   % At this point we have the bp_location
   bp_to_egi_convertion_table = readtable(map_file);
   bp_labels = bp_to_egi_convertion_table.bp_location;
   egi_labels = bp_to_egi_convertion_table.egi_location;
   
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
   
   % Fix the location structure array
   location(index_to_remove) = [];
   % Fix the dpli matrix
   dpli(index_to_remove,:) = [];
   dpli(:, index_to_remove) = [];
   
   [r_dpli, r_location, r_regions] = reorder_channels(dpli, location, 'biapt_egi129.csv');
end