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
    parser.add_argument('-output_dir', type=str,
                        help='folder name to save the ARI results')
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
    current_hemisphere = []
    electrode_percents =[]
    
    hemispheres = ['Right','Left','Whole']

    # for extracted hemispheres
    channels_to_extract =[]
    state1_indices_to_extract =[]
    state2_indices_to_extract =[]
    wpli_state1_singlehem =[]
    wpli_state2_singlehem =[]
    dpli_state1_singlehem =[]
    dpli_state2_singlehem =[]


    for p_id in P_IDS:

        # load FC data
        wpli_1 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S1}.npy")
        wpli_2 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S2}.npy")

        # load FC data
        dpli_1 = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{S1}.npy")
        dpli_2 = np.load(f"{args.input_dir}/dPLI_{args.frequencyband}/dPLI_{args.frequencyband}_{p_id}_{S2}.npy")

        info1 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S1}_info.npy",allow_pickle=True)
        info1 = info1.tolist()
        ch_names1 = info1.ch_names

        info2 = np.load(f"{args.input_dir}/wPLI_{args.frequencyband}/wPLI_{args.frequencyband}_{p_id}_{S2}_info.npy",allow_pickle=True)
        info2 = info2.tolist()
        ch_names2 = info2.ch_names

        for hemisphere in hemispheres:
            if hemisphere == 'Right':
                right_hemisphere_channels_all = ['E15', 'E1', 'E9', 'E16', 'E10', 'E3', 'E2', 'E11', 'E4', 'E124', 'E123', 'E122', 'E5', 
                                         'E118', 'E117', 'E116', 'E6', 'E112', 'E111', 'E110', 'E106', 'E105', 'E104', 'E103', 'Cz', 
                                         'E80', 'E87', 'E93', 'E55', 'E79', 'E98', 'E86', 'E92', 'E97', 'E78', 'E62', 'E85', 'E77', 
                                         'E91', 'E72', 'E96', 'E76', 'E84', 'E75', 'E83', 'E90', 'E95', 'E82', 'E89', 'E121', 'E114', 
                                         'E115', 'E109', 'E102', 'E108', 'E101', 'E100']
                
                right_hemisphere_channels_all = np.array(right_hemisphere_channels_all).reshape(-1,1) #to create the array same way as ch_names1

                #select right hemisphere channels in state1 file
                right_hemisphere_channels_state1 = [channel for channel in ch_names1 if channel in right_hemisphere_channels_all]
                #select right hemisphere channels in state2 file
                right_hemisphere_channels_state2 = [channel for channel in ch_names2 if channel in right_hemisphere_channels_all]
                #select overlapping channels between 2 states
                right_hemisphere_channels_2states = [channel for channel in right_hemisphere_channels_state1 if channel in right_hemisphere_channels_state2]
                
                channels_to_extract= right_hemisphere_channels_2states
                electrode_percent = len(channels_to_extract)/57
                
            elif hemisphere == 'Left':
                left_hemisphere_channels_all = np.array(['E15', 'E32', 'E22', 'E16', 'E18', 'E23', 'E26', 'E11', 'E19', 'E24', 'E27', 'E33', 
                                        'E12', 'E20', 'E28', 'E34', 'E6', 'E13', 'E29', 'E35', 'E7', 'E30', 'E36', 'E41', 'Cz', 
                                        'E31', 'E37', 'E42', 'E55', 'E54', 'E47', 'E53', 'E52', 'E51', 'E61', 'E62', 'E60', 'E67', 
                                        'E59', 'E72', 'E58', 'E71', 'E66', 'E75', 'E70', 'E65', 'E64', 'E74', 'E69', 'E38', 'E44', 
                                        'E39', 'E40', 'E46', 'E45', 'E50', 'E57'])
                
                left_hemisphere_channels_all = np.array(left_hemisphere_channels_all).reshape(-1,1) #to create the array same way as ch_names1

                #select left hemisphere channels in state1 file
                left_hemisphere_channels_state1 = [channel for channel in ch_names1 if channel in left_hemisphere_channels_all]
                #select left hemisphere channels in state2 file
                left_hemisphere_channels_state2 = [channel for channel in ch_names2 if channel in left_hemisphere_channels_all]
                #select overlapping channels between 2 states
                left_hemisphere_channels_2states = [channel for channel in left_hemisphere_channels_state1 if channel in left_hemisphere_channels_state2]
                
                channels_to_extract= left_hemisphere_channels_2states
                electrode_percent = len(channels_to_extract)/57 
            
            elif hemisphere == 'Whole':
                whole_hemisphere_channels_2states = [channel for channel in ch_names1 if channel in ch_names2]
                channels_to_extract= whole_hemisphere_channels_2states
                electrode_percent = len(channels_to_extract)/105 #  total # of brain electrodes

            else:
                break

            # indices to be extracted from original file
            state1_indices_to_extract = [ch_names1.index(channel) for channel in channels_to_extract]
            state2_indices_to_extract = [ch_names2.index(channel) for channel in channels_to_extract]

            #wpli extracted
            wpli_state1_singlehem = wpli_1[:, state1_indices_to_extract][:, :, state1_indices_to_extract]
            wpli_state2_singlehem = wpli_2[:, state2_indices_to_extract][:, :, state2_indices_to_extract]

            #dpli extracted
            dpli_state1_singlehem = dpli_1[:, state1_indices_to_extract][:, :, state1_indices_to_extract]
            dpli_state2_singlehem = dpli_2[:, state2_indices_to_extract][:, :, state2_indices_to_extract]

            dPLI_ARI_tmp, Hub_ARI_tmp = calculate_ARI_2state(wpli_state1_singlehem, wpli_state2_singlehem, dpli_state1_singlehem, dpli_state2_singlehem)

            dPLI_ARI.append(dPLI_ARI_tmp)
            Hub_ARI.append(Hub_ARI_tmp)
            IDS.append(p_id)
            current_hemisphere.append(hemisphere)
            electrode_percents.append(electrode_percent)


            # save in progress dataframe
            output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI,'Hemisphere':current_hemisphere,'electrode_percent':electrode_percents}
            output_df = pd.DataFrame(output_df) 
            output_df.to_csv(f'{args.output_dir}/2state_ARI_{S1}_{S2}_{args.frequencyband}.txt', index=False, sep=',') 
            

# save in progress dataframe
#output_df = {'ID':IDS, 'dPLI_ARI':dPLI_ARI,'Hub_ARI':Hub_ARI,'Hemisphere':hemisphere}
#output_df = pd.DataFrame(output_df)
#output_df.to_csv(f'{args.output_dir}/2state_ARI_{S1}_{S2}_{args.frequencyband}_singlehem.txt', index=False, sep=',')