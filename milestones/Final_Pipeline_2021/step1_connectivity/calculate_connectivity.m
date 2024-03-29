%% Charlotte Maschke November 11 2020
% This script goal is to generate the dpli and wPLI matrices for the ARI 
% The matrices will be generated with non-overlapping 10s windows in the alpha bandwidth.  

FREQUENCY = "alpha";
%FREQUENCY = "theta";
%FREQUENCY = "delta";


% Remote Source Setup
%
INPUT_DIR = 'Users/charlotte/Documents/GitHub/ARI/milestones/Final_Pipeline_2021/data/raw';
OUTPUT_DIR = 'data/connectivity/';

NEUROALGO_PATH = 'C:/Users/BIAPT/Documents/GitHub/NeuroAlgo/MATLAB';
%addpath(genpath(NEUROALGO_PATH)); % Add NA library to our path so that we can use it

% This list contains all participant IDs
% P_IDS = {'WSAS02', 'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13','WSAS18', 'WSAS19', 'WSAS20', 'WSAS22', 'WSAS25'};
% Phase = {'Base', 'Anes', 'Reco'};

%P_IDS = {'WSAS02', 'WSAS05', 'WSAS09', 'WSAS10', 'WSAS11', 'WSAS12', 'WSAS13','WSAS18', 'WSAS19', 'WSAS20', 'WSAS22',...
%    '002MG', '003MG', '004MG', '004MW', '005MW', '006MW', '007MG', '009MG', '010MG', 'MDFA05', 'MDFA06', 'MDFA11', 'MDFA15', 'MDFA17'};
%Phase = {'Base', 'Anes'};

% This list contains all participant IDs
P_IDS = {'WSAS28'};
Phase = {'Baseline', 'Anes', 'Reco'};


%% d/w pli Parameters:
p_value = 0.05;
number_surrogate = 20;

if FREQUENCY == "alpha"
    low_frequency = 7;
    high_frequency = 13;
elseif FREQUENCY == "theta"
    low_frequency = 4;
    high_frequency = 8;
elseif FREQUENCY == "delta"
    low_frequency = 1;
    high_frequency = 4;
end


% Size of the cuts for the data
window_size = 10; % in seconds
%this parameter is set to 1 (overlapping windows)and 10(non-overlapping windows).
step_size = 10; % in seconds


%% loop over all particiopants and stepsizes and calculate dpli
for p = 1:length(P_IDS)
    p_id = P_IDS{p};
    for c = 1:length(Phase)
        cond = Phase{c};

        fprintf("Analyzing functional connectivity of participant '%s' in '%s' \n", p_id,cond);

        %participant_in = strcat(p_id, '_',cond,'_5min.set');
        participant_in = strcat(p_id, '_',cond,'_CLEAN.set');
        %participant_in = strcat('sub-',p_id, '_task-',cond,'_eeg','.set');
        participant_out_path_wpli = strcat(OUTPUT_DIR,'wpli_',FREQUENCY,'_',p_id,'_',cond,'.mat');            
        participant_out_path_dpli = strcat(OUTPUT_DIR,'dpli_',FREQUENCY,'_',p_id,'_',cond,'.mat');            

        %participant_channel_path = strcat(OUTPUT_DIR,'step',step_size,'/dPLI_',FREQUENCY,'_step',step_size,'_',p_id,'_channels.mat');            

        %% Load data
        recording = load_set(participant_in,INPUT_DIR);
        sampling_rate = recording.sampling_rate;
        
        frequency_band = [low_frequency high_frequency]; % This is in Hz

        %% calculate FC
        % calculate dPLI with NEUROALGO
        result_dpli = na_dpli_parallel(recording, frequency_band, window_size, step_size, number_surrogate, p_value);
        
        % calculate wPLI with NEUROALGO
        result_wpli = na_wpli_parallel(recording, frequency_band, window_size, step_size, number_surrogate, p_value);
        
        %% save data
        save(participant_out_path_wpli,'result_wpli')
        save(participant_out_path_dpli,'result_dpli')

    end
end
