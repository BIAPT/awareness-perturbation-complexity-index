%% Yacine Mahdid April 25 2020
% This script is addressing the task https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/14

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/wsas17_result/";

% esthetic variables
COLOR = "jet";

% Here we will only lookat participant 17
participant = "WSAS17";

%% Creating the figure

% Process each of the two states
[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
[anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));

% This vector is used for nomarlization
dpli_all = [baseline_r_dpli(:); anesthesia_r_dpli(:)];

% Creat the 3 subplot vertical figure for comparions
handle = figure;
subplot(1,2,1)
plot_pli(baseline_r_dpli, baseline_r_regions, dpli_all, COLOR)
title(strcat(participant, " alpha dpli at baseline"));
subplot(1,2,2)
plot_pli(anesthesia_r_dpli, anesthesia_r_regions, dpli_all, COLOR)
title(strcat(participant, " alpha dpli at anesthesia"));
colorbar;
set(handle, 'Position', [70,152,1527,589]);

% Save the figure at the right spot in disk
filename = strcat(OUT_DIR, participant, "_alpha_dpli.png");
saveas(handle,filename);
close all;