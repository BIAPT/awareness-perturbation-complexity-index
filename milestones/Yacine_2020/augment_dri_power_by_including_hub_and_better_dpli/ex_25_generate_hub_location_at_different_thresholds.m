%% Yacine Mahdid April 29 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/24

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/hub_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

% esthetic variables
COLOR = "jet";

% We wil use all participant here
P_ID = {'WSAS02', 'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS17', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

% Binary thresholds
binary_thresholds = [0.1, 0.2, 0.3];
%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure. We will also be iterating over the thresholds and
% generating binarize wpli matrix at these different values.
for b = 1:length(binary_thresholds)
    threshold = binary_thresholds(b);
    
    for p = 1:length(P_ID)
        participant = P_ID{p};
        disp(participant);

        % Process each of the three states
        if strcmp(participant, "WSAS02")
            [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'), MAP_FILE);
            [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'), MAP_FILE);
            [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'), MAP_FILE);
        else
            [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'));
            [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'));

            if strcmp(participant, "WSAS17") == 0
                [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'));              
            end
        end
        
        % Binarize the three states and calculate the hub location
        [baseline_r_wpli] = binarize_matrix(threshold_matrix(baseline_r_wpli, threshold));
        [~, baseline_weights] = binary_hub_location(baseline_r_wpli, baseline_r_location);
        
        [anesthesia_r_wpli] = binarize_matrix(threshold_matrix(anesthesia_r_wpli, threshold));
        [~, anesthesia_weights] = binary_hub_location(anesthesia_r_wpli, anesthesia_r_location);
        
        recovery_weights = [];
        if strcmp(participant, "WSAS17") == 0
            [recovery_r_wpli] = binarize_matrix(threshold_matrix(recovery_r_wpli, threshold));        
            [~, recovery_weights] = binary_hub_location(recovery_r_wpli, recovery_r_location);
        end
        
        % Create the 2 or 3 subplot vertical figure for comparions
        % depending if this is participant WSAS17 or not (no recovery)
        num_sub = 3;
        if strcmp(participant,"WSAS17")
            num_sub = 2;
        end

        % This vector is used for nomarlization
        weights_all = [baseline_weights(:); anesthesia_weights(:); recovery_weights(:)];
    
        handle = figure;
        subplot(1,num_sub,1)
        plot_hub_location(baseline_weights, baseline_r_location,weights_all, COLOR)
        title(sprintf("%s alpha hub b(%.1f) at baseline",participant,threshold));
        subplot(1,num_sub,2)
        plot_hub_location(anesthesia_weights, anesthesia_r_location, weights_all, COLOR)
        title(sprintf("%s alpha hub b(%.1f) at anesthesia",participant,threshold));
        if strcmp(participant,"WSAS17") == 0
            subplot(1,num_sub,3)
            plot_hub_location(recovery_weights, recovery_r_location, weights_all, COLOR)
            title(sprintf("%s alpha hub b(%.1f) at recovery",participant,threshold));
        end
        colorbar;
        set(handle, 'Position', [70,152,1527,589]);

        % Save the figure at the right spot in disk
        filename = sprintf("%s%s_alpha_hub_%.1f.png",OUT_DIR,participant,threshold);
        saveas(handle,filename);
        close all;
    end
end

function plot_hub_location(weights, channels_location, weights_all, color)
%PLOT HUB LOCATION will create a topographic map of the hub location
%weights
%   This function is using the built-in eeglab plotting capabilities to
%   make a topographic map. This is mostly a wrapper function so that the
%   code is easier to read without having to worry about the eeglab parameters.
%
%   input:
%   weights: a 1*N vector where N is the hub location weights for a given
%   channel
%   channels_location: this is a 1*N struct array containing eeglab channel
%   location
%   color: This is an visual parameters for the plot
    topoplot(weights,channels_location,'maplimits','absmax', 'electrodes', 'off');
    colormap(color);
    min_color = mean(weights_all) - 3*(std(weights_all));
    max_color = mean(weights_all) + 3*(std(weights_all));
    caxis([min_color max_color])
end