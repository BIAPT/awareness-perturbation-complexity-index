
%% Charlotte Maschke January 2020
% this script is mainly based on the previous material from Yacin Mahdid 
% it summarizes the material used for the current submission 
% and is able to replicate the results with fifferent electrode numbers


FREQUENCY = "alpha";
%FREQUENCY = "theta";

% do you want the channels reduced to 18 channels (defined below) 
REDUCED = "No";

%% Experiment Variable
IN_DIR = 'C:\Users\BIAPT\Documents\GitHub\ARI\milestones\NET_ICU_ARI\data\connectivity\';
OUT_DIR = 'C:\Users\BIAPT\Documents\GitHub\ARI\milestones\NET_ICU_ARI\results\ARI_'+FREQUENCY+'_reduced_'+REDUCED;

% Create output dir
if not(exist(OUT_DIR,'dir'))
        mkdir(OUT_DIR)
end

% Here we will skip participant 17 since we do not have recovery
P_ID = {'002MG', '003MG', '004MG', '010MG', '011MG', '012MG', '016MG', '017MG', '018MG', '019MG','020MG', '024MG', '025MG', '026MG', '027MG'};
P_LABEL = [0,2,1,2,2,1,1,2,2,1,2,1,3,3,3]; %here 1 means recover and 0 means not recover 2 means unknown (new patient)

% Do you want a hard threshold? 
% If no then use smallest connected graph to find baseline threshold
use_hard_threshold = "No";
% only relevant if Yes
hard_threshold = 0.05;
% only relevant if No
threshold_range = 0.70:-0.01:0.01; % More connected to less connected


COLOR = 'jet';

if REDUCED == "Yes"
    Subset_left = {'E11','E13','E20','E24','E28','E33','E36','E37','E45','E47','E52','E57','E58','E62','E68','E70','E75','Cz'};
    Subset_right = {'E9','E11','E62','E75','E83','E87','E92','E94','E96','E98','E100','E104','E108','E112','E117','E122','E124','Cz'};
    OUT_DIR = 'C:\Users\BIAPT\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\new_patient_ARI_'+FREQUENCY+'_reduced';
end


%% Calculate the dpli-dris
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_dris = zeros(1, length(P_ID));
hub_dris = zeros(1, length(P_ID));

baseline_only_dpli = zeros(1, length(P_ID));
baseline_only_hub = zeros(1, length(P_ID));

for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(strcat("Participant: ", participant , "_dPLI"));
    if REDUCED == "Yes"
        % take left Hemisphere only
        Subset = Subset_left;
        disp("selected left subset");
    end
 
    % Process each of the three states, since participant WSAS02 is special
    % in the sense that is has the Brain Product headset we check for it
    % to processing it correctly

    [sedon1_r_dpli, sedon1_r_location, sedon1_r_regions] = process_dpli(strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedon1.mat'));
    [sedoff_r_dpli, sedoff_r_location, sedoff_r_regions] = process_dpli(strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedoff.mat'));
    [sedon2_r_dpli, sedon2_r_location, sedon2_r_regions] = process_dpli(strcat(IN_DIR, filesep,'dpli_',FREQUENCY,'_',participant,'_sedon2.mat'));        

    % This vector is used for nomarlization
    %sim_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Get the common location
    [common_labels, common_region] = get_subset(sedon1_r_location, sedoff_r_location, sedon2_r_location, sedon1_r_regions, sedoff_r_regions, sedon2_r_regions);
    
    if REDUCED == "Yes"
        common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    sedon1_f_dpli = filter_matrix(sedon1_r_dpli, sedon1_r_location, common_labels);
    sedoff_f_dpli = filter_matrix(sedoff_r_dpli, sedoff_r_location, common_labels);
    sedon2_f_dpli = filter_matrix(sedon2_r_dpli, sedon2_r_location, common_labels);
    
    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    sedon1_vs_sedon2 = abs(sedon1_f_dpli - sedon2_f_dpli);
    sedon1_vs_sedoff = abs(sedon1_f_dpli - sedoff_f_dpli);
    sedon2_vs_sedoff = abs(sedon2_f_dpli - sedoff_f_dpli);
    
    % new feature: remove the diagonal from the dPLI (wd = without diagonal)
    % temporary value
    tmp = sedon1_vs_sedon2';
    sedon1_vs_sedon2_wd = reshape(tmp(~eye(size(tmp))), size(sedon1_vs_sedon2, 2)-1, [])';

    tmp = sedon1_vs_sedoff';
    sedon1_vs_sedoff_wd = reshape(tmp(~eye(size(tmp))), size(sedon1_vs_sedoff, 2)-1, [])';
    
    tmp = sedon2_vs_sedoff';
    sedon2_vs_sedoff_wd = reshape(tmp(~eye(size(tmp))), size(sedon2_vs_sedoff, 2)-1, [])';
    
    % Calculate the dpli-dri with w1, w2 and w3
    % Weights for analysis
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    dpli_dris(p) = calculate_NET_ICU_ARI(sedon1_vs_sedon2_wd, sedon1_vs_sedoff_wd, sedon2_vs_sedoff_wd, w1, w2, w3);
    % normalize it so that headset with more channels aren't artificially
    % inflated
    dpli_dris(p) = dpli_dris(p)/length(sedon1_vs_sedon2_wd(:));
    % At this point we have the dpli_dri
    
    %% Calculate the Hub-DRI
    disp(strcat("Participant: ", participant , "_HUB"));

    % Process each of the three states
    [sedon1_r_wpli, sedon1_r_labels, sedon1_r_regions, sedon1_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedon1.mat'));
    [sedoff_r_wpli, sedoff_r_labels, sedoff_r_regions, sedoff_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedoff.mat'));
    [sedon2_r_wpli, sedon2_r_labels, sedon2_r_regions, sedon2_r_location] = process_wpli(strcat(IN_DIR,filesep,'wpli_',FREQUENCY,'_',participant,'_sedon2.mat'));              

    % Filter the matrix to have the same size
    % Get the common location
    [common_labels, common_region] = get_subset(sedon1_r_labels, sedoff_r_labels, sedon2_r_labels, sedon1_r_regions, sedoff_r_regions, sedon2_r_regions);           
    
    if REDUCED == "Yes"
        common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    sedon1_f_wpli = filter_matrix(sedon1_r_wpli, sedon1_r_labels, common_labels);
    sedoff_f_wpli = filter_matrix(sedoff_r_wpli, sedoff_r_labels, common_labels);
    sedon2_f_wpli = filter_matrix(sedon2_r_wpli, sedon2_r_labels, common_labels);

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
    
    % Recovery Threshold:
    [sedon2_b_wpli] = binarize_matrix(threshold_matrix(sedon2_f_wpli, threshold));        
    % here we are using only the degree and not the betweeness centrality
    [~, sedon2_weights] = binary_hub_location(sedon2_b_wpli, common_location,  1.0, 0.0);
    sedon2_norm_weights = (sedon2_weights - mean(sedon2_weights))  / std(sedon2_weights);

    % Calculate a contrast matrix, this is same thing as for dpli-dri
    % now we want to have high score for large differences and low
    % score for similarities
    s1vs2 = abs(sedon1_norm_weights - sedon2_norm_weights);
    s1vso = abs(sedon1_norm_weights - sedoff_norm_weights);
    s2vso = abs(sedon2_norm_weights - sedoff_norm_weights);
    disp(strcat("Cosine s1vs2: ", string(sum(s1vs2(:)))))
    disp(strcat("Cosine s1vso: ", string(sum(s1vso(:)))))
    disp(strcat("Cosine s2vso: ", string(sum(s2vso(:)))))
    
    disp("-----")
    % Calculate the hub dri
    w1 = 1.0;
    w2 = 1.0;
    w3 = 1.0;
    hub_dris(p) = w1*sum(s1vso(:)) + w2*sum(s2vso(:)) - w3*sum(s1vs2(:));
    hub_dris(p) = hub_dris(p)/length(s1vs2(:));

    plot_dpli_hub_NET_ICU(sedon1_f_dpli,sedoff_f_dpli,sedon2_f_dpli,sedon1_norm_weights,sedoff_norm_weights,sedon2_norm_weights,common_location,participant,OUT_DIR)

end

% Plot figure for the dpli-dri
handle = figure;
gscatter(dpli_dris,hub_dris,P_LABEL)
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
