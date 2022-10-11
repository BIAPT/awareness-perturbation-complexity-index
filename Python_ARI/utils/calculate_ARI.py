
import os
import numpy as np
from utils.data_import import filter_channels
from utils.BIAPT_Connectivity import connectivity_compute


def calculate_ARI(wpli_Base, wpli_Anes, wpli_Reco, dpli_Base, dpli_Anes, dpli_Reco ):

        ################################################################
        #       1)    make average wpli and dpli                       #
        ################################################################
        average_wpli_Base = np.mean(wpli_Base, axis=0)
        average_wpli_Anes = np.mean(wpli_Anes, axis=0)
        average_wpli_Reco = np.mean(wpli_Reco, axis=0)

        average_dpli_Base = np.mean(dpli_Base, axis=0)
        average_dpli_Anes = np.mean(dpli_Anes, axis=0)
        average_dpli_Reco = np.mean(dpli_Reco, axis=0)

        ################################################################
        #       2)    Calculate wPLI HUB                               #
        ################################################################
        node_degree_Base = (np.sum(average_wpli_Base, axis=0))
        node_degree_Anes = (np.sum(average_wpli_Anes, axis=0))
        node_degree_Reco = (np.sum(average_wpli_Reco, axis=0))

        # normalize
        norm_degree_Base = (node_degree_Base - np.mean(node_degree_Base)) / np.std(node_degree_Base);
        norm_degree_Anes = (node_degree_Anes - np.mean(node_degree_Anes)) / np.std(node_degree_Anes);
        norm_degree_Reco = (node_degree_Reco - np.mean(node_degree_Reco)) / np.std(node_degree_Reco);

        ################################################################
        #       4)    Calculate calculate_ARI                       #
        ################################################################
        BvA = np.sum(np.abs(average_dpli_Base - average_dpli_Anes), axis=(0,1))
        RvA = np.sum(np.abs(average_dpli_Reco - average_dpli_Anes), axis=(0,1))
        BvR = np.sum(np.abs(average_dpli_Base - average_dpli_Reco), axis=(0,1))
        dPLI_ARI = BvA + RvA - BvR;
        # normalize with length of nr_channels
        dPLI_ARI = dPLI_ARI/average_dpli_Base.shape[0]

        BvA = np.sum(np.abs(norm_degree_Base - norm_degree_Anes))
        RvA = np.sum(np.abs(norm_degree_Reco - norm_degree_Anes))
        BvR = np.sum(np.abs(norm_degree_Base - norm_degree_Reco))
        Hub_ARI = BvA + RvA - BvR;
        # normalize with length of nr_channels
        Hub_ARI = Hub_ARI/average_dpli_Base.shape[0]

        return dPLI_ARI, Hub_ARI
