%% Yacine Mahdid March 27 2020
% This script is addressing the task https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/8

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";

% Esthetic Variables
COLOR = "hot";

% Here we will skip participant 17 since we do not have recovery
% And participant 02 since it's headset nomenclature is different.
P_ID = {'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

% this is used in the definition of the similarity matrix to scale the tanh function
SHIFT_WEIGHT = 2; 

%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(participant);

    % Process each of the three states
    [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
    [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));
    [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_dpli.mat'));
    
    % Get the common location
    [common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, recovery_r_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);
    
    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);
    recovery_f_dpli = filter_matrix(recovery_r_dpli, recovery_r_location, common_location);
    
    % Calculate the similarity matrix
    % similarity matrix is more complicated than in the previous iteration,
    % it should be weighting more the shift from front/back of the brain
    baseline_vs_recovery = calculate_sim_matrix(baseline_f_dpli, recovery_f_dpli, SHIFT_WEIGHT);
    baseline_vs_anesthesia = calculate_sim_matrix(baseline_f_dpli, anesthesia_f_dpli, SHIFT_WEIGHT);
    recovery_vs_anesthesia = calculate_sim_matrix(recovery_f_dpli, anesthesia_f_dpli, SHIFT_WEIGHT);
    
    % This vector is used for nomarlization
    sim_all = [baseline_vs_recovery(:); baseline_vs_anesthesia(:); recovery_vs_anesthesia(:)];

    % Here we create the figure that will be saved
    handle = figure;
    subplot(1,3,1)
    plot_pli(baseline_vs_recovery, common_region, sim_all, COLOR)
    title(strcat(participant, " alpha baseline vs recovery"));
    subplot(1,3,2)
    plot_pli(baseline_vs_anesthesia, common_region, sim_all, COLOR)
    title(strcat(participant, " alpha baseline vs anesthesia"));
    subplot(1,3,3)
    plot_pli(recovery_vs_anesthesia, common_region, sim_all, COLOR)
    title(strcat(participant, " alpha recovery vs anesthesia"));
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    % Here we save the figure to the disk
    filename = strcat(OUT_DIR, participant, "_alpha_sim_dpli_augmented.png");
    saveas(handle,filename);
    close all;    
end