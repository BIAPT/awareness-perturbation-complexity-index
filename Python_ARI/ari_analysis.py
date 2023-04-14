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
    parser.add_argument('-participants', type=str,
                        help='path to txt with information about participants')
    parser.add_argument('-frequencyband', type=str,
                        help='lower and upper filer frequency')

    args = parser.parse_args()

    # load patient IDS
    P_IDS = pd.read_csv(args.participants, sep='\t')['Patient']

    dPLI_ARI = []
    Hub_ARI = []
    IDS = []

    for p_id in P_IDS:

        # load FC data
        wpli_Base = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base.npy")
        wpli_Anes = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Anes.npy")
        wpli_Reco = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Reco.npy")

        # load FC data
        dpli_Base = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Base.npy")
        dpli_Anes = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Anes.npy")
        dpli_Reco = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Reco.npy")

        info = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base_info.npy",allow_pickle=True)
        info = info.tolist()

        maxtime = 30 # min(dpli_Base.shape[0],dpli_Anes.shape[0],dpli_Reco.shape[0])
        # take shorter signal if it is too long

        if dpli_Base.shape[0] > maxtime+1:
            #start = int(np.round((dpli_Base.shape[0]-maxtime)/2))
            wpli_Base = wpli_Base[:maxtime]
            dpli_Base = dpli_Base[:maxtime]

        if dpli_Anes.shape[0] > maxtime+1:
            #start = int(np.round((dpli_Anes.shape[0]-maxtime)/2))
            wpli_Anes = wpli_Anes[:maxtime]
            dpli_Anes = dpli_Anes[:maxtime]

        if dpli_Reco.shape[0] > maxtime+1:
            #start = int(np.round((dpli_Reco.shape[0]-maxtime)/2))
            wpli_Reco = wpli_Reco[:maxtime]
            dpli_Reco = dpli_Reco[:maxtime]

        dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI(wpli_Base, wpli_Anes, wpli_Reco, dpli_Base, dpli_Anes, dpli_Reco)

        dPLI_ARI.append(dPLI_ARI_tmp)
        Hub_ARI.append(Hub_ARI_tmp)
        IDS.append(p_id)

        # save in progress dataframe
        output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI}

        # plot time-averaged FC
        fig, axs = plt.subplots(3, 3, figsize=(30,20))
        sns.heatmap(wpli_Base.mean(0), cmap='jet', ax=axs[0,0], vmin=0, vmax=0.2)
        sns.heatmap(wpli_Anes.mean(0), cmap='jet', ax=axs[0,1], vmin=0, vmax=0.2)
        sns.heatmap(wpli_Reco.mean(0), cmap='jet', ax=axs[0,2], vmin=0, vmax=0.2)

        sns.heatmap(dpli_Base.mean(0), cmap='jet', ax=axs[1,0], vmin=0.4, vmax=0.6)
        sns.heatmap(dpli_Anes.mean(0), cmap='jet', ax=axs[1,1], vmin=0.4, vmax=0.6)
        sns.heatmap(dpli_Reco.mean(0), cmap='jet', ax=axs[1,2], vmin=0.4, vmax=0.6)

        # plot Hub:
        node_degree_Base = list(np.sum(wpli_Base.mean(0), axis=0))
        norm_degree_Base = (node_degree_Base - np.mean(node_degree_Base)) / np.std(node_degree_Base)

        node_degree_Anes = list(np.sum(wpli_Anes.mean(0), axis=0))
        norm_degree_Anes = (node_degree_Anes - np.mean(node_degree_Anes)) / np.std(node_degree_Anes)

        node_degree_Reco = list(np.sum(wpli_Reco.mean(0), axis=0))
        norm_degree_Reco = (node_degree_Reco - np.mean(node_degree_Reco)) / np.std(node_degree_Reco)


        mne.viz.plot_topomap(norm_degree_Base, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[2,0])
        mne.viz.plot_topomap(norm_degree_Anes, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[2,1])
        mne.viz.plot_topomap(norm_degree_Reco, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[2,2])

        axs[0,1].set_title(p_id, fontsize = 20)

        plt.savefig(os.path.join(f'{args.input_dir}/{args.frequencyband}_{p_id}.png'))

        output_df = pd.DataFrame(output_df)
        output_df.to_csv(f'{args.input_dir}/ARI_3states_{args.frequencyband}.txt', index=False, sep=',')

        print(f'finished {p_id}')
