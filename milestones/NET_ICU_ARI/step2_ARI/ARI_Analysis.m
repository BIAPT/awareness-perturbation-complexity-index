
%% Charlotte Maschke January 2020
% this script is mainly based on the previous material from Yacin Mahdid 
% it summarizes the material used for the current submission 
% and is able to replicate the results with fifferent electrode numbers


FREQUENCY = "alpha";
%FREQUENCY = "theta";

% do you want the channels reduced to 18 channels (defined below) 
REDUCED = "No"; % can be Yes or No

%% Experiment Variable
IN_DIR = 'data/connectivity';
OUT_DIR = 'results/ARI_'+FREQUENCY+'_reduced_'+REDUCED;

% Create output dir
if not(exist(OUT_DIR,'dir'))
        mkdir(OUT_DIR)
end

info = readtable('Part_Info.txt');
P_ID = info.ID;
Best_hem = info.Better_Hem;

% Do you want a hard threshold? 
% If no then use smallest connected graph to find baseline threshold
use_hard_threshold = "No";
% only relevant if Yes
hard_threshold = 0.05;
% only relevant if No
threshold_range = 0.70:-0.01:0.01; % More connected to less connected

COLOR = 'jet';

% Import electrodes for reduced subset
if REDUCED == "Yes"
    Subset_left = {'E11','E13','E20','E24','E28','E33','E36','E37','E45','E47','E52','E57','E58','E62','E68','E70','E75','Cz'};
    Subset_right = {'E9','E11','E62','E75','E83','E87','E92','E94','E96','E98','E100','E104','E108','E112','E117','E122','E124','Cz'};
end

%% Calculate the dpli-dris
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_on1 = zeros(1, length(P_ID));
dpli_off = zeros(1, length(P_ID));
dpli_on2 = zeros(1, length(P_ID));
dpli_diff_on1_off = zeros(1, length(P_ID));
dpli_diff_off_on2 = zeros(1, length(P_ID));
dpli_diff_on1_on2 = zeros(1, length(P_ID));
dpli_ARI = zeros(1, length(P_ID));

hub_on1 = zeros(1, length(P_ID));
hub_off = zeros(1, length(P_ID));
hub_on2 = zeros(1, length(P_ID));
hub_diff_on1_off = zeros(1, length(P_ID));
hub_diff_off_on2 = zeros(1, length(P_ID));
hub_diff_on1_on2 = zeros(1, length(P_ID));
hub_ARI = zeros(1, length(P_ID));

for p = 1:length(P_ID)
    participant = P_ID{p};
    % set up this for patients who only have 2 recordings (no sedon2 recording)
    threePhase = true;      
    disp(strcat("Participant: ", participant , "_dPLI"));
    
    if REDUCED == "Yes"
        if Best_hem{p} == "left"
            Subset = Subset_left;
            disp("LEFT subset selected");    
        end
        if Best_hem{p} == "right"
            Subset = Subset_right;
            disp("RIGHT subset selected");    
        end
    end

    
    sedon1_file = strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedon1.mat');
    sedoff_file = strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedoff.mat');
    sedon2_file = strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedon2.mat');

    [sedon1_r_dpli, sedon1_r_location, sedon1_r_regions] = process_dpli(sedon1_file);
    [sedoff_r_dpli, sedoff_r_location, sedoff_r_regions] = process_dpli(sedoff_file);
    
    if isfile(sedon2_file)
        % File exists.
        [sedon2_r_dpli, sedon2_r_location, sedon2_r_regions] = process_dpli(sedon2_file);        
    else
        % We know we only have 2 phases recorded
        threePhase = false;
    end
    
    % Get the common location
    if threePhase
        [common_labels, common_region] = get_subset(sedon1_r_location, sedoff_r_location, sedon2_r_location, sedon1_r_regions, sedoff_r_regions, sedon2_r_regions);
    else
        [common_labels, common_region] = get_subset_two(sedon1_r_location, sedoff_r_location, sedon1_r_regions, sedoff_r_regions);
    end

    if REDUCED == "Yes"
        common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    sedon1_f_dpli = filter_matrix(sedon1_r_dpli, sedon1_r_location, common_labels);
    sedoff_f_dpli = filter_matrix(sedoff_r_dpli, sedoff_r_location, common_labels);
    if threePhase
        sedon2_f_dpli = filter_matrix(sedon2_r_dpli, sedon2_r_location, common_labels);
    end

    % add raw space averaged values to output
    dpli_on1(p) = mean(nonzeros(triu(sedon1_f_dpli, 1)));
    dpli_off(p) = mean(nonzeros(triu(sedoff_f_dpli, 1)));
    
    if threePhase
        dpli_on2(p) = mean(nonzeros(triu(sedon2_f_dpli, 1)));
    else
        dpli_on2(p) = NaN;
    end

    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    sedon1_vs_sedoff = abs(sedon1_f_dpli - sedoff_f_dpli);
    if threePhase
        sedon2_vs_sedoff = abs(sedon2_f_dpli - sedoff_f_dpli);
        sedon1_vs_sedon2 = abs(sedon1_f_dpli - sedon2_f_dpli);
    end

    % remove the diagonal from the dPLI (wd = without diagonal)
    % temporary value
    tmp = sedon1_vs_sedoff';
    sedon1_vs_sedoff_wd = reshape(tmp(~eye(size(tmp))), size(sedon1_vs_sedoff, 2)-1, [])';
    dpli_diff_on1_off(p) = sum(sedon1_vs_sedoff_wd(:))/length(sedon1_vs_sedoff_wd(:));

    if threePhase
        tmp = sedon2_vs_sedoff';
        sedon2_vs_sedoff_wd = reshape(tmp(~eye(size(tmp))), size(sedon2_vs_sedoff, 2)-1, [])';
        dpli_diff_off_on2(p) = sum(sedon2_vs_sedoff_wd(:))/length(sedon2_vs_sedoff_wd(:));

        tmp = sedon1_vs_sedon2';
        sedon1_vs_sedon2_wd = reshape(tmp(~eye(size(tmp))), size(sedon1_vs_sedon2, 2)-1, [])';  
        dpli_diff_on1_on2(p) = sum(sedon1_vs_sedon2_wd(:))/length(sedon1_vs_sedon2_wd(:));
        
        % claculate the ARI
        dpli_ARI(p) = calculate_NET_ICU_ARI(sedon1_vs_sedon2_wd, sedon1_vs_sedoff_wd, sedon2_vs_sedoff_wd, 1, 1, 1);
        % normalize it so that headset with more channels aren't artificially inflated
        dpli_ARI(p) = dpli_ARI(p)/length(sedon1_vs_sedon2_wd(:));
    else
        dpli_diff_off_on2(p) = NaN;
        dpli_diff_on1_on2(p) = NaN;
        dpli_ARI(p) = NaN;
    end


    %% Calculate the Hub-DRI
    disp(strcat("Participant: ", participant , "_HUB"));

    % Process each of the three states
    [sedon1_r_wpli, sedon1_r_labels, sedon1_r_regions, sedon1_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedon1.mat'));
    [sedoff_r_wpli, sedoff_r_labels, sedoff_r_regions, sedoff_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedoff.mat'));
    if threePhase
        [sedon2_r_wpli, sedon2_r_labels, sedon2_r_regions, sedon2_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedon2.mat'));              
    end

    % Filter the matrix to have the same size
    % Get the common location
    if threePhase
       [common_labels, common_region] = get_subset(sedon1_r_labels, sedoff_r_labels, sedon2_r_labels, sedon1_r_regions, sedoff_r_regions, sedon2_r_regions);           
    else
        [common_labels, common_region] = get_subset_two(sedon1_r_labels, sedoff_r_labels, sedon1_r_regions, sedoff_r_regions);           
    end

    if REDUCED == "Yes"
        common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    sedon1_f_wpli = filter_matrix(sedon1_r_wpli, sedon1_r_labels, common_labels);
    sedoff_f_wpli = filter_matrix(sedoff_r_wpli, sedoff_r_labels, common_labels);
    if threePhase
        sedon2_f_wpli = filter_matrix(sedon2_r_wpli, sedon2_r_labels, common_labels);
    end

    % Regenerate the common location from the common labels that was
    % lost in the get_subset process
    common_location = generate_common_location(common_labels, sedon1_r_labels, sedon1_r_location);

    %% Binarize the three states using the minimally spanning tree and calculate the hub location
    % thereby we calculate the threshold only for baseline data and keep it
    % for the other conditions
    
    if use_hard_threshold == "Yes"
        threshold = hard_threshold;
    else
        [threshold] = find_smallest_connected_threshold(sedoff_f_wpli, threshold_range);
    end
    
    disp("use for all the threshold: " + string (threshold))

    % Baseline Threshold    
    [sedon1_b_wpli] = binarize_matrix(threshold_matrix(sedon1_f_wpli, threshold));
    % here we are using only the degree and not the betweeness centrality
    [~, sedon1_weights] = binary_hub_location(sedon1_b_wpli, common_location, 1.0, 0.0);
    sedon1_norm_weights = (sedon1_weights - mean(sedon1_weights))  / std(sedon1_weights);

    % Anesthesia Threshold    
    [sedoff_b_wpli] = binarize_matrix(threshold_matrix(sedoff_f_wpli, threshold));
    % here we are using only the degree and not the betweeness centrality
    [~, sedoff_weights] = binary_hub_location(sedoff_b_wpli, common_location,  1.0, 0.0);
    sedoff_norm_weights = (sedoff_weights - mean(sedoff_weights))  / std(sedoff_weights);
    
    if threePhase
        % Recovery Threshold:
        [sedon2_b_wpli] = binarize_matrix(threshold_matrix(sedon2_f_wpli, threshold));        
        % here we are using only the degree and not the betweeness centrality
        [~, sedon2_weights] = binary_hub_location(sedon2_b_wpli, common_location,  1.0, 0.0);
        sedon2_norm_weights = (sedon2_weights - mean(sedon2_weights))  / std(sedon2_weights);
    end

    % add single phase output to results:
    hub_on1(p) = mean(sedon1_norm_weights);
    hub_off(p) = mean(sedoff_norm_weights);
    if threePhase
        hub_on2(p) = mean(sedon2_norm_weights);
    else
        hub_on2(p) = NaN;
    end

    % Calculate a contrast matrix, this is same thing as for dpli-dri
    % now we want to have high score for large differences and low
    % score for similarities
    s1vso = abs(sedon1_norm_weights - sedoff_norm_weights);
    hub_diff_on1_off(p) = sum(s1vso(:));
    if threePhase
        s2vso = abs(sedon2_norm_weights - sedoff_norm_weights);
        hub_diff_off_on2(p) = sum(s2vso(:));
        
        s1vs2 = abs(sedon1_norm_weights - sedon2_norm_weights);
        hub_diff_on1_on2(p) = sum(s1vs2(:));
        
        % Calculate the hub ARI
        hub_ARI(p) = 1*sum(s1vso(:)) + 1*sum(s2vso(:)) - 1*sum(s1vs2(:));
        hub_ARI(p) = hub_ARI(p)/length(s1vs2(:));
    else
        s2vso(p) = NaN;
        s1vs2(p) = NaN;
        hub_ARI(p) = NaN;        
    end

    % Plot resutls
    if threePhase
        plot_dpli_hub_NET_ICU(sedon1_f_dpli,sedoff_f_dpli,sedon2_f_dpli,sedon1_norm_weights,sedoff_norm_weights,sedon2_norm_weights,common_location,participant,OUT_DIR)
    else
        plot_dpli_hub_two(sedon1_f_dpli, sedoff_f_dpli, sedon1_norm_weights, sedoff_norm_weights, common_location, participant, OUT_DIR)
    end

end

% Put together table to output results
RESULTS = table(P_ID(:), dpli_on1(:),dpli_off(:),dpli_on2(:), ...
    dpli_diff_on1_off(:),dpli_diff_off_on2(:),dpli_diff_on1_on2(:), ...
    dpli_ARI(:),...
    hub_on1(:),hub_off(:),hub_on2(:), ...
    hub_diff_on1_off(:),hub_diff_off_on2(:),hub_diff_on1_on2(:), ...
    hub_ARI(:), ...
    'VariableNames', { 'P_ID', 'dpli_on1','dpli_off','dpli_on2', ...
    'dpli_diff_on1_off','dpli_diff_off_on2','dpli_diff_on1_on2', ...
    'dpli_ARI',...
    'hub_on1','hub_off','hub_on2', ...
    'hub_diff_on1_off','hub_diff_off_on2','hub_diff_on1_on2', ...
    'hub_ARI'});

% Write data to text file
writetable(RESULTS, strcat(OUT_DIR, '/NET_ICU_ARI_variables.txt'))
