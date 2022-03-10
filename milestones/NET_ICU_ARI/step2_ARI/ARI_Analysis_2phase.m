
%% Charlotte Maschke January 2020
% this script is mainly based on the previous material from Yacin Mahdid 
% it summarizes the material used for the current submission 
% and is able to replicate the results with fifferent electrode numbers

FREQUENCY = "alpha";

%% Experiment Variable
IN_DIR = '/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data';
MAP_FILE = "C:\Users\charlotte\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\utils\bp_to_egi_mapping_yacine.csv";
OUT_DIR = "/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data/results/" + FREQUENCY;

% Here we will skip participant 17 since we do not have recovery
P_ID = {'002MG', '003MG', '003MW', '004MG', '004MW', '007MG', '005MW',...
'009MG', '006MW', '010MG', '011MG', '012MG', '013MG', '014MG', '016MG', ...
'017MG', '018MG', '019MG', '020MG', '022MG', '023MG', '024MG', '025MG', '026MG', '027MG', '028MG'};


%here 
% 0 WSAS recovered
% 1 WSAS non-recovered
% 2 NET_ICU non-recovered
% 3 NET_ICU recovered
% 4 NET_ICU unknown
% 5 HEALTHY

%P_LABEL = [0,1,0,1,1,1,1,1,0,0,1,2,3,2,3,4,2,3,3,3,5,5,5,5,5 ]; 

threshold_range = 0.70:-0.01:0.01; % More connected to less connected

COLOR = 'jet';


%% Calculate the dpli-dris
% Here we iterate over each participant and each epochs to create the 3
% subplots per figure
dpli_dris = zeros(1, length(P_ID));
hub_dris = zeros(1, length(P_ID));

for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(strcat("Participant: ", participant , "_dPLI"));
  
    [sedon1_r_dpli, sedon1_r_location, sedon1_r_regions] = process_dpli(strcat(IN_DIR,filesep,'connectivity', filesep, 'dpli_',FREQUENCY,'_',participant,'_sedon1.mat'));
    [sedoff_r_dpli, sedoff_r_location, sedoff_r_regions] = process_dpli(strcat(IN_DIR,filesep,'connectivity', filesep, 'dpli_',FREQUENCY,'_',participant,'_sedoff.mat'));
    
    % This vector is used for nomarlization
    %sim_all = [baseline_r_dpli(:); anesthesia_r_dpli(:); recovery_r_dpli(:)];

    % Get the common location
    [common_labels, common_region] = get_subset_two(baseline_r_location, anesthesia_r_location, baseline_r_regions, anesthesia_r_regions);
    
    if REDUCED == "Yes"
        common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    baseline_f_dpli = filter_matrix(baseline_r_dpli, baseline_r_location, common_labels);
    anesthesia_f_dpli = filter_matrix(anesthesia_r_dpli, anesthesia_r_location, common_labels);
        
    % Calculate a contrast matrix, this is different than before.
    % now we want to have high score for large differences and low
    % score for similarities
    baseline_vs_anesthesia = abs(baseline_f_dpli - anesthesia_f_dpli);
    
    % new feature: remove the diagonal from the dPLI (wd = without diagonal)
    % temporary value
    tmp = baseline_vs_anesthesia';
    baseline_vs_anesthesia_wd = reshape(tmp(~eye(size(tmp))), size(baseline_vs_anesthesia, 2)-1, [])';
        
    dpli_dris(p) = sum(baseline_vs_anesthesia_wd(:));
    % normalize it so that headset with more channels aren't artificially
    % inflated
    dpli_dris(p) = dpli_dris(p)/length(baseline_vs_anesthesia_wd(:));
    % At this point we have the dpli_dri

    %% Calculate the Hub-DRI
    disp(strcat("Participant: ", participant , "_HUB"));

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_bp_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,FREQUENCY, filesep, 'wpli_',FREQUENCY,'_',participant,'_Base.mat'), MAP_FILE);
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_bp_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,FREQUENCY, filesep, 'wpli_',FREQUENCY,'_',participant,'_Anes.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,FREQUENCY, filesep, 'wpli_',FREQUENCY,'_',participant,'_Base.mat'));
        [anesthesia_r_wpli, anesthesia_r_labels, anesthesia_r_regions, anesthesia_r_location] = process_wpli(strcat(IN_DIR,filesep,'connectivity',filesep,FREQUENCY, filesep, 'wpli_',FREQUENCY,'_',participant,'_Anes.mat'));
    end

    % Filter the matrix to have the same size
    % Get the common location
    [common_labels, common_region] = get_subset_two(baseline_r_labels, anesthesia_r_labels, baseline_r_regions, anesthesia_r_regions);           
    
    if REDUCED == "Yes"
    common_labels = intersect(common_labels,Subset, 'stable');
    end

    % Filter the matrices to have the same size
    baseline_f_wpli = filter_matrix(baseline_r_wpli, baseline_r_labels, common_labels);
    anesthesia_f_wpli = filter_matrix(anesthesia_r_wpli, anesthesia_r_labels, common_labels);

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
    
    % Calculate a contrast matrix, this is same thing as for dpli-dri
    % now we want to have high score for large differences and low
    % score for similarities
    bva = abs(baseline_norm_weights - anesthesia_norm_weights);
    disp(strcat("Cosine BvA: ", string(bva)))
    
    disp("-----")
    % Calculate the hub dri
    hub_dris(p) = sum(bva(:))/length(bva(:));
    
    plot_dpli_hub_two(baseline_f_dpli, anesthesia_f_dpli, baseline_norm_weights, anesthesia_norm_weights, common_location, participant, OUT_DIR)

end

%here 
% 0 WSAS recovered
% 1 WSAS non-recovered
% 2 NET_ICU recovered
% 3 NET_ICU non-recovered
% 4 NET_ICU unknown
% 5 HEALTHY

% Plot figure for the dpli-dri
handle = figure;
scatter(dpli_dris(P_LABEL ==0),hub_dris(P_LABEL ==0),[],'red','filled')
hold on
scatter(dpli_dris(P_LABEL ==1),hub_dris(P_LABEL ==1),[],'blue','filled')
scatter(dpli_dris(P_LABEL ==5),hub_dris(P_LABEL ==5),[],'green','filled')
xlabel("dPLI-DRI");
ylabel("Hub-DRI");
legend('Recovered','Non-Recovered','Healthy');
% Save it to disk
filename = strcat(OUT_DIR,"\DPLI_DRI_WSAS.png");
saveas(handle,filename);
close all; 

% Plot figure for the dpli-dri
handle = figure;
scatter(dpli_dris(P_LABEL ==2),hub_dris(P_LABEL ==2),[],'red','filled')
hold on
scatter(dpli_dris(P_LABEL ==3),hub_dris(P_LABEL ==3),[],'blue','filled')
scatter(dpli_dris(P_LABEL ==5),hub_dris(P_LABEL ==5),[],'green','filled')
xlabel("dPLI-DRI");
ylabel("Hub-DRI");
legend('Non-Recovered','Recovered','Healthy');
% Save it to disk
filename = strcat(OUT_DIR,"\DPLI_DRI_NETICU.png");
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
