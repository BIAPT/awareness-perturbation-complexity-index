
import os
import numpy as np
from utils.data_import import filter_channels
from utils.BIAPT_Connectivity import connectivity_compute


def calculate_dirhub_ARI(dpli_Base, dpli_Anes, dpli_Reco ):

        ################################################################
        #       1)    make average dpli                       #
        ################################################################
        average_dpli_Base = np.mean(dpli_Base, axis=0)
        average_dpli_Anes = np.mean(dpli_Anes, axis=0)
        average_dpli_Reco = np.mean(dpli_Reco, axis=0)

        ################################################################
        #       2)    Calculate dPLI HUB                               #
        ################################################################
        node_degree_Base = (np.sum(average_dpli_Base, axis=0))
        node_degree_Anes = (np.sum(average_dpli_Anes, axis=0))
        node_degree_Reco = (np.sum(average_dpli_Reco, axis=0))

        # normalize
        norm_degree_Base = (node_degree_Base - np.mean(node_degree_Base)) / np.std(node_degree_Base);
        norm_degree_Anes = (node_degree_Anes - np.mean(node_degree_Anes)) / np.std(node_degree_Anes);
        norm_degree_Reco = (node_degree_Reco - np.mean(node_degree_Reco)) / np.std(node_degree_Reco);

        ################################################################
        #       4)    Calculate calculate_ARI                       #
        ################################################################
        BvA = np.sum(np.abs(node_degree_Base - node_degree_Anes))
        RvA = np.sum(np.abs(node_degree_Reco - node_degree_Anes))
        BvR = np.sum(np.abs(node_degree_Base - node_degree_Reco))
        dirHub_ARI = BvA + RvA - BvR;
        # normalize with length of nr_channels
        dirHub_ARI = dirHub_ARI/average_dpli_Base.shape[0]

        BvA = np.sum(np.abs(norm_degree_Base - norm_degree_Anes))
        RvA = np.sum(np.abs(norm_degree_Reco - norm_degree_Anes))
        BvR = np.sum(np.abs(norm_degree_Base - norm_degree_Reco))
        normdirHub_ARI = BvA + RvA - BvR;
        # normalize with length of nr_channels
        normdirHub_ARI = normdirHub_ARI/average_dpli_Base.shape[0]


        return dirHub_ARI, normdirHub_ARI
