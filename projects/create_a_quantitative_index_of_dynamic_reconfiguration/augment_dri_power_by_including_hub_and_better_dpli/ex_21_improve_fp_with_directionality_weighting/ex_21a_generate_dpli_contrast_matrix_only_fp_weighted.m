%% Yacine Mahdid April 29 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/21

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/fp_only/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/experiments/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

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
    
    % This vector is used for nomarlization
    sim_all = [baseline_vs_recovery(:); baseline_vs_anesthesia(:); recovery_vs_anesthesia(:)];

    % Here we create the figure that will be saved
    handle = figure;
    subplot(1,3,1)
    plot_pli_diff_axis(baseline_vs_recovery, x_region, y_region, sim_all, COLOR)
    title(strcat(participant, " alpha (only FP) baseline vs recovery"));
    subplot(1,3,2)
    plot_pli_diff_axis(baseline_vs_anesthesia, x_region, y_region, sim_all, COLOR)
    title(strcat(participant, " alpha (only FP) baseline vs anesthesia"));
    subplot(1,3,3)
    plot_pli_diff_axis(recovery_vs_anesthesia, x_region, y_region, sim_all, COLOR)
    title(strcat(participant, " alpha (only FP) recovery vs anesthesia"));
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    filename = strcat(OUT_DIR, participant, "_alpha_contrast_fp_dpli.png");
    saveas(handle,filename);
    close all;    
end