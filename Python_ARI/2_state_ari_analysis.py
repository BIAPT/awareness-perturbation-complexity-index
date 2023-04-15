#!/usr/bin/env python
import sys
sys.path.append("..")
from utils.BIAPT_Connectivity import connectivity_compute
from utils.data_import import data_import
from utils.calculate_ARI import calculate_ARI_2state
from utils.dpliHub_ARI import calculate_dirhub_ARI_2states
import numpy as np
import argparse
import matplotlib.pyplot as plt
import seaborn as sns
import mne
import os
import pandas as pd

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Calculates ARI using wPLI and dPLI functional connectivity.')
    parser.add_argument('-input_dir', type=str,
                        help='folder name containing the fc data')
    parser.add_argument('-participants', type=str,
                        help='path to txt with information about participants')
    parser.add_argument('-frequencyband', type=str,
                        help='lower and upper filer frequency')
    parser.add_argument('-state1', type=str,
                        help='Baseeline state to compare to ')
    parser.add_argument('-state2', type=str,
                        help='Second comparison state')


    args = parser.parse_args()
    S1 = args.state1
    S2 = args.state2

    # load patient IDS
    P_IDS = pd.read_csv(args.participants, sep='\t')['Patient']
    dPLI_ARI = []
    Hub_ARI = []
    dir_ARI = []
    IDS = []

    for p_id in P_IDS:

        # load FC data
        wpli_1 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S1}.npy")
        wpli_2 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S2}.npy")

        # load FC data
        dpli_1 = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{S1}.npy")
        dpli_2 = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{S2}.npy")

        info = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S1}_info.npy",allow_pickle=True)
        info = info.tolist()

        ch_names = info.ch_names
        #""" You can insert your code here which selects the channels you want to use and filters wPLI and dPLI accordingly."""


        dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI_2state(wpli_1, wpli_2, dpli_1, dpli_2)

        # only an experiment
        #dirHub_ARI, normdirHub_ARI = calculate_dirhub_ARI_2states(dpli_1, dpli_2)
        #dir_ARI.append(dirHub_ARI)

        dPLI_ARI.append(dPLI_ARI_tmp)
        Hub_ARI.append(Hub_ARI_tmp)
        IDS.append(p_id)

        # save in progress dataframe
        output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI}
        output_df = pd.DataFrame(output_df)
        output_df.to_csv(f'{args.input_dir}/2state_ARI_{S1}_{S2}_{args.frequencyband}.txt', index=False, sep=',')


        # visualize the FC
        # plot time-averaged FC
        fig, axs = plt.subplots(3, 2, figsize=(20,20))
        sns.heatmap(wpli_1.mean(0), cmap='jet', ax=axs[0,0], vmin=0, vmax=0.2)
        sns.heatmap(wpli_2.mean(0), cmap='jet', ax=axs[0,1], vmin=0, vmax=0.2)

        sns.heatmap(dpli_1.mean(0), cmap='jet', ax=axs[1,0], vmin=0.4, vmax=0.6)
        sns.heatmap(dpli_2.mean(0), cmap='jet', ax=axs[1,1], vmin=0.4, vmax=0.6)

        # plot Hub:
        node_degree_1 = list(np.sum(wpli_1.mean(0), axis=0))
        norm_degree_1 = (node_degree_1 - np.mean(node_degree_1)) / np.std(node_degree_1)

        node_degree_2 = list(np.sum(wpli_2.mean(0), axis=0))
        norm_degree_2 = (node_degree_2 - np.mean(node_degree_2)) / np.std(node_degree_2)

        mne.viz.plot_topomap(norm_degree_1, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[2,0])
        mne.viz.plot_topomap(norm_degree_2, info, vmin=0, vmax=1, show=False, cmap='jet', axes = axs[2,1])

        axs[0,1].set_title(p_id, fontsize = 20)

        plt.savefig(os.path.join(f'{args.input_dir}/2_state_{args.frequencyband}_{p_id}.png'))


        print(f'finished {p_id}')

    # save in progress dataframe
    output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI}
    output_df = pd.DataFrame(output_df)
    output_df.to_csv(f'{args.input_dir}/2state_ARI_{S1}_{S2}_{args.frequencyband}.txt', index=False, sep=',')
