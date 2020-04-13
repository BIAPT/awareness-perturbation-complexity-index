%% Yacine Mahdid April 10 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/10

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";

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

    % Process each of the three states
    [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'baseline_alpha_dpli.mat'));
    [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'anesthesia_alpha_dpli.mat'));
    [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_dpli(strcat(IN_DIR,participant,filesep,'recovery_alpha_dpli.mat'));
    
    % This vector is used for nomarlization
    sim_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Get the common location
    [common_location, common_region] = get_subset(baseline_r_location, anesthesia_r_location, recovery_r_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);
    
    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_location);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_location);
    recovery_f_dpli = filter_matrix(recovery_r_dpli, recovery_r_location, common_location);
    
    
    dpli_all = [baseline_f_dpli(:); anesthesia_f_dpli(:); recovery_f_dpli(:)];

    handle = figure;
    subplot(1,3,1)
    plot_pli(baseline_f_dpli, common_location, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at baseline"));
    subplot(1,3,2)
    plot_pli(anesthesia_f_dpli, common_location, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at anesthesia"));
    subplot(1,3,3)
    plot_pli(recovery_f_dpli, common_location, dpli_all, COLOR)
    title(strcat(participant, " alpha dpli at recovery"));
    colorbar;
    set(handle, 'Position', [70,152,1527,589]);
    
    
    % Calculate the similarity matrix
    % similarity matrix is defined as 1 - abs(mat1 - mat2);
    baseline_vs_recovery = 1 - abs(baseline_f_dpli - recovery_f_dpli);
    baseline_vs_anesthesia = 1 - abs(baseline_f_dpli - anesthesia_f_dpli);
    recovery_vs_anesthesia = 1 - abs(recovery_f_dpli - anesthesia_f_dpli);
    
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
    
    filename = strcat(OUT_DIR, participant, "_alpha_sim_dpli.png");
    saveas(handle,filename);
    close all;    
end

function [common_location, common_region] = get_subset(baseline_location, anesthesia_location, recovery_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions)

    all_location = [baseline_location recovery_location anesthesia_location];
    all_regions = [baseline_r_regions, anesthesia_r_regions, recovery_r_regions];

    common_location = {};
    common_region = {};
    for l = 1:length(all_location)
        label = all_location{l};
        region = all_regions{l};
        
        % Index of each of these label
        b_index = get_label_index(label, baseline_location);
        a_index = get_label_index(label, anesthesia_location);
        r_index = get_label_index(label, recovery_location);
        
        if(b_index ~= 0 && a_index ~= 0 && r_index ~= 0)
           common_location = [common_location all_location(l)];
           common_region = [common_region region];
           baseline_location(b_index) = [];
           anesthesia_location(a_index) = [];
           recovery_location(r_index) = [];
        end
    end

end