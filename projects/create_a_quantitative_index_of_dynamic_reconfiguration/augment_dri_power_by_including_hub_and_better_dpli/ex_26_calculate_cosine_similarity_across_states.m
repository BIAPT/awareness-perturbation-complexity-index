%% Yacine Mahdid May 02 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/26

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/hub_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

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
        
        % Filter the matrix to have the same size
        % Get the common location
        if strcmp(participant, "WSAS17") == 0
            [common_labels, common_region] = get_subset(baseline_r_labels, anesthesia_r_labels, recovery_r_labels, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);           
            % Filter the matrices to have the same size
            baseline_f_wpli = filter_matrix(baseline_r_wpli, baseline_r_labels, common_labels);
            anesthesia_f_wpli = filter_matrix(anesthesia_r_wpli, anesthesia_r_labels, common_labels);
            recovery_f_wpli = filter_matrix(recovery_r_wpli, recovery_r_labels, common_labels);

        else
            [common_labels, common_region] = get_subset_wsas17(baseline_r_labels, anesthesia_r_labels, baseline_r_regions, anesthesia_r_regions);
            % Filter the matrices to have the same size
            baseline_f_wpli = filter_matrix(baseline_r_wpli, baseline_r_labels, common_labels);
            anesthesia_f_wpli = filter_matrix(anesthesia_r_wpli, anesthesia_r_labels, common_labels);
        end
        
        
        % Regenerate the common location from the common labels that was
        % lost in the get_subset process
        common_location = generate_common_location(common_labels, baseline_r_labels, baseline_r_location);
        
        % Binarize the three states and calculate the hub location
        [baseline_b_wpli] = binarize_matrix(threshold_matrix(baseline_f_wpli, threshold));
        [~, baseline_weights] = binary_hub_location(baseline_b_wpli, common_location);
        baseline_norm_weights = (baseline_weights - mean(baseline_weights))  / std(baseline_weights);
        
        [anesthesia_b_wpli] = binarize_matrix(threshold_matrix(anesthesia_f_wpli, threshold));
        [~, anesthesia_weights] = binary_hub_location(anesthesia_b_wpli, common_location);
        anesthesia_norm_weights = (anesthesia_weights - mean(anesthesia_weights))  / std(anesthesia_weights);
        
        
        recovery_weights = [];
        if strcmp(participant, "WSAS17") == 0
            [recovery_b_wpli] = binarize_matrix(threshold_matrix(recovery_f_wpli, threshold));        
            [~, recovery_weights] = binary_hub_location(recovery_b_wpli, common_location);
            recovery_norm_weights = (recovery_weights - mean(recovery_weights))  / std(recovery_weights);
        end
        
        
        % Calculate the cosine similarities between each of the states
        baseline_vs_anesthesia = vector_cosine_similarity(baseline_norm_weights, anesthesia_norm_weights);
        if strcmp(participant, "WSAS17") == 0
            baseline_vs_recovery = vector_cosine_similarity(baseline_norm_weights, recovery_norm_weights);
            recovery_vs_anesthesia = vector_cosine_similarity(recovery_norm_weights, anesthesia_norm_weights);
            cosine_similarities = [baseline_vs_recovery, baseline_vs_anesthesia, recovery_vs_anesthesia];
        else
            cosine_similarities = [baseline_vs_anesthesia];
        end

        
        % Create the 2 or 3 subplot vertical figure for comparions
        % depending if this is participant WSAS17 or not (no recovery)

        if strcmp(participant,"WSAS17")
            labels = categorical({'BvA'});
        else
            labels = categorical({'BvR', 'BvA', 'RvA'});
            labels = reordercats(labels,{'BvR', 'BvA', 'RvA'});
        end

        handle = figure;
        bar(labels, cosine_similarities)
        title(sprintf("%s alpha cosine similarity at t=%.1f across all states",participant,threshold))
        xlabel("States Comparison")
        ylabel("Cosine Similarity");
        set(handle, 'Position', [70,152,1527,589]);

        % Save the figure at the right spot in disk
        filename = sprintf("%s%s_alpha_cosine_similarity_%.1f.png",OUT_DIR,participant,threshold);
        saveas(handle,filename);
        close all;
    end
end


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