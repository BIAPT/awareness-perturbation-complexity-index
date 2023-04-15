# Code for ARI in Python:
please make sure you have installed the requirements.txt and that you are working in python at least 3.9

If you run those .py scripts, each scripts need input arguments. You can either put them all in one line:
`python test.py -input1 INPUT -Argument2 INPUT2`

Alternatively, if you put them in multiple lines you need to end your line with `\`. If there are extra speces behind the \ it will not work! (It will give you a  command not found: error)
`python test.py\
   -input1 INPUT\
   -Argument2 INPUT2`

##  <ins>step1 calculate FC </ins>
This code calculates wPLI (weighted Phase Lag Index), dPLI (directed Phase Lag Index) for paricipants and conditions.
To get information about the requited arguments, please type `python get_functional_connectivity.py -h`
If you feed multiple conditions to the function, only channels which are present in all conditions are kept, so that the output FC matrices for one subject have the same dimension in all three conditions.

As an example of how to call this script, see below for *WSAS*:

`python get_functional_connectivity.py \
    -input_dir DATA/data_original/ \
    -output_dir RESULTS/WSAS/ \
    -participants DATA/data_original/data_2states.txt \
    -frequencyband alpha \
    -mode wpli \
    -stepsize 10 \
    -conditions Base Anes Reco`

As an example of how to call this script, see below for *NET-ICU*:
(Please note that you can rerun the script with a participant file containing only subjects who have 2 or 3 states)
`python get_functional_connectivity.py \
    -input_dir DATA/NET-ICU_derivative_standard/ \
    -output_dir RESULTS/NET-ICU/ \
    -participants DATA/NET-ICU_derivative_standard/data_3states.txt \
    -frequencyband alpha \
    -mode wpli \
    -stepsize 10 \
    -conditions sedon1 sedoff sedon2`

##### OUTPUT:
Calling `get_functional_connectivity.py` creates a folder for your output. In the example above, this folder will be called RESULTS/WSAS or RESULTS/NET-ICU. Inside, you will get subfolders with wPLI_frequencyband and dPLI_frequencyband (depending on chosen mode.)

The folders contain:
- Functional connectivity matrices (3D) for all subjects and conditions
- An Info file for each FC matrix. Info files are mne.info objects https://mne.tools/stable/generated/mne.Info.html

---

##  <ins>step2 calculate ARI </ins>
This code calculates the ARI based on the wPLI (HUB) and dPLI. The code assumes all FC matrices of one subject to have the same number of channels. This is done automatically if you calculate FC for all three conditions at once, using the script above.  

To get information about the requited arguments, please type `python ari_analysis.py -h` or for the 2 state ARI `python 2_state_ari_analysis.py -h`

As an example of how to call this script, see below for *WSAS*:
`python ari_analysis.py \
    -input_dir RESULTS/WSAS/ \
    -participants DATA/data_original/data_3states.txt \
    -frequencyband alpha\
    -state1 Base \
    -state2 Anes \
    -state3 Reco`

As an example of how to call this script, see below for *NET-ICU*:

`python ari_analysis.py \
    -input_dir RESULTS/NETICU_test \
    -participants DATA/NET-ICU_derivative_standard/data_test.txt \
    -frequencyband alpha\
    -state1 sedon1\
    -state2 sedoff\
    -state3 sedon2`

<ins> Alternatively you can calculate the ARI for 2 states: </ins>

`python 2_state_ari_analysis.py \
    -input_dir RESULTS/WSAS/ \
    -participants DATA/data_original/data_3states.txt \
    -frequencyband alpha\
    -state1 sedon1\
    -state2 sedoff\`

##### OUTPUT:
Running ARI analysis outputs:
- ARI .txt file containing participant ID, dPLI and Hub reconfiguration
- a .png with wPLI, dPLI and Hub for all states


---
# Work In Progress Functions and other experiments:

# Get ARI for continuously segmented WSAS

1) Dynamic ARI analysis:

`python dynamic_ari_analysis.py\
    -input_dir RESULTS/WSAS_new/\
    -participants DATA/continuous_derivative_WSAS/data_dyn_states.txt\
    -frequencyband alpha\
    -compare_cond Base\
    -conditions Indu Anes Emer Reco`

`python hub-movie.py`

2) The utils folder contains the calculate_ARI script. This contains the classic ARI and 2_state ARI.
However it also contains some other experimentations (ARI_test3...) Those are not usd int the main scripts and still work in progress.
