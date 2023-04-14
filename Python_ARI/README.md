# Code for ARI in Python:

## Steps :

#### step1 calculate FC
This code calculates wPLI (weighted Phase Lag Index), dPLI (directed Phase Lag Index) for paricipants and conditions.

python get_functional_connectivity.py \
    -input_dir DATA/data_original/ \
    -output_dir RESULTS/WSAS/ \
    -participants DATA/data_original/data_2states.txt \
    -frequencyband alpha \
    -mode wpli \
    -stepsize 10 \
    -conditions Base Anes Reco

python ari_analysis.py \               
    -input_dir RESULTS/WSAS/ \      
    -participants DATA/data_original/data_3states.txt \
    -frequencyband alpha  

# Get ARI for continuously segmented WSAS
python get_functional_connectivity.py \
    -input_dir DATA/continuous_derivative_WSAS/ \
    -output_dir RESULTS/WSAS_new/ \
    -participants DATA/continuous_derivative_WSAS/data_dyn_states.txt \
    -frequencyband alpha \
    -mode wpli \
    -stepsize 10 \
    -conditions Base Indu Anes Emer Reco

python ari_analysis.py \
    -input_dir RESULTS/WSAS_new/ \
    -participants DATA/continuous_derivative_WSAS/data_dyn_states.txt \
    -frequencyband alpha

python dynamic_ari_analysis.py\
    -input_dir RESULTS/WSAS_new/\
    -participants DATA/continuous_derivative_WSAS/data_dyn_states.txt\
    -frequencyband alpha\
    -compare_cond Base\
    -conditions Indu Anes Emer Reco


python 2_state_ari_analysis.py \
    -input_dir RESULTS/WSAS/ \
    -participants DATA/data_original/data_2states.txt \
    -frequencyband alpha\
    -state1 Base\
    -state2 Anes\

python 2_state_ari_analysis.py \
    -input_dir ~/Documents/GitHub/ARI/Python_ARI/RESULTS_NETICU \
    -participants ~/Documents/GitHub/ARI/Python_ARI/DATA/NET-ICU_derivative_standard/data_2states.txt\
    -frequencyband alpha\
    -state1 Sedon1\
    -state2 Sedoff\

# For dynamic ari_analysis\
python dynamic_ari_analysis.py \
    -input_dir RESULTS/WSAS_new\
    -participants ~/Documents/GitHub/ARI/Python_ARI/DATA/NET-ICU_derivative_standard/data_2states.txt\
    -frequencyband alpha \
    -compare_cond Sedon1\
    -conditions Sedoff


python get_functional_connectivity.py \
    -input_dir DATA/NET-ICU_derivative_standard/ \
    -output_dir RESULTS/NETICU \
    -participants DATA/NET-ICU_derivative_standard/data_2states.txt\
    -frequencyband alpha \
    -mode dpli \
    -stepsize 10\
    -conditions sedon1 sedoff


python dynamic_ari_analysis.py \
    -input_dir ~/Documents/GitHub/ARI/Python_ARI/RESULTS_dynamic\
    -participants ~/Documents/GitHub/ARI/Python_ARI/continuous_derivative_WSAS/data_dyn_states.txt \
    -frequencyband alpha \
    -compare_cond Base\
    -conditions Indu Anes Emer Reco
