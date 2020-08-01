%% Yacine Mahdid April 08 2020
% This script is addressing a part of this task : https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/10

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";
MAP_FILE = "/home/yacine/Documents/BIAPT/awareness-perturbation-complexity-index/projects/create_a_quantitative_index_of_dynamic_reconfiguration/data/bp_to_egi_mapping_yacine.csv";


%% Fixing the participant data
% Here we are simply checking if the function process_bp_dpli is working
% properly. Since it was working it was promoted to a utility function for
% the other experiment
[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_bp_dpli(strcat(IN_DIR,"WSAS02",filesep,'baseline_alpha_dpli.mat'), MAP_FILE);