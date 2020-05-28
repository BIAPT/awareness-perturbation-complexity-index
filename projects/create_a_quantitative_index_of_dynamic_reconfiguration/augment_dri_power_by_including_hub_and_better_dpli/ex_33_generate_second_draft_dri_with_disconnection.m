%% Yacine Mahdid May 04 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/33

%% Experiment Variable
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

% Here we will skip participant 17 since we do not have recovery
P_ID = {'WSAS02','WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};
P_LABEL = [1,0,1,0,0,0,0,0,1,1,0]; %here 1 means recover and 0 means not recover

COLOR = 'jet';

threshold_range = 0.70:-0.01:0.01; % More connected to less connected


%% Calculate the dpli-dris
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_dris_3 = zeros(1, length(P_ID));
for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(participant);

    % Process each of the three states, since participant WSAS02 is special
    % in the sense that is has the Brain Product headset we check for it
    % to processing it correctly
    if strcmp(participant, "WSAS02")
        [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_bp_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'), MAP_FILE);
        [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_bp_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'), MAP_FILE);
        [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_bp_dpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_dpli.mat'), MAP_FILE);
    else
        [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
        [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));
        [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_dpli.mat'));        
    end
    
    
    % This vector is used for nomarlization
    sim_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Get the common location
    [common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, recovery_r_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);
    
    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);
    recovery_f_dpli = filter_matrix(recovery_r_dpli, recovery_r_location, common_location);
    
    % Filter the matrices to keep only the frontal and parietal regions
    [baseline_f_dpli, x_region, y_region] = filter_fp_regions(baseline_f_dpli, common_region);
    [anesthesia_f_dpli, ~, ~] = filter_fp_regions(anesthesia_f_dpli, common_region);
    [recovery_f_dpli, ~, ~] = filter_fp_regions(recovery_f_dpli, common_region);
    
    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    baseline_vs_recovery = abs(baseline_f_dpli - recovery_f_dpli);
    baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);
    recovery_vs_anesthesia = abs(recovery_f_dpli - anesthesia_f_dpli);
    
    % Calculate the dpli-dri with w1, w2 and w3
    % Weights for analysis
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    dpli_dris_3(p) = calculate_dpli_dri_3(baseline_vs_recovery, baseline_vs_anesthesia, recovery_vs_anesthesia, w1, w2, w3);
    % normalize it so that headset with more channels aren't artificially
    % inflated
    dpli_dris_3(p) = dpli_dris_3(p)/length(baseline_vs_recovery(:));
end

% At this point we have the dpli_dri_3
%% Calculate the Hub-DRI
hub_dris_1 = zeros(1, length(P_ID));
for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(strcat("Participant: ", participant));

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'), MAP_FILE);
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'), MAP_FILE);
        [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'));
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'));
        [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'));              
    end

    % Filter the matrix to have the same size
    % Get the common location
    [common_labels, common_region] = get_subset(baseline_r_labels, anesthesia_r_labels, recovery_r_labels, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);           
    % Filter the matrices to have the same size
    baseline_f_wpli = filter_matrix(baseline_r_wpli, baseline_r_labels, common_labels);
    anesthesia_f_wpli = filter_matrix(anesthesia_r_wpli, anesthesia_r_labels, common_labels);
    recovery_f_wpli = filter_matrix(recovery_r_wpli, recovery_r_labels, common_labels);

    % Regenerate the common location from the common labels that was
    % lost in the get_subset process
    common_location = generate_common_location(common_labels, baseline_r_labels, baseline_r_location);

    % Binarize the three states and calculate the hub location
    disp("Baseline Threshold: ")
    [threshold] = find_smallest_connected_threshold(baseline_f_wpli, threshold_range);
    [baseline_b_wpli] = binarize_matrix(threshold_matrix(baseline_f_wpli, threshold));
    [~, baseline_weights] = binary_hub_location(baseline_b_wpli, common_location);
    baseline_norm_weights = (baseline_weights - mean(baseline_weights))  / std(baseline_weights);


    disp("Anesthesia Threshold: ")    
    [threshold] = find_smallest_connected_threshold(anesthesia_f_wpli, threshold_range);
    [anesthesia_b_wpli] = binarize_matrix(threshold_matrix(anesthesia_f_wpli, threshold));
    [~, anesthesia_weights] = binary_hub_location(anesthesia_b_wpli, common_location);
    anesthesia_norm_weights = (anesthesia_weights - mean(anesthesia_weights))  / std(anesthesia_weights);
    
    disp("Recovery Threshold: ")
    [threshold] = find_smallest_connected_threshold(recovery_f_wpli, threshold_range);
    [recovery_b_wpli] = binarize_matrix(threshold_matrix(recovery_f_wpli, threshold));        
    [~, recovery_weights] = binary_hub_location(recovery_b_wpli, common_location);
    recovery_norm_weights = (recovery_weights - mean(recovery_weights))  / std(recovery_weights);

    
    % Calculate the cosine similarities between each of the states
    baseline_vs_anesthesia = vector_cosine_similarity(baseline_norm_weights, anesthesia_norm_weights);
    baseline_vs_recovery = vector_cosine_similarity(baseline_norm_weights, recovery_norm_weights);
    recovery_vs_anesthesia = vector_cosine_similarity(recovery_norm_weights, anesthesia_norm_weights);

    disp(strcat("Cosine BvA: ", string(baseline_vs_anesthesia)))
    disp(strcat("Cosine BvR: ", string(baseline_vs_recovery)))
    disp(strcat("Cosine RvA: ", string(recovery_vs_anesthesia)))
    
    disp("-----")
    % Calculate the hub dri
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    hub_dris_1(p) = w1*baseline_vs_recovery - (w2*baseline_vs_anesthesia + w3*recovery_vs_anesthesia);
end

%% Create the figure
% Plot figure for the dpli-dri
handle = figure;
scatter(dpli_dris_3,hub_dris_1,[],P_LABEL,'filled')
xlabel("dPLI-DRI");
ylabel("Hub-DRI");
colormap(COLOR);
title(sprintf("WSAS Both DRI for alpha at dynamic threshold (attempt #3)",threshold));

% Save it to disk
filename = sprintf("%sboth_dri_3.png",OUT_DIR,threshold);
saveas(handle,filename);
close all; 

function [common_location] = generate_common_location(common_labels, labels, location)
% GENERATE COMMON LOCATION the purpose of this function is to regenerate
% the channels location that were lost when calling the get_subset
% function.
%   When we call the get_subset function used in the previous dpli-dri
%   analysis we do not have any channels location information. This was not
%   needed since the dpli analysis is agnostic of where in the brain the
%   channels are. However, for the hub analysis this is an important
%   information. Here we take the common_labels that were generated by
%   get_subset and we regenerate the channels location using the location
%   from one of the state
%
%   input:
%   common_labels: A cell array containing all the labels that are common
%   everywhere in the states
%   location: A given location structure that was used to generate the
%   common_labels.
%
%   output:
%   common_location: this is an array of struct containing all the channels
%   information

    common_location = [];
    for l = 1:length(common_labels)
       label = common_labels{l};
       
       % will find where this label appear in the location
       index = get_label_index(label, labels);
        
       % store the location in the common_location structure
       common_location = [common_location, location(index)];
    end
end


function [smallest_threshold] = find_smallest_connected_threshold(pli_matrix, threshold_range)
    %loop through thresholds
    for j = 1:length(threshold_range) 
        current_threshold = threshold_range(j);
        
        % Thresholding and binarization using the current threshold
        t_network = threshold_matrix(pli_matrix, current_threshold);
        b_network = binarize_matrix(t_network);

        % check if the binary network is disconnected
        % Here our binary network (b_network) is a weight matrix but also an
        % adjacency matrix.
        distance = distance_bin(b_network);

        % Here we check if there is one node that is disconnected
        if(sum(isinf(distance(:))))
            disp(strcat("Final threshold: ", string(threshold_range(j-1))));
            smallest_threshold = threshold_range(j-1);
            break;
        end
    end
end