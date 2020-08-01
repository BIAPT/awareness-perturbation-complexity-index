%% Yacine Mahdid April 25 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/14

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/wsas17_result/";

% Esthetic Variables
COLOR = "hot";

% Participant 17
participant = "WSAS17";

%% Creating the figure

[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
[anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));

% Get the common location
[common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, baseline_r_regions, anesthesia_r_regions);

% Filter the matrices to have the same size
baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);

% Filter the matrices to keep only the frontal and parietal regions
[baseline_f_dpli, x_region, y_region] = filter_fp_regions(baseline_f_dpli, common_region);
[anesthesia_f_dpli, ~, ~] = filter_fp_regions(anesthesia_f_dpli, common_region);

% Calculate a contrast matrix, this is different than before.
% now we want to have high score for large differences and low
% score for similarities
baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);

% This vector is used for nomarlization
sim_all = baseline_vs_anesthesia(:);

% Here we create the figure that will be saved
handle = figure;
plot_pli_diff_axis(baseline_vs_anesthesia, x_region, y_region, sim_all, COLOR)
title(strcat(participant, " alpha (only FP) baseline vs anesthesia"));
colorbar;
set(handle, 'Position', [70,152,1527,589]);

filename = strcat(OUT_DIR, participant, "_alpha_contrast_fp_dpli.png");
saveas(handle,filename);
close all;