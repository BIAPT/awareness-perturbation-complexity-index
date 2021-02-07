
%% Charlotte Maschke January 2020
% this script calculates the Lempel-ziv-complexity for all elecrodes
% individually and plots the outcome for every patient as well as a group
% comparative plot


%% Experiment Variable
IN_DIR = 'C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\data';
MAP_FILE = "C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\utils\bp_to_egi_mapping_yacine.csv";
OUT_DIR = 'C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\LZC_threshold_base';

% Here we will skip participant 17 since we do not have recovery
P_ID = {'WSAS02','WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22'};
P_LABEL_bin = [1,0,1,0,0,0,0,0,1,1,0]; %here 1 means recover and 0 means not recover

P_LABEL = {'recovered','non-recovered','recovered','non-recovered','non-recovered','non-recovered','non-recovered','non-recovered',...
    'recovered','recovered','non-recovered'}; %here 1 means recover and 0 means not recover

threshold_range = 0.70:-0.01:0.01; % More connected to less connected

COLOR = 'jet';

% empty Lempel-ziv arrays for every phase
baseline_LZ = zeros(1, length(P_ID));
anesthesia_LZ = zeros(1, length(P_ID));
recovery_LZ = zeros(1, length(P_ID));

for p = 1:length(P_ID)

    participant = P_ID{p}; 

    %% Calculate the Hub-DRI
    disp(strcat("Participant: ", participant , "_wPLI"));
    
    [baseline_wpli, baseline_location] = process_wpli_unaveraged(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Base.mat'));
    [anesthesia_wpli, anesthesia_location] = process_wpli_unaveraged(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Anes.mat'));
    [recovery_wpli, recovery_location] = process_wpli_unaveraged(strcat(IN_DIR,filesep,'connectivity',filesep,'wpli_alpha_',participant,'_Reco.mat'));              
    
    baseline_wPLI_mean = reshape(mean(baseline_wpli),size(baseline_wpli,2),size(baseline_wpli,2));
    anesthesia_wPLI_mean = reshape(mean(anesthesia_wpli),size(anesthesia_wpli,2),size(anesthesia_wpli,2));
    recovery_wPLI_mean = reshape(mean(recovery_wpli),size(recovery_wpli,2),size(recovery_wpli,2));
    
    %% Binarize the three states using the minimally spanning tree and calculate the hub location
    % thereby we calculate the threshold only for baseline data and keep it
    % for the other conditions
    
    baseline_b_wpli = zeros(size(baseline_wpli));
    anesthesia_b_wpli = zeros(size(anesthesia_wpli));
    recovery_b_wpli = zeros(size(recovery_wpli));
    
    %threshold = 0.05;

    disp("Baseline Threshold: ")
    [threshold] = find_smallest_connected_threshold(baseline_wPLI_mean, threshold_range);    
    for i = 1 : size(baseline_wpli,1)
        % binarize baseline
        slice_base = reshape(baseline_wpli(i,:,:),size(baseline_wpli,2),size(baseline_wpli,2));
        [baseline_b_wpli(i,:,:)] = binarize_matrix(threshold_matrix(slice_base, threshold));
    end
    
    %disp("Anesthesia Threshold: ")
    %[threshold] = find_smallest_connected_threshold(anesthesia_wPLI_mean, threshold_range);
    for i = 1 : size(anesthesia_wpli,1)
        % binarize anesthesia
        slice_anes = reshape(anesthesia_wpli(i,:,:),size(anesthesia_wpli,2),size(anesthesia_wpli,2));
        [anesthesia_b_wpli(i,:,:)] = binarize_matrix(threshold_matrix(slice_anes, threshold));
    end
    
    %disp("Recovery Threshold: ")
    %[threshold] = find_smallest_connected_threshold(recovery_wPLI_mean, threshold_range);
    for i = 1 : size(recovery_wpli,1)
        % binarize recovery
        slice_reco = reshape(recovery_wpli(i,:,:),size(recovery_wpli,2),size(recovery_wpli,2));
        [recovery_b_wpli(i,:,:)] = binarize_matrix(threshold_matrix(slice_reco, threshold));
    end
    
    % calculate Lempel-ZIV Complexity
    % use the following toolbox: 
    % https://www.mathworks.com/matlabcentral/fileexchange/38211-calc_lz_complexity
    
    lz_base=[];
    lz_anes=[];
    lz_reco=[];
    
    lz_matrix_base=zeros(size(baseline_b_wpli,2),size(baseline_b_wpli,2));
    lz_matrix_anes=zeros(size(anesthesia_b_wpli,2),size(anesthesia_b_wpli,2));
    lz_matrix_reco=zeros(size(recovery_b_wpli,2),size(recovery_b_wpli,2));
    
    for r = 1 : size(baseline_b_wpli,2)
        for c = r+1 : size(baseline_b_wpli,2)
            time_vector = reshape(baseline_b_wpli(:,r,c),size(baseline_wpli,1),1);
            lzc = calc_lz_complexity(time_vector, 'primitive', true);
            lz_base=[lz_base,lzc];
            lz_matrix_base(r,c) = lzc;
        end
    end
    
    for r = 1 : size(anesthesia_b_wpli,2)
        for c = r+1 : size(anesthesia_b_wpli,2)
            time_vector = reshape(anesthesia_b_wpli(:,r,c),size(anesthesia_wpli,1),1);
            lzc = calc_lz_complexity(time_vector, 'primitive', true);
            lz_anes=[lz_anes,lzc];
            lz_matrix_anes(r,c) = lzc;
        end
    end
    
    for r = 1 : size(recovery_b_wpli,2)
        for c = r+1 : size(recovery_b_wpli,2)
            time_vector = reshape(recovery_b_wpli(:,r,c),size(recovery_wpli,1),1);
            lzc = calc_lz_complexity(time_vector, 'primitive', true);
            lz_reco=[lz_reco,lzc];
            lz_matrix_reco(r,c) = lzc;
        end
    end
    
    plot_lzc(lz_matrix_base, lz_matrix_anes, lz_matrix_reco, lz_base, lz_anes, lz_reco, participant,OUT_DIR)
    
    baseline_LZ(p) = mean(lz_base);
    anesthesia_LZ(p) = mean(lz_anes);
    recovery_LZ(p) = mean(lz_reco);
    
end

difference = max(baseline_LZ,anesthesia_LZ)-min(baseline_LZ,anesthesia_LZ);

sum_data = table(P_ID(:),P_LABEL(:), baseline_LZ(:) , anesthesia_LZ(:),recovery_LZ(:),difference(:),...
    'VariableNames', { 'ID', 'Label','Baseline','Anesthesia','Recovery','difference'});
handle = figure;
set(gcf,'Position',[100, 100, 700, 500])
coordvars = {'Baseline','Anesthesia','Recovery'};
p = parallelplot(sum_data,'CoordinateVariables',coordvars,'GroupVariable','Label','DataNormalization','none');

% Save it to disk
filename = strcat(OUT_DIR,"\Summary_LZ.png");
saveas(handle,filename);
close all; 

handle = figure;
boxplot(difference,P_LABEL)
hold on
scatter(~P_LABEL_bin+1,difference,'r','filled')
% Save it to disk
filename = strcat(OUT_DIR,"\difference_BA_LZ.png");
saveas(handle,filename);
close all; 

% Write data to text file
writetable(sum_data, strcat(OUT_DIR,'/LZC.txt'))
