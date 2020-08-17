%% Yacine Mahdid August 04 2020
% This script is addressing the task
% https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/38
%
% calculate anterior and posterior mean degree for all participant in the
% baseline state
%% Experiment Variable
IN_DIR = "/media/yacine/My Book/datasets/consciousness/dri hub control/";
OUT_DIR = "/media/yacine/My Book/result_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/milestones/data/bp_to_egi_mapping_yacine.csv";

P_ID = {'WSAS02', 'WSAS04', 'WSAS05', 'WSAS07', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', ...
    'WSAS13', 'WSAS14', 'WSAS15', 'WSAS16', 'WSAS17', 'WSAS18', 'WSAS19', 'WSAS20', 'WSAS22', ...
    'WSAS23', 'p0003', 'p0004', 'p0008', 'p0022', 'p0028', 'p0031', 'p0034', 'p0036'};
threshold_range = 0.70:-0.01:0.01; % More connected to less connected


%% Calculate the anterior posterior mean degree

anterior_mean_degree = zeros(1, length(P_ID));
posterior_mean_degree = zeros(1, length(P_ID));
thresholds = zeros(1, length(P_ID));

for p = 1:length(P_ID)
    participant = P_ID{p};
    disp(strcat("Participant: ", participant));

    % Process each of the three states
    if strcmp(participant, "WSAS02")
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_bp_wpli(strcat(IN_DIR,participant,'_Baseline_wPLI.mat'), MAP_FILE);
    else
        [baseline_r_wpli, baseline_r_labels, baseline_r_regions, baseline_r_location] = process_wpli(strcat(IN_DIR,participant,'_Baseline_wPLI.mat'));
        
    end

    % Binarize the three states and calculate the hub location
    disp("Baseline Threshold: ")
    [threshold] = find_smallest_connected_threshold(baseline_r_wpli, threshold_range);
    [baseline_b_wpli] = binarize_matrix(threshold_matrix(baseline_r_wpli, threshold));

    % here we are using only the degree and not the betweeness centrality
    [~, baseline_weights] = binary_hub_location(baseline_b_wpli, baseline_r_location, 1.0, 0.0);

    anterior_weights = [];
    posterior_weights = [];
    
    for i = 1:length(baseline_weights)
        if baseline_r_location(i).is_anterior
           anterior_weights = [anterior_weights, baseline_weights(i)];
        else
           posterior_weights = [posterior_weights, baseline_weights(i)];
        end
    end
    
    anterior_mean_degree(p) = mean(anterior_weights);
    posterior_mean_degree(p) = mean(posterior_weights);
    thresholds(p) = threshold;
    
end

% Print out the result in a good format
for p = 1:length(P_ID)
    participant = P_ID{p};
    anterior_degree = anterior_mean_degree(p);
    posterior_degree = posterior_mean_degree(p);
    threshold = thresholds(p);
    
    msg = sprintf("Participant: %s\nThreshold: %f\nAnterior Mean Degree: %f\nPosterior Mean Degree: %f\n------\n",participant,threshold,anterior_degree,posterior_degree);
    disp(msg);
end

function [smallest_threshold] = find_smallest_connected_threshold(pli_matrix, threshold_range)
    %loop through thresholds
    for j = 1:length(threshold_range) 
        current_threshold = threshold_range(j);
        
        % Thresholding and binarization using the current threshold
        t_network = threshold_matrix(pli_matrix, current_threshold);
        b_network = binarize_matrix(t_network);

        % check if the binary network is disconnected
        % Here our binary network (b_network) is a weight matrix but also an
        % adjacency matrix.
        distance = distance_bin(b_network);

        % Here we check if there is one node that is disconnected
        if(sum(isinf(distance(:))))
            disp(strcat("Final threshold: ", string(threshold_range(j-1))));
            smallest_threshold = threshold_range(j-1);
            break;
        end
    end
end

function [hub_location, weights] = binary_hub_location(b_wpli, location, a_degree, a_bc)
%BETWEENESS_HUB_LOCATION select a channel which is the highest hub based on
%betweeness centrality and degree
% input:
% b_wpli: binary matrix
% location: 3d channels location
% a_degree: weight to put on the degree for the definition of hub
% a_bc: weight to put on the betweeness centrality for the definition of
% hub
%
% output:
% hub_location: This is a number between 0 and 1, where 0 is fully
% posterior and 1 is fully anterior
% weights: this is a an array containing weights of each of the channel in
% the order of the location structure

    %% 1.Calculate the degree for each electrode.
    degrees = degrees_und(b_wpli);
    
    %% 2. Calculate the betweeness centrality for each electrode.
    bc = betweenness_bin(b_wpli);
    
    
    %% 3. Combine the two Weightsmetric (here we assume equal weight on both the degree and the betweeness centrality)
    weights = a_degree*degrees + a_bc*bc;
    
    %% Obtain a metric for the channel that is most likely the hub epicenter
    [~, channel_index] = max(weights);
    hub_location = threshold_anterior_posterior(channel_index, location);

end

function [normalized_value] = threshold_anterior_posterior(index,channels_location)
%THRESHOLD_ANTERIOR_POSTERIOR This function will squash the channels in the
%direction of the anterior-posterior line and will set the most posterior
%index to 0 and the anterior most anterior index to 1
%   To do so it takes the index of the channel we want to normalize in the
%   posterior-anterior direction and the channels location for where it
%   came from. It then will find the value this channel should have.
% input:
% index: index of the channel to normalize between 0 and 1
% channels_location: 3D channel data structure

    % Get the X index of the current channels
    current_x = channels_location(index).X;
    
    % Accumulate all the Xs index for the channels locations
    all_x = zeros(1,length(channels_location));
    for i = 1:length(channels_location)
       all_x(i) = channels_location(i).X; 
    end
    
    % Normalize the current value of x between the min coordinate we have
    % in the headset and the maximum
    min_x = min(all_x);
    max_x = max(all_x);
    normalized_value = (current_x - min_x)/(max_x - min_x);
end

