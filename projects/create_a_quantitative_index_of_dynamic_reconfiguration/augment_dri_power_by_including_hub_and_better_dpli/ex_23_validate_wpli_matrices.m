%% Yacine Mahdid April 29 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/23

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/hub_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

% esthetic variables
COLOR = "jet";

% We wil use all participant here
P_ID = {'WSAS02', 'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS17', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(participant);

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_location, baseline_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'), MAP_FILE);
        [anesthesia_r_wpli, anesthesia_r_location, anesthesia_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'), MAP_FILE);
        [recovery_r_wpli, recovery_r_location, recovery_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_location, baseline_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'));
        [anesthesia_r_wpli, anesthesia_r_location, anesthesia_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'));
        
        if strcmp(participant, "WSAS17")
           recovery_r_wpli = [];
        else
            [recovery_r_wpli, recovery_r_location, recovery_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'));              
        end
    end
    
    % This vector is used for nomarlization
    dpli_all = [baseline_r_wpli(:); anesthesia_r_wpli(:); recovery_r_wpli(:)];

    % Creat the 2 or 3 subplot vertical figure for comparions
    % depending if this is participant WSAS17 or not (no recovery)
    num_sub = 3;
    if strcmp(participant,"WSAS17")
        num_sub = 2;
    end
    
    handle = figure;
    subplot(1,num_sub,1)
    plot_pli(baseline_r_wpli, baseline_r_regions, dpli_all, COLOR)
    title(strcat(participant, " alpha wpli at baseline"));
    subplot(1,num_sub,2)
    plot_pli(anesthesia_r_wpli, anesthesia_r_regions, dpli_all, COLOR)
    title(strcat(participant, " alpha wpli at anesthesia"));
    if strcmp(participant,"WSAS17") == 0
        subplot(1,num_sub,3)
        plot_pli(recovery_r_wpli, recovery_r_regions, dpli_all, COLOR)
        title(strcat(participant, " alpha wpli at recovery"));
    end
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    % Save the figure at the right spot in disk
    filename = strcat(OUT_DIR, participant, "_alpha_wpli.png");
    saveas(handle,filename);
    close all;
end

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

function [r_wpli, r_location, r_regions] = process_bp_wpli(filename, map_file)
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
   [r_wpli, r_location, r_regions] = reorder_channels(wpli, location, ...
                                                     'biapt_egi129.csv');
end