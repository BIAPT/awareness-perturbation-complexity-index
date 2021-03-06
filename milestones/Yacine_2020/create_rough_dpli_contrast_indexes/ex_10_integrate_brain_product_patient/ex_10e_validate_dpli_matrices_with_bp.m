%% Yacine Mahdid April 10 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/10

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

% Esthetic Variables
COLOR = "jet";

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
    
    % This vector is used for nomarlization
    dpli_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Create the figure
    handle = figure;
    subplot(1,3,1)
    plot_pli(baseline_r_dpli, baseline_r_regions, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at baseline"));
    subplot(1,3,2)
    plot_pli(anesthesia_r_dpli, anesthesia_r_regions, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at anesthesia"));
    subplot(1,3,3)
    plot_pli(recovery_r_dpli, recovery_r_regions, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at recovery"));
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    % Save it to disk
    filename = strcat(OUT_DIR, participant, "_alpha_dpli.png");
    saveas(handle,filename);
    close all;
end