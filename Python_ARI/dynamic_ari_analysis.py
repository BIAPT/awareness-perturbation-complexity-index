#!/usr/bin/env python
import sys
sys.path.append("..")
from utils.BIAPT_Connectivity import connectivity_compute
from utils.data_import import data_import
from utils.calculate_ARI import calculate_ARI_2state
import numpy as np
import argparse
import json
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
    parser.add_argument('-compare_cond', type = str,
                        help='Condition to compare to')
    parser.add_argument('-conditions', type = str, nargs='+',
                        help='List of conditions to analyze')

    args = parser.parse_args()
    conds = args.conditions
    base_cond = args.compare_cond

    # load patient IDS
    P_IDS = pd.read_csv(args.participants, sep='\t')['Patient']

    dPLI_ARI = []
    Hub_ARI = []
    IDS = []


    for p_id in P_IDS:
        # load FC data
        wpli_Base = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{base_cond}.npy")
        dpli_Base = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{base_cond}.npy")

        for c in conds:
            locals()['wpli_'+c] = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{c}.npy")
            locals()['dpli_'+c] = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{c}.npy")

        # calculate ARI over every minute in all states
        for c in conds:
            wpli = locals()['wpli_'+c]
            dpli = locals()['dpli_'+c]
            locals()['dPLI_ARI_'+c] = []
            locals()['Hub_ARI_'+c] = []

            for t in range(len(wpli)-6):
                #breakpoint()
                dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI_2state(wpli_Base, wpli[t:t+6], dpli_Base, dpli[t:t+6])
                locals()['dPLI_ARI_'+c].append(dPLI_ARI_tmp)
                locals()['Hub_ARI_'+c].append(Hub_ARI_tmp)

            #locals()['dPLI_ARI_'+c] = []
            #locals()['Hub_ARI_'+c] = []

            #for t in range(len(wpli)):
            #    dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI_2state(wpli_Base, wpli[:t], dpli_Base, dpli[:t])
            #    locals()['dPLI_ARI_'+c].append(dPLI_ARI_tmp)
            #    locals()['Hub_ARI_'+c].append(Hub_ARI_tmp)

        # save in progress dataframe
        output_dict = {'ID':p_id}
        for c in conds:
            name = 'dPLI_ARI_'+c
            output_dict[name] = locals()['dPLI_ARI_'+c]
            name = 'Hub_ARI_'+c
            output_dict[name] = locals()[name]

        with open(f'{args.input_dir}/ARI_dynamic_{args.frequencyband}_{p_id}.txt', 'w') as f:
            json.dump(output_dict, f)

        # get ARI from min max estimation:

        dPLI_ARI.append(np.max(dPLI_ARI_Anes))
        Hub_ARI.append(np.max(Hub_ARI_Anes))
        IDS.append(p_id)

        # save in progress dataframe
        output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI}


        output_df = pd.DataFrame(output_df)
        output_df.to_csv(f'{args.input_dir}/ARI_max_2states_{args.frequencyband}.txt', index=False)

        print(f'finished {p_id}')
