#!/usr/bin/env python
import sys
sys.path.append("..")
from utils.BIAPT_Connectivity import connectivity_compute
from utils.data_import import data_import
from utils.calculate_ARI import calculate_ARI
from utils.dpliHub_ARI import calculate_dirhub_ARI
from utils.calculate_ARI import calculate_norm_ARI
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import argparse
import os
import pandas as pd
import mne
import json
import warnings
warnings.filterwarnings("ignore")


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Calculates ARI using wPLI and dPLI functional connectivity.')
    parser.add_argument('-input_dir', type=str,
                        help='folder name containing the fc data')
    parser.add_argument('-participant', type=str,
                        help='which part to visualize')
    parser.add_argument('-frequencyband', type=str,
                        help='lower and upper filer frequency')


    args = parser.parse_args()

    # load patient IDS
    p_id = args.participant

    # load FC data
    wpli_Base = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base.npy")
    wpli_Indu = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Indu.npy")
    wpli_Anes = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Anes.npy")
    wpli_Emer = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Emer.npy")
    wpli_Reco = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Reco.npy")

    dpli_Base = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Base.npy")
    dpli_Indu = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Indu.npy")
    dpli_Anes = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Anes.npy")
    dpli_Emer = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Emer.npy")
    dpli_Reco = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Reco.npy")

    info = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base_info.npy",allow_pickle=True)
    info = info.tolist()

    conc_data = np.concatenate((wpli_Base,wpli_Indu,wpli_Anes,wpli_Emer,wpli_Reco))
    conc_dpli = np.concatenate((dpli_Base,dpli_Indu,dpli_Anes,dpli_Emer,dpli_Reco))

    start_Indu = len(wpli_Base)
    start_Anes = len(wpli_Base)+len(wpli_Indu)
    start_Emer = len(wpli_Base)+len(wpli_Indu)+len(wpli_Anes)
    start_Reco = len(wpli_Base)+len(wpli_Indu)+len(wpli_Anes)+len(wpli_Emer)

    for t in range(len(conc_data)-6):
        # plot time-averaged FC
        fig, axs = plt.subplots(3, 1, figsize=(20,40))
        fig, axs = plt.subplots(3, 1, figsize=(20,40))
        axs[0].plot(np.arange(len(conc_data),len(conc_data)))
        axs[0].axvspan(0,start_Indu, facecolor='green', alpha=0.2)
        axs[0].axvspan(start_Indu,start_Anes, facecolor='yellow', alpha=0.2)
        axs[0].axvspan(start_Anes,start_Emer, facecolor='orange', alpha=0.2)
        axs[0].axvspan(start_Emer,start_Reco, facecolor='yellow', alpha=0.2)
        axs[0].axvspan(start_Reco,len(conc_data), facecolor='green', alpha=0.2)
        axs[0].scatter(t,0.5, s= 400)

        # plot Hub:
        node_degree = list(np.sum(conc_data[t:t+6].mean(0), axis=0))
        norm_degree = (node_degree - np.mean(node_degree)) / np.std(node_degree)

        mne.viz.plot_topomap(norm_degree, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[1])

        sns.heatmap(conc_dpli[t:t+6].mean(0), cmap='jet', ax=axs[2], vmin=0.4, vmax=0.6)

        plt.savefig(os.path.join(f'{args.input_dir}/MOVIEFRAMES_{p_id}/movie_{t}.png'))

        print(f'finished {t}')
