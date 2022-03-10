% EEGLAB history file generated on the 11-Feb-2022
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','sub-008MW_task-sedon1_eeg.set','filepath','/Users/charlotte/Documents/GitHub/ARI/milestones/NET_ICU_ARI/data/raw/BIDS_NET_ICU/sub-008MW/eeg/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw;
