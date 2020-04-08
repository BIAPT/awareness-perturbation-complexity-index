%% Yacine Mahdid April 08 2020
% This script is addressing a part of this task : https://github.com/BIAPT/awareness-perturbation-complexity-index/issues/10

%% Experiment Variables
IN_DIR = "/media/yacine/My Book/datasets/consciousness/Dynamic Reconfiguration Index/";
OUT_DIR = "/media/yacine/My Book/result_dri/dpli_dri/";

%% Fixing the participant data
[baseline_r_dpli, baseline_r_location, baseline_r_regions] = process_bp_dpli(strcat(IN_DIR,"WSAS02",filesep,'baseline_alpha_dpli.mat'));

% Here this is what we will be modifying to get a translated version
% of the bp headset
function [r_dpli, r_location, r_regions] = process_bp_dpli(filename)
    data = load(filename);

   % Extracting the data and channel location
   dpli = data.result_dpli.data.avg_dpli;
   location = data.result_dpli.metadata.channels_location;
   
   % At this point we have the bp_location
   

   [r_dpli, r_location, r_regions] = reorder_channels(dpli, location, 'biapt_egi129.csv');
end

