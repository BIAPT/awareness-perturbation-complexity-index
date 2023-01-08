#!/usr/bin/env python
import sys
sys.path.append("..")
from utils.BIAPT_Connectivity import connectivity_compute
from utils.data_import import data_import
from utils.calculate_ARI import calculate_ARI_2state
from utils.dpliHub_ARI import calculate_dirhub_ARI_2states
import numpy as np
import argparse
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

    args = parser.parse_args()

    # load patient IDS
    P_IDS = pd.read_csv(args.participants, sep='\t')['Patient']
    dPLI_ARI = []
    Hub_ARI = []
    dir_ARI = []
    IDS = []

    for p_id in P_IDS:

        # load FC data
        wpli_Base = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Base.npy")
        wpli_Anes = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_Anes.npy")

        # load FC data
        dpli_Base = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Base.npy")
        dpli_Anes = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_Anes.npy")

        dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI_2state(wpli_Base, wpli_Anes, dpli_Base, dpli_Anes)

        dirHub_ARI, normdirHub_ARI = calculate_dirhub_ARI_2states(dpli_Base, dpli_Anes)

        dir_ARI.append(dirHub_ARI)
        dPLI_ARI.append(dPLI_ARI_tmp)
        Hub_ARI.append(Hub_ARI_tmp)
        IDS.append(p_id)

        # save in progress dataframe
        output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI,'dirhub_ARI':dir_ARI}
        output_df = pd.DataFrame(output_df)
        output_df.to_csv('{}/2state_ARI.txt'.format(args.input_dir), index=False, sep=',')

        print(f'finished {p_id}')

    # save in progress dataframe
    output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI,'dirhub_ARI':dir_ARI}
    output_df = pd.DataFrame(output_df)
    output_df.to_csv('{}/2state_ARI.txt'.format(args.input_dir), index=False, sep=',')
