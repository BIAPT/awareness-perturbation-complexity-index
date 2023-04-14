#!/usr/bin/env python
import os
import mne
import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import sys
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
        input_fname =  f"{input_dir}/sub-{p_id}/eeg/sub-{p_id}_task-{cond}_epoch_eeg.fif"
        raw_data = mne.read_epochs(input_fname)

    # remove channels marked as bad and non-brain channels
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

    # prepare output pdf
    pdf = PdfPages(os.path.join(output_dir, f"WSAS_{args.mode}_{args.frequencyband}_step_{args.stepsize}.pdf"))

    # load patient IDS
    info = pd.read_csv(args.participants, sep='\t')
    P_IDS = [info['Patient'][args.id]] if args.id is not None else info['Patient']

    l_freq, h_freq = FREQUENCIES[args.frequencyband]

    conds = args.conditions

    for p_id in P_IDS:

        for c in conds:
            try:
                # import data from all conditions
                locals()['epochs_'+c] = data_import(args.input_dir, p_id, cond=c)
            except:
                locals()[c + '_exist'] = False #if no Reco states available


        epochs_Base = data_import(args.input_dir, p_id, cond="Base")
        epochs_Anes = data_import(args.input_dir, p_id, cond="Anes")
        try:
            epochs_Reco = data_import(args.input_dir, p_id, cond="Reco")
            Reco_exist = True
        except:
            Reco_exist = False #if no Reco states available

        # find channels that exist in both datasets and drop others

        if Reco_exist:
            intersect = reduce(np.intersect1d, (epochs_Base.info['ch_names'], epochs_Anes.info['ch_names'], epochs_Reco.info['ch_names']))
        else:
            intersect = reduce(np.intersect1d, (epochs_Base.info['ch_names'], epochs_Anes.info['ch_names']))

        drop_A = set(epochs_Anes.info['ch_names']) ^ set(intersect)
        drop_B = set(epochs_Base.info['ch_names']) ^ set(intersect)
        if Reco_exist:
            drop_R = set(epochs_Reco.info['ch_names']) ^ set(intersect)

        epochs_Anes.drop_channels(drop_A)
        epochs_Anes.resample(sfreq=250)

        if Reco_exist:
            epochs_Reco.drop_channels(drop_R)
            epochs_Reco.resample(sfreq=250)


        epochs_Base.drop_channels(drop_B)
        epochs_Base.resample(sfreq=250)

        sfreq = int(epochs_Base.info['sfreq'])

        Anes = np.array(epochs_Anes._data)
        Base = np.array(epochs_Base._data)
        if Reco_exist:
            Reco = np.array(epochs_Reco._data)

        arguments = (WINDOW_LENGTH, args.stepsize, l_freq, h_freq, sfreq)
        kwargs = {"mode": args.mode, "verbose": True, "n_surrogates": N_SURROGATES}

        fc_Base = connectivity_compute(Base, *arguments, **kwargs)
        fc_Anes = connectivity_compute(Anes, *arguments, **kwargs)

        if Reco_exist:
            fc_Reco = connectivity_compute(Reco, *arguments, **kwargs)

        average_fc_Base = np.mean(fc_Base, axis=0)
        average_fc_Anes = np.mean(fc_Anes, axis=0)
        if Reco_exist:
            average_fc_Reco = np.mean(fc_Anes, axis=0)

        fig, axs = plt.subplots(1, 3, figsize=(15, 5))

        if args.mode == 'wpli':
            cmin = 0
            cmax = 0.35

        if args.mode == 'dpli':
            cmin = 0.5
            cmax = 0.75

        # plot time-averaged wPLI in PDF
        sns.heatmap(average_fc_Base, cmap='jet', ax=axs[0], vmin=cmin, vmax=cmax)
        sns.heatmap(average_fc_Anes, cmap='jet', ax=axs[1], vmin=cmin, vmax=cmax)
        axs[0].set_title(f"{args.mode} {args.frequencyband} {p_id} Base")
        axs[1].set_title(f"{args.mode} {args.frequencyband} {p_id} Anes")

        if Reco_exist:
            sns.heatmap(average_fc_Reco, cmap='jet', ax=axs[2], vmin=cmin, vmax=cmax)
            axs[2].set_title(f"{args.mode} {args.frequencyband} {p_id} Reco")
        pdf.savefig(fig)

        np.save(os.path.join(output_dir, f"{args.mode}_{args.frequencyband}_{p_id}_Base.npy"), fc_Base)
        np.save(os.path.join(output_dir, f"{args.mode}_{args.frequencyband}_{p_id}_Anes.npy"), fc_Anes)
        if Reco_exist:
            np.save(os.path.join(output_dir, f"{args.mode}_{args.frequencyband}_{p_id}_Reco.npy"), fc_Reco)

    pdf.close()
