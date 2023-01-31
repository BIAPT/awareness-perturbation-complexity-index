# Code for ARI in Python:

## Steps :

#### step1 calculate FC
This code calculates wPLI (weighted Phase Lag Index), dPLI (directed Phase Lag Index) for paricipants and conditions.

python get_functional_connectivity.py \
    -input_dir ~/Documents/GitHub/ARI/Python_ARI/data/ \
    -output_dir ~/Documents/GitHub/ARI/Python_ARI/RESULTS \
    -participants ~/Documents/GitHub/ARI/Python_ARI/data/data_2states.txt \
    -frequencyband alpha \
    -mode wpli \
    -stepsize 10

python example_analysis.py \
    -input_dir ~/Documents/GitHub/ARI/Python_ARI/RESULTS \
    -participants ~/Documents/GitHub/ARI/Python_ARI/data/data_3states.txt \
    -frequencyband alpha


python 2_state_example_analysis.py \
    -input_dir ~/Documents/GitHub/ARI/Python_ARI/RESULTS \
    -participants ~/Documents/GitHub/ARI/Python_ARI/data/data_2states.txt \
    -frequencyband alpha\
    -state1 Base\
    -state2 Anes\
