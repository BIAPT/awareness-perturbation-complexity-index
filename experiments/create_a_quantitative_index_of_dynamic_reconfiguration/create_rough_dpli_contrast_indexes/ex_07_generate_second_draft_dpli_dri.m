%% Yacine Mahdid March 27 2020
% This script is addressing the task https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/6

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";

% Here we will skip participant 17 since we do not have recovery
% And participant 02 since it's headset nomenclature is different.
P_ID = {'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};

%% Creating the figures
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_dris_1 = [];
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
    
    % Calculate the similarity matrix
    % similarity matrix is defined as 1 - abs(mat1 - mat2);
    baseline_vs_recovery = 1 - abs(baseline_f_dpli - recovery_f_dpli);
    baseline_vs_anesthesia = 1 - abs(baseline_f_dpli - anesthesia_f_dpli);
    recovery_vs_anesthesia = 1 - abs(recovery_f_dpli - anesthesia_f_dpli);
    
    % Calcualte the dpli-dri with w1 and w2 = 0
    [dpli_dri] = calculate_dpli_dri_1(baseline_vs_recovery, baseline_vs_anesthesia, recovery_vs_anesthesia, 1.0, 1.0);
    dpli_dris_1 = [dpli_dris_1, dpli_dri];
end

% Plot figure for the dpli-dri
handle = figure;
bar(categorical(P_ID), dpli_dris_1)
title("WSAS dpli-dri for alpha (attempt #2)");

filename = strcat(OUT_DIR, "dpli_dri_2.png");
saveas(handle,filename);
close all; 

% This is the the major thing that has changed here
% We will be doing a sum and a substraction to avoid having too narrow a
% range
function [dpli_dri] = calculate_dpli_dri_1(bvr, bva, rva, w1, w2)
    dpli_dri = 2*sum(bvr(:)) - (w1*(sum(bva(:))) + w2*(sum(rva(:))));
end

function [r_dpli, r_location, r_regions] = process_dpli(filename)
    data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.avg_dpli;
   location = data.result_dpli.metadata.channels_location;

   [r_dpli, r_location, r_regions] = reorder_channels(dpli, location, 'biapt_egi129.csv');
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

function [f_matrix] = filter_matrix(matrix, location, f_location)
    num_channels = length(f_location);
    
    good_index = zeros(1, num_channels);
    for l = 1:length(f_location)
        label = location{l};
        
        m_index = get_label_index(label, location);
        
        good_index(l) = m_index;
    end
    
    f_matrix = matrix(good_index, good_index);
end

% Function to check if a label is present in a given location
function [label_index] = get_label_index(label, location)
    label_index = 0;
    for i = 1:length(location)
       if(strcmp(label,location{i}))
          label_index = i;
          return
       end
    end
end