%% Yacine Mahdid April 23 2020
% This script is addressing this issue: https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/16

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/contrast_matrix/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/experiments/create_a_quantitative_index_of_dynamic_reconfiguration/create_rough_dpli_contrast_indexes/data/bp_to_egi_mapping_yacine.csv";

% Esthetic Variables
COLOR = "hot";

% Here we will skip participant 17 since we do not have recovery
P_ID = {'WSAS02','WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
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
    
    % Get the common location
    [common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, recovery_r_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);
    
    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);
    recovery_f_dpli = filter_matrix(recovery_r_dpli, recovery_r_location, common_location);
    
    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    baseline_vs_recovery = abs(baseline_f_dpli - recovery_f_dpli);
    baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);
    recovery_vs_anesthesia = abs(recovery_f_dpli - anesthesia_f_dpli);
    
    
    % Create the directory to save the data
    create_dir_if_not_exist(OUT_DIR, participant);
    
    % Save BvR
    filename = strcat(OUT_DIR, filesep, participant, filesep, "baseline_vs_recovery.mat");
    save(filename, 'baseline_vs_recovery');
    
    % Save BvA
    filename = strcat(OUT_DIR, filesep, participant, filesep, "baseline_vs_anesthesia.mat");
    save(filename, 'baseline_vs_anesthesia');
    
    % Save RvA
    filename = strcat(OUT_DIR, filesep, participant, filesep, "recovery_vs_anesthesia.mat");
    save(filename, 'recovery_vs_anesthesia');
end

function create_dir_if_not_exist(parent_dir, new_dir_name)
% CREATE DIR IF NOT EXIST helper function to wrap the mkdir function into a
% try catch to avoid crashes if the directory already exist.
%   This will allow to run this script multiple time and simply overwrite
%   the previous data without big red error messages.
%
%   input:
%   parent_dir: the directory where we want to create the new directory
%   new_dir: the name of the directory we want to create
    try
        mkdir(parent_dir, new_dir_name)
    catch  
        disp(strcat("Directory ", new_dir_name, " already exist."))
    end
end