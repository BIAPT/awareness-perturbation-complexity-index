%% Charlotte Maschke November 11 2020
% This script goal is to generate the dpli and wPLI matrices for the ARI 
% The matrices will be generated with non-overlapping 10s windows in the alpha bandwidth.  

FREQUENCY = "alpha";
%FREQUENCY = "theta";
%FREQUENCY = "delta";


% Remote Source Setup
%
INPUT_DIR = '/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data/raw/BIDS_NET_ICU';
OUTPUT_DIR = '/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data/connectivity/';

NEUROALGO_PATH = 'C:\Users\BIAPT\Documents\GitHub\NeuroAlgo\MATLAB';
%addpath(genpath(NEUROALGO_PATH)); % Add NA library to our path so that we can use it

%P_IDS = {'002MG', '003MG','004MG','010MG','011MG','012MG','014MG',...
% '016MG','017MG','018MG','019MG','020MG','023MG','024MG','025MG',...
% '026MG','027MG','028MG'};
%P_IDS={'003MW','004MW','007MG','005MW','009MG','006MW','013MG','022MG'};

P_IDS={'022MG'};

%Phase = {'sedon1', 'sedoff','sedon2'};
Phase = {'sedon2'};

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
DATA_dir = '/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data/raw/BIDS_NET_ICU';

%% loop over all particiopants and stepsizes and calculate dpli
for p = 1:length(P_IDS)
    p_id = P_IDS{p};
    for c = 1:length(Phase)
        cond = Phase{c};

        fprintf("Analyzing functional connectivity of participant '%s' in '%s' \n", p_id,cond);
        part_in = strcat(INPUT_DIR,'/sub-',p_id,'/eeg/');
        part_file = strcat('sub-',p_id, '_task-',cond,'_eeg.set');
        participant_out_path_wpli = strcat(OUTPUT_DIR,'wpli_',FREQUENCY,'_',p_id,'_',cond,'.mat');            
        participant_out_path_dpli = strcat(OUTPUT_DIR,'dpli_',FREQUENCY,'_',p_id,'_',cond,'.mat');            

        %% Load data
        recording = load_set(part_file, part_in);
        sampling_rate = recording.sampling_rate;
        frequency_band = [low_frequency high_frequency]; % This is in Hz
        
        len_signal = length(recording.data)/sampling_rate;
        
        % Crop the signal: only keep the last 5 min
        if len_signal > 300
            n1= (len_signal-300)*sampling_rate;  
            n2= len_signal*sampling_rate;
            eeg_cropped=recording.data(:,n1:n2);
        else
            eeg_cropped=recording.data(:,:);
        end
      
        recording.data = eeg_cropped;
        recording.length_recording = length(eeg_cropped);

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
