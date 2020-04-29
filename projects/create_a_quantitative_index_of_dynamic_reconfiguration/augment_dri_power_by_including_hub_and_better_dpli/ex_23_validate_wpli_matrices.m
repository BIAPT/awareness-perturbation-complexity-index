%% Yacine Mahdid April 29 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/23

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/hub_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";

% esthetic variables
COLOR = "jet";

% We wil use all participant here
P_ID = {'WSAS02', 'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS17', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(participant);

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_location, baseline_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'), MAP_FILE);
        [anesthesia_r_wpli, anesthesia_r_location, anesthesia_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'), MAP_FILE);
        [recovery_r_wpli, recovery_r_location, recovery_r_regions] = process_bp_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_location, baseline_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_wpli.mat'));
        [anesthesia_r_wpli, anesthesia_r_location, anesthesia_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_wpli.mat'));
        
        if strcmp(participant, "WSAS17")
           recovery_r_wpli = [];
        else
            [recovery_r_wpli, recovery_r_location, recovery_r_regions] = process_wpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_wpli.mat'));              
        end
    end
    
    % This vector is used for nomarlization
    wpli_all = [baseline_r_wpli(:); anesthesia_r_wpli(:); recovery_r_wpli(:)];

    % Creat the 2 or 3 subplot vertical figure for comparions
    % depending if this is participant WSAS17 or not (no recovery)
    num_sub = 3;
    if strcmp(participant,"WSAS17")
        num_sub = 2;
    end
    
    handle = figure;
    subplot(1,num_sub,1)
    plot_pli(baseline_r_wpli, baseline_r_regions, wpli_all, COLOR)
    title(strcat(participant, " alpha wpli at baseline"));
    subplot(1,num_sub,2)
    plot_pli(anesthesia_r_wpli, anesthesia_r_regions, wpli_all, COLOR)
    title(strcat(participant, " alpha wpli at anesthesia"));
    if strcmp(participant,"WSAS17") == 0
        subplot(1,num_sub,3)
        plot_pli(recovery_r_wpli, recovery_r_regions, wpli_all, COLOR)
        title(strcat(participant, " alpha wpli at recovery"));
    end
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    % Save the figure at the right spot in disk
    filename = strcat(OUT_DIR, participant, "_alpha_wpli.png");
    saveas(handle,filename);
    close all;
end