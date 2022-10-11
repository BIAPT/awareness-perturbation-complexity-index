import scipy
import numpy as np
import sys
from scipy.io import loadmat
import pandas as pd
import argparse
#from utils import visualize
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from scipy.spatial import distance
import seaborn as sns
from utils import average_matrices as average_matrices
from matplotlib.backends.backend_pdf import PdfPages
import os
import mne

def data_import(input_dir, p_id, cond):
    # define epoch name
    input_fname =  f"{input_dir}/sub-{p_id}/eeg/epochs_{p_id}_{cond}.fif"
    raw_epochs = mne.read_epochs(input_fname)

    # remove channels marked as bad and non-brain channels
    raw_epochs.drop_channels(raw_epochs.info['bads'])

    #crop data if necessary
    if len(raw_epochs) > 30:
        epochs_cropped = raw_epochs[-30:]
    else:
        epochs_cropped = raw_epochs.copy()

    return epochs_cropped

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Calculates and plots network hubs')
    parser.add_argument('-data_dir', type=str, action='store',
                        help='folder name containing the data in epoched .fif data')
    parser.add_argument('-input_dir', type=str, action='store',
                        help='folder name containing the wPLI data')
    parser.add_argument('-output_dir', type=str, action='store',
                        help='folder name where to save the functional connectivity')
    parser.add_argument('-participants', type=str, action='store',
                        help='path to txt with information about participants')
    parser.add_argument('-frequencyband', type=str,
                        help='lower and upper filer frequency')
    args = parser.parse_args()


    """
           1)    PREPARE IN-AND OUTPUT
    """
    # make ouput directory
    output_dir = os.path.join(args.output_dir, f'wPLI_Plots')

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # prepare output pdf
    pdf = PdfPages(f"{output_dir}/Hubs_{args.frequencyband}.pdf")

    # load patient IDS
    info = pd.read_csv(args.participants, sep='\t')
    P_IDS = info['Patient']

    for p_id in P_IDS:
        """
        1)    IMPORT DATA
        """
        # import data from both conditions
        epochs_Base = data_import(args.data_dir, p_id, cond="Base")
        epochs_Anes = data_import(args.data_dir, p_id, cond="Anes")

        # find channels that exist in both datasets and drop others
        intersect = list(np.intersect1d(epochs_Base.info['ch_names'], epochs_Anes.info['ch_names']))
        drop_A = set(epochs_Anes.info['ch_names']) ^ set(intersect)
        drop_B = set(epochs_Base.info['ch_names']) ^ set(intersect)

        epochs_Anes.drop_channels(drop_A)
        Anes = np.concatenate(list(epochs_Anes), axis=1)

        epochs_Base.drop_channels(drop_B)
        Base = np.concatenate(list(epochs_Base), axis=1)

        # load FC data
        fc_Base = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base.npy")
        fc_Anes = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Anes.npy")

        average_fc_Base = np.mean(fc_Base, axis=0)
        average_fc_Anes = np.mean(fc_Anes, axis=0)

        node_degree_Base = list(np.sum(average_fc_Base, axis=0))
        node_degree_Anes = list(np.sum(average_fc_Anes, axis=0))

        norm_degree_Base = (node_degree_Base - np.mean(node_degree_Base)) / np.std(node_degree_Base);
        norm_degree_Anes = (node_degree_Anes - np.mean(node_degree_Anes)) / np.std(node_degree_Anes);

        """
        2)    Plot HUBS
        """
        fig = plt.figure(figsize = (10,3))
        ax = plt.subplot(131)
        ax.set_title(f"Base Hub {p_id}")
        ax, _ = mne.viz.plot_topomap(node_degree_Base, epochs_Base.info, show=False, cmap='jet')
        cbar = plt.colorbar(ax)
        cbar.ax.tick_params(labelsize=10)

        ax = plt.subplot(132)
        ax.set_title(f"Anes Hub {p_id}")
        ax, _ = mne.viz.plot_topomap(node_degree_Anes, epochs_Base.info, show=False, cmap='jet')
        cbar = plt.colorbar(ax)
        cbar.ax.tick_params(labelsize=10)
        pdf.savefig(fig)
        plt.close()

        # plot normalized Hubs
        fig = plt.figure(figsize = (10,3))
        ax = plt.subplot(131)
        ax.set_title(f"Base Norm Hub {p_id}")
        ax, _ = mne.viz.plot_topomap(norm_degree_Base, epochs_Base.info, vmin=0, vmax=1, show=False, cmap='jet')
        cbar = plt.colorbar(ax)
        cbar.ax.tick_params(labelsize=10)

        ax = plt.subplot(132)
        ax.set_title(f"Anes Norm Hub {p_id}")
        ax, _ = mne.viz.plot_topomap(norm_degree_Anes, epochs_Anes.info, vmin=0, vmax=1, show=False, cmap='jet')
        cbar = plt.colorbar(ax)
        cbar.ax.tick_params(labelsize=10)
        pdf.savefig(fig)
        plt.close()

        print(f"DONE {p_id} ")

    pdf.close()
