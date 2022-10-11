
import os
import numpy as np
from utils.data_import import filter_channels
from utils.BIAPT_Connectivity import connectivity_compute


def ARI(data_Base, data_Anes, data_Reco, frequency, OUT_DIR=False):

        FREQUENCIES  = {
          "delta": (1,4),
          "theta": (4,8),
          "alpha": (8,13),
          "beta": (13,30),
          "gamma": (30,45),
          "fullband": (1,45),
          }

        WINDOW_LENGTH = 10
        STEPSIZE = 10
        N_SURROGATES = 20
        # chose frequency
        l_freq, h_freq = FREQUENCIES[frequency]


        ################################################################
        #       1)    Load wpli data                          #
        ################################################################
        # find channels that exist in both datasets and drop others
        Base, Anes, Reco, sfreq= filter_channels(data_Base, data_Anes, data_Reco)

        ################################################################
        #       2)    Calculate wPLI                            #
        ################################################################
        arguments = (WINDOW_LENGTH, STEPSIZE, l_freq, h_freq, sfreq)
        kwargs = {"mode": 'wpli', "verbose": True, "n_surrogates": N_SURROGATES}

        wpli_Base = connectivity_compute(Base, *arguments, **kwargs)
        #wpli_Anes = connectivity_compute(Anes, *arguments, **kwargs)
        #wpli_Reco = connectivity_compute(Reco, *arguments, **kwargs)

        average_wpli_Base = np.mean(wpli_Base, axis=0)
        #average_wpli_Anes = np.mean(wpli_Anes, axis=0)
        #average_wpli_Reco = np.mean(wpli_Reco, axis=0)
        breakpoint()
        if bool(OUT_DIR):
            np.save(os.path.join(OUT_DIR, f"{'wpli'}_{frequency}_{p_id}_Base.npy"), wpli_Base)
            np.save(os.path.join(OUT_DIR, f"{'wpli'}_{frequency}_{p_id}_Anes.npy"), wpli_Anes)
            np.save(os.path.join(OUT_DIR, f"{'wpli'}_{frequency}_{p_id}_Reco.npy"), wpli_Reco)

        ################################################################
        #       3)    Calculate wPLI HUB                               #
        ################################################################
        node_degree_Base = list(np.sum(average_wpli_Base, axis=0))
        node_degree_Anes = list(np.sum(average_wpli_Anes, axis=0))
        node_degree_Reco = list(np.sum(average_wpli_Reco, axis=0))

        if bool(OUT_DIR):
            np.save(os.path.join(OUT_DIR, f"{'whub'}_{frequency}_{p_id}_Base.npy"), node_degree_Base)
            np.save(os.path.join(OUT_DIR, f"{'whub'}_{frequency}_{p_id}_Anes.npy"), node_degree_Anes)
            np.save(os.path.join(OUT_DIR, f"{'whub'}_{frequency}_{p_id}_Reco.npy"), node_degree_Reco)


        # normalize
        #norm_degree_Base = (node_degree_Base - np.mean(node_degree_Base)) / np.std(node_degree_Base);
        #norm_degree_Anes = (node_degree_Anes - np.mean(node_degree_Anes)) / np.std(node_degree_Anes);

        ################################################################
        #       4)    Calculate dPLI                            #
        ################################################################
        arguments = (WINDOW_LENGTH, STEPSIZE, l_freq, h_freq, sfreq)
        kwargs = {"mode": 'dpli', "verbose": True, "n_surrogates": N_SURROGATES}

        dpli_Base = connectivity_compute(Base, *arguments, **kwargs)
        dpli_Anes = connectivity_compute(Anes, *arguments, **kwargs)
        dpli_Reco = connectivity_compute(Reco, *arguments, **kwargs)

        average_dpli_Base = np.mean(dpli_Base, axis=0)
        average_dpli_Anes = np.mean(dpli_Anes, axis=0)
        average_dpli_Reco = np.mean(dpli_Reco, axis=0)

        if bool(OUT_DIR):
            np.save(os.path.join(OUT_DIR, f"{'dpli'}_{frequency}_{p_id}_Base.npy"), dpli_Base)
            np.save(os.path.join(OUT_DIR, f"{'dpli'}_{frequency}_{p_id}_Anes.npy"), dpli_Anes)
            np.save(os.path.join(OUT_DIR, f"{'dpli'}_{frequency}_{p_id}_Reco.npy"), dpli_Reco)

        ################################################################
        #       4)    Calculate calculate_ARI                       #
        ################################################################
        breakpoint()
        BvA = dpli_Base-dpli_Anes
        RvA = dpli_Reco-dpli_Anes
        BvR = dpli_Base-dpli_Reco

        ARI = sum(BvA) + sum(RvA) - sum(BvR);

        return ARI
