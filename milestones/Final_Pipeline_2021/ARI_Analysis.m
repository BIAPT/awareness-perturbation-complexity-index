
%% Charlotte Maschke January 2020
% this script is mainly based on the previous material from Yacin Mahdid 
% it summarizes the material used for the current submission 
% and is able to replicate the results with fifferent electrode numbers



%% Experiment Variable
IN_DIR = 'C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\data';
MAP_FILE = "C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\utils\bp_to_egi_mapping_yacine.csv";
OUT_DIR = 'C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\all_electrodes';

% Here we will skip participant 17 since we do not have recovery
P_ID = {'WSAS02','WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};
P_LABEL = [1,0,1,0,0,0,0,0,1,1,0]; %here 1 means recover and 0 means not recover

REDUCED = "Yes";

threshold_range = 0.70:-0.01:0.01; % More connected to less connected

COLOR = 'jet';

if REDUCED == "Yes"
    %Subset = ['Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2'];
    Subset = {'E22','E9','E33','E24','E11','E124','E122','E45','E36','Cz','E104','E108','E58','E52','E62','E92','E96','E70','E83'};
    OUT_DIR = 'C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\reduced_wd';

end


%% Calculate the dpli-dris
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_dris = zeros(1, length(P_ID));
hub_dris = zeros(1, length(P_ID));

for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(strcat("Participant: ", participant , "_dPLI"));
    

    % Process each of the three states, since participant WSAS02 is special
    % in the sense that is has the Brain Product headset we check for it
    % to processing it correctly
    if strcmp(participant, "WSAS02")
        [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_bp_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Base.mat'), MAP_FILE);
        [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_bp_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Anes.mat'), MAP_FILE);
        [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_bp_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Reco.mat'), MAP_FILE);
    else
        [baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Base.mat'));
        [anesthesia_r_dpli, anesthesia_r_location, anesthesia_r_regions] = process_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Anes.mat'));
        [recovery_r_dpli, recovery_r_location, recovery_r_regions] = process_dpli(strcat(IN_DIR,filesep,'connectivity',filesep,'dpli_alpha_',participant,'_Reco.mat'));        
    end
    
    % This vector is used for nomarlization
    %sim_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Get the common location
    [common_labels, common_region] = get_subset(baseline_r_location, anesthesia_r_location, recovery_r_location, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);
    
    if REDUCED == "Yes"
    common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_labels);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_labels);
    recovery_f_dpli = filter_matrix(recovery_r_dpli, recovery_r_location, common_labels);
    
    
    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    baseline_vs_recovery = abs(baseline_f_dpli - recovery_f_dpli);
    baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);
    recovery_vs_anesthesia = abs(recovery_f_dpli - anesthesia_f_dpli);
    
    % new feature: remove the diagonal from the dPLI (wd = without diagonal)
    % temporary value
    tmp = baseline_vs_recovery';
    baseline_vs_recovery_wd = reshape(tmp(~eye(size(tmp))), size(baseline_vs_recovery, 2)-1, [])';

    tmp = baseline_vs_anesthesia';
    baseline_vs_anesthesia_wd = reshape(tmp(~eye(size(tmp))), size(baseline_vs_anesthesia, 2)-1, [])';
    
    tmp = recovery_vs_anesthesia';
    recovery_vs_anesthesia_wd = reshape(tmp(~eye(size(tmp))), size(recovery_vs_anesthesia, 2)-1, [])';
    
    
    % Calculate the dpli-dri with w1, w2 and w3
    % Weights for analysis
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    dpli_dris(p) = calculate_dpli_dri(baseline_vs_recovery_wd, baseline_vs_anesthesia_wd, recovery_vs_anesthesia_wd, w1, w2, w3);
    % normalize it so that headset with more channels aren't artificially
    % inflated
    dpli_dris(p) = dpli_dris(p)/length(baseline_vs_recovery_wd(:));
    % At this point we have the dpli_dri

    %% Calculate the Hub-DRI
    disp(strcat("Participant: ", participant , "_HUB"));

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_bp_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Base.mat'), MAP_FILE);
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_bp_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Anes.mat'), MAP_FILE);
        [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_bp_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Reco.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Base.mat'));
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Anes.mat'));
        [recovery_r_wpli, recovery_r_labels, recovery_r_regions, recovery_r_location] = process_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Reco.mat'));              
    end

    % Filter the matrix to have the same size
    % Get the common location
    [common_labels, common_region] = get_subset(baseline_r_labels, anesthesia_r_labels, recovery_r_labels, baseline_r_regions, anesthesia_r_regions, recovery_r_regions);           
    
    if REDUCED == "Yes"
    common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    baseline_f_wpli = filter_matrix(baseline_r_wpli, baseline_r_labels, common_labels);
    anesthesia_f_wpli = filter_matrix(anesthesia_r_wpli, anesthesia_r_labels, common_labels);
    recovery_f_wpli = filter_matrix(recovery_r_wpli, recovery_r_labels, common_labels);

    % Regenerate the common location from the common labels that was
    % lost in the get_subset process
    common_location = generate_common_location(common_labels, baseline_r_labels, baseline_r_location);

    %% Binarize the three states using the minimally spanning tree and calculate the hub location
    % thereby we calculate the threshold only for baseline data and keep it
    % for the other conditions
    disp("Baseline Threshold: ")
    [threshold] = find_smallest_connected_threshold(baseline_f_wpli, threshold_range);
    [baseline_b_wpli] = binarize_matrix(threshold_matrix(baseline_f_wpli, threshold));

    % here we are using only the degree and not the betweeness centrality
    [~, baseline_weights] = binary_hub_location(baseline_b_wpli, common_location, 1.0, 0.0);
    baseline_norm_weights = (baseline_weights - mean(baseline_weights))  / std(baseline_weights);

    disp("Anesthesia Threshold: ")    
    %[threshold] = find_smallest_connected_threshold(anesthesia_f_wpli, threshold_range);
    [anesthesia_b_wpli] = binarize_matrix(threshold_matrix(anesthesia_f_wpli, threshold));

    % here we are using only the degree and not the betweeness centrality
    [~, anesthesia_weights] = binary_hub_location(anesthesia_b_wpli, common_location,  1.0, 0.0);
    anesthesia_norm_weights = (anesthesia_weights - mean(anesthesia_weights))  / std(anesthesia_weights);
    
    disp("Recovery Threshold: ")
    %[threshold] = find_smallest_connected_threshold(recovery_f_wpli, threshold_range);
    [recovery_b_wpli] = binarize_matrix(threshold_matrix(recovery_f_wpli, threshold));        
    
    % here we are using only the degree and not the betweeness centrality
    [~, recovery_weights] = binary_hub_location(recovery_b_wpli, common_location,  1.0, 0.0);
    recovery_norm_weights = (recovery_weights - mean(recovery_weights))  / std(recovery_weights);

    % Calculate a contrast matrix, this is same thing as for dpli-dri
    % now we want to have high score for large differences and low
    % score for similarities
    bvr = abs(baseline_norm_weights - recovery_norm_weights);
    bva = abs(baseline_norm_weights - anesthesia_norm_weights);
    rva = abs(recovery_norm_weights - anesthesia_norm_weights);
    disp(strcat("Cosine BvA: ", string(bva)))
    disp(strcat("Cosine BvR: ", string(bvr)))
    disp(strcat("Cosine RvA: ", string(rva)))
    
    disp("-----")
    % Calculate the hub dri
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    hub_dris(p) = w1*sum(bva(:)) + w2*sum(rva(:)) - w3*sum(bvr(:));
    hub_dris(p) = hub_dris(p)/length(bvr(:));
    
    plot_dpli_hub(baseline_f_dpli,anesthesia_f_dpli,recovery_f_dpli,baseline_norm_weights,anesthesia_norm_weights,recovery_norm_weights,common_location,participant,OUT_DIR)

end

% Plot figure for the dpli-dri
handle = figure;
scatter(dpli_dris,hub_dris,[],P_LABEL,'filled')
xlabel("dPLI-DRI");
ylabel("Hub-DRI");
colormap(COLOR);

% Save it to disk
filename = strcat(OUT_DIR,"\DPLI_DRI.png");
saveas(handle,filename);
close all; 

% Print out the result in a good format
for p = 1:length(P_ID)
    participant = P_ID{p};
    label = P_LABEL(p);
    dpli_dri = dpli_dris(p);
    hub_dri = hub_dris(p);
    
    msg = sprintf("Participant: %s\nLabel: %d\ndPLI-DRI: %f\nHub-DRI: %f\n------\n",participant,label,dpli_dri,hub_dri);
    disp(msg);
end


RESULTS = table(P_ID(:), dpli_dris(:) , hub_dris(:), 'VariableNames', { 'ID', 'dPLI','Hub'});
% Write data to text file
writetable(RESULTS, strcat(OUT_DIR,'/ARI.txt'))
