%% Yacine Mahdid April 25 2020
% This script is addressing the task https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/17

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/wsas17_result/";

% Esthetic Variables
COLOR = "hot";

% Here we will skip participant 17 since we do not have recovery
participant = "WSAS17";

%% Creating the figure
[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
[anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));

% Get the common location
[common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, baseline_r_regions, anesthesia_r_regions);

% Filter the matrices to have the same size
baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);

% Calculate a contrast matrix, this is different than before.
% now we want to have high score for large differences and low
% score for similarities
baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);

% This vector is used for nomarlization
sim_all = baseline_vs_anesthesia(:);

% Here we create the figure that will be saved
handle = figure;
plot_pli(baseline_vs_anesthesia, common_region, sim_all, COLOR)
title(strcat(participant, " alpha baseline vs anesthesia"));
colorbar;
set(handle, 'Position', [70,152,1527,589]);

filename = strcat(OUT_DIR, participant, "_alpha_contrast_dpli.png");
saveas(handle,filename);
close all;    