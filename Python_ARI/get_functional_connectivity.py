#!/usr/bin/env python
import os
import mne
import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys
import warnings
warnings.filterwarnings("ignore")
sys.path.append("..")
from utils.BIAPT_Connectivity_parallel import connectivity_compute
from functools import reduce

FREQUENCIES  = {
  "delta": (1,4),
  "theta": (4,8),
  "alpha": (8,13),
  "beta": (13,30),
  "gamma": (30,45),
  "fullband": (1,45),
  }

WINDOW_LENGTH = 10
N_SURROGATES = 20

def data_import(input_dir, p_id, cond):
    # define epoch name
    #input_fname =  f"{input_dir}/sub-{p_id}/eeg/epochs_{p_id}_{cond}.fif"
    #raw_data = mne.read_epochs(input_fname)

    try:
        input_fname =  f"{input_dir}/{p_id}_{cond}_5min.set"
        raw_data = mne.io.read_raw_eeglab(input_fname)
    except:
        raw_data = None

    if raw_data == None:
        try:
            input_fname =  f"{input_dir}/{p_id}_{cond}_eeg.fif"
            raw_data = mne.read_epochs(input_fname)
        except:
            raw_data = None

    if raw_data == None:
        try:
            input_fname =  f"{input_dir}/{p_id}_{cond}_5min.fif"
            raw_data = mne.read_epochs(input_fname)
        except:
            raw_data = None

    if raw_data == None:
        try:
            input_fname =  f"{input_dir}/sub-{p_id}/eeg/sub-{p_id}_task-{cond}_epoch_eeg.fif"
            raw_data = mne.read_epochs(input_fname)
        except:
            raw_data = None
    # remove channels marked as bad and non-brain channels
    if raw_data:
        raw_data.drop_channels(raw_data.info['bads'])
        raw_data.load_data()



    #crop data if necessary
    #if len(raw_epochs) > 30:
    #    epochs_cropped = raw_epochs[-30:]
    #else:
    #    epochs_cropped = raw_epochs.copy()

    return raw_data


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Calculates wPLI or dPLI functional connectivity.')
    parser.add_argument('-input_dir', type=str,
                        help='folder name containing the data in epoched .fif data in BIDS format')
    parser.add_argument('-output_dir', type=str,
                        help='folder name where to save the functional connectivity')
    parser.add_argument('-participants', type=str,
                        help='path to txt with information about participants')
    parser.add_argument('-frequencyband', type=str,
                        help='lower and upper filer frequency')
    parser.add_argument('-id', type = int, # default = None,
                        help='Participant ID to compute')
    parser.add_argument('-mode', type = str,
                        help='type of connectivity to compute can be wpli or dpli')
    parser.add_argument('-stepsize', type = int,
                        help='in seconds: stepsize for windows of 10 seconds ')
    parser.add_argument('-conditions', type = str, nargs='+',
                        help='List of conditions to analyze')
    args = parser.parse_args()

    ################################################################
    #       1)    PREPARE IN-AND OUTPUT                            #
    ################################################################

    # make ouput directory
    output_dir = os.path.join(args.output_dir, f'{args.mode}_{args.frequencyband}')
    os.makedirs(output_dir, exist_ok=True)

    # load patient IDS
    info = pd.read_csv(args.participants, sep='\t')
    P_IDS = [info['Patient'][args.id]] if args.id is not None else info['Patient']

    l_freq, h_freq = FREQUENCIES[args.frequencyband]

    conds = args.conditions

    for p_id in P_IDS:
        # create second list that only contains conditions whihc exist for this patient
        c_exist = []
        for c in conds:
            # import data from all conditions
            locals()['epochs_'+c] = data_import(args.input_dir, p_id, cond=c)
            if locals()['epochs_'+c] == None:
                print(f'NO DATA FOUND for {c}')
            else:
                c_exist.append(c)


        # find channels that exist in both datasets and drop others
        all_channels = []
        for c in c_exist:
            all_channels.append(locals()['epochs_'+c].info['ch_names'])

        intersect = reduce(np.intersect1d, tuple(all_channels))

        # drop channels which do not intersect between states, and resample to 250 Hz
        for c in c_exist:
            locals()['drop_'+c] = set(locals()['epochs_'+c].info['ch_names']) ^ set(intersect)
            locals()['epochs_'+c].drop_channels(locals()['drop_'+c])
            locals()['epochs_'+c].resample(sfreq=250)
            locals()['data_'+c] = np.array(locals()['epochs_'+c]._data)

        sfreq = 250

        arguments = (WINDOW_LENGTH, args.stepsize, l_freq, h_freq, sfreq)
        kwargs = {"mode": args.mode, "verbose": True, "n_surrogates": N_SURROGATES}

        # calculate FC for every existing condition
        for c in c_exist:

            # concatenate data if necessary:
            if len(locals()['data_'+c].shape) == 3:
                locals()['data_conc_'+c] = np.concatenate(list(locals()['data_'+c]), axis=1)

            #calculate FC
            locals()['fc_'+c] = connectivity_compute(locals()['data_conc_'+c], *arguments, **kwargs)
            locals()['average_fc_'+c] = np.mean(locals()['fc_'+c], axis=0)

        # Save final FC matrices and info
        for c in c_exist:
            np.save(os.path.join(output_dir, f"{args.mode}_{args.frequencyband}_{p_id}_{c}_info.npy"), locals()['epochs_'+c].info)
            np.save(os.path.join(output_dir, f"{args.mode}_{args.frequencyband}_{p_id}_{c}.npy"), locals()['fc_'+c])
