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
SHIFT_WEIGHT = 2; % this is used in the definition of the similarity matrix to scale the tanh function

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
    
    filename = strcat(OUT_DIR, participant, "_alpha_sim_dpli_augmented.png");
    saveas(handle,filename);
    close all;    
end

function [sim_matrix] = calculate_sim_matrix(matrix1, matrix2, shift_weight)
% CALCULATE SIM MATRIX this function will calculate an improved version of
% the similarity matrix that takes into consideration posterior/anterior
% shift
    
    % Here we shift the matrix1 matrix2 to check for crossing of the 0.5
    % mark
    shift_matrix1 = matrix1 - 0.5;
    shift_matrix2 = matrix2 - 0.5;
    
    % Here we want to have make a matrix that will give us a 1 for crossing
    % over and a 0 for not crossing over
    % We check which index in both shifted matrix are positive
    pos_matrix1 = shift_matrix1 > 0;
    pos_matrix2 = shift_matrix2 > 0;
    % We then add these two, we will get a value of 1 (one positive one
    % negative), 2 (both positive) or 0 (both negative)
    sign_matrix = pos_matrix1 + pos_matrix2;
    
    % To get the amount of crossing we put zeros everywhere and then only
    % modify the cross matrix for the index that are actually crossing.
    amount_crossing_matrix = abs(shift_matrix1 - shift_matrix2);
    cross_matrix = amount_crossing_matrix.*(sign_matrix == 1);
    
    % Finally to calculate the weight matrix we put the cross matrix
    % through the tanh function. Should give 0 for 0 values and a positive
    % value for positive input saturating at 1. We then shift that matrix
    % by 1 and weight it by the shift_weight. This will give us a 1 for the
    % region which don't cross and a scaling proportional to the amount of
    % crossing for actual cross.
    weight_matrix = shift_weight*tanh(cross_matrix) + 1;
    
    % We finally multiply the naive version of the similarity matrix with
    % the weight matrix.
    sim_matrix = 1 - (abs(matrix1 - matrix2).*weight_matrix);

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