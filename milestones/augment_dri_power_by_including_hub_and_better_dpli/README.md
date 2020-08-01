# Report for Augment DRI Power by Including Hub and Better dPLI
This is the report for the milestone `Augment DRI Power by Including Hub and Better dPLI`. You will find figures, results and general explanation on the codebase ( all the figures are in the hidden folder `.figure`).

**Goal**: Build upon the rough dpli contrast index that we created in the [Create Rough dPLI Contrast Index](../create_rough_dpli_contrast_indexes/README.md) milestone. What we came up with was that the attempt 4 and 5 in that milestone were promising. The next steps were to add wpli based hub location and to try a last way of weighting the attempt 5 in order to have a FP metric that is weighting more the channels that flip from phase lead to phase lag (or vice versa).

## Table of Content
- [dPLI Dynamic Reconfiguration Index](#dpli-dynamic-reconfiguration-index)
  - [Weighted FP Contrast Matrix](#weighted-fp-contrast-matrix)
  - [Attempt #6](#attempt-6)
- [wPLI per Participant](#wpli-per-participant)
- [Binarized wPLI per Participant](#binarized-wpli-per-participant)
- [Hub per Participant](#hub-per-participant)
- [Cosine Similarity per Participant](#cosine-similarity-per-participant)
- [Hub Dynamic Reconfiguration Index](#hub-dynamic-reconfiguration-index)
- [Both Dynamic Reconfiguration Index](#both-dynamic-reconfiguration-index)

## dPLI Dynamic Reconfiguration Index
The current version of the dpli-dri make use of contrast matrices and filters out all the region except the fronto-parietal ones. What we currently get in terms of dpli-dri for each of the participant is this:

![dPLI DRI Attempt #5](../.figure/dpli_dri_5.png)

## Weighted FP Contrast Matrix
Here for each participant we first filtered out all regions except the fronto-parietal ones. Then we applied the same algorithm to weight the resulting matrix than before with a `shift_weight` parameter which takes on the following values (1, 2, 10 or 100).

The algorithm is as follows:
```matlab
    % Here we shift the matrix1 matrix2 to check for crossing of the 0.5
    % mark
    shift_matrix1 = matrix1 - 0.5;
    shift_matrix2 = matrix2 - 0.5;
    
    % Here we want to have make a matrix that will give us a 1 for crossing
    % over and a 0 for not crossing over
    % We check which index in both shifted matrix are positive
    pos_matrix1 = shift_matrix1 > 0;
    pos_matrix2 = shift_matrix2 > 0;
    
    % We then add these two, we will get a value of 1 (one positive one
    % negative), 2 (both positive) or 0 (both negative)
    sign_matrix = pos_matrix1 + pos_matrix2;
    
    % To get the amount of crossing we put zeros everywhere and then only
    % modify the cross matrix for the index that are actually crossing.
    amount_crossing_matrix = abs(shift_matrix1 - shift_matrix2);
    cross_matrix = amount_crossing_matrix.*(sign_matrix == 1);
    
    % Finally to calculate the weight matrix we put the cross matrix
    % through the tanh function. Should give 0 for 0 values and a positive
    % value for positive input saturating at 1. We then shift that matrix
    % by 1 and weight it by the shift_weight. This will give us a 1 for the
    % region which don't cross and a scaling proportional to the amount of
    % crossing for actual cross.
    weight_matrix = shift_weight*tanh(cross_matrix) + 1;
    
    % We finally multiply the naive version of the contrast matrix with
    % the weight matrix.
    contrast_matrix = abs(matrix1 - matrix2).*weight_matrix;
```

We will mix the attempt 3 (which was weighting the contrast matrix more heavily if they were doing a switch lead/lag) with attempt 5 which was only taking the fronto-parietal regions into consideration.

We get the resulting matrix for a sample of two participant at each of the 4 `shift_weight` values (the rest of the participant have a similar dynamic). These were generated with `ex_21a_generate_dpli_contrast_matrix_only_fp_weighted.m`

### WSAS09
shift_weight = 1:
![WSAS09 weighted at 1 fp contrast matrix](./.figure/fp_weighted/WSAS09_alpha_weighted_1_contrast_fp_dpli.png)

shift_weight = 2:
![WSAS09 weighted at 2 fp contrast matrix](./.figure/fp_weighted/WSAS09_alpha_weighted_2_contrast_fp_dpli.png)

shift_weight = 10:
![WSAS09 weighted at 10 fp contrast matrix](./.figure/fp_weighted/WSAS09_alpha_weighted_10_contrast_fp_dpli.png)

shift_weight = 100:
![WSAS09 weighted at 100 fp contrast matrix](./.figure/fp_weighted/WSAS09_alpha_weighted_100_contrast_fp_dpli.png)

### WSAS20
shift_weight = 1:
![WSAS20 weighted at 1 fp contrast matrix](./.figure/fp_weighted/WSAS20_alpha_weighted_1_contrast_fp_dpli.png)

shift_weight = 2:
![WSAS20 weighted at 2 fp contrast matrix](./.figure/fp_weighted/WSAS20_alpha_weighted_2_contrast_fp_dpli.png)

shift_weight = 10:
![WSAS20 weighted at 10 fp contrast matrix](./.figure/fp_weighted/WSAS20_alpha_weighted_10_contrast_fp_dpli.png)

shift_weight = 100:
![WSAS20 weighted at 100 fp contrast matrix](./.figure/fp_weighted/WSAS20_alpha_weighted_100_contrast_fp_dpli.png)

As expected we get plot with higher contrast as we move up weighting. We should try all the weighting when creating the dpli-dri, however the choice of weight here is still a bit arbitrary.

### Attempt 6
Here are the dpli-dri attempt 6 with varying amount of shift_weight (1,2,10 and 100). These figures where generated with `ex_21b_generate_sixth_draft_dpli_dri.m`

shitf_weight = 1:
![dPLI DRI weight 1 for attempt 6](./.figure/dpli_dri_w_1_6.png)

shift_weight = 2:
![dPLI DRI weight 2 for attempt 6](./.figure/dpli_dri_w_2_6.png)

shift_weight = 10:
![dPLI DRI weight 10 for attempt 6](./.figure/dpli_dri_w_10_6.png)

shift_weight = 100:
![dPLI DRI weight 100 for attempt 6](./.figure/dpli_dri_w_100_6.png)

## wPLI per Participant
The matrix are normalized within subject with mean() +- 3*std. These matrices were generated using `ex_23_validate_wpli_matrices.m`:

### WSAS02
![WSAS02 wpli at Alpha](./.figure/WSAS02_alpha_wpli.png)

### WSAS05
![WSAS05 wpli at Alpha](./.figure/WSAS05_alpha_wpli.png)

### WSAS09
![WSAS09 wpli at Alpha](./.figure/WSAS09_alpha_wpli.png)

### WSAS10
![WSAS10 wpli at Alpha](./.figure/WSAS10_alpha_wpli.png)

### WSAS11
![WSAS11 wpli at Alpha](./.figure/WSAS11_alpha_wpli.png)

### WSAS12
![WSAS12 wpli at Alpha](./.figure/WSAS12_alpha_wpli.png)

### WSAS13
![WSAS13 wpli at Alpha](./.figure/WSAS13_alpha_wpli.png)

### WSAS17
![WSAS17 wpli at Alpha](./.figure/WSAS17_alpha_wpli.png)

### WSAS18
![WSAS18 wpli at Alpha](./.figure/WSAS18_alpha_wpli.png)

### WSAS19
![WSAS19 wpli at Alpha](./.figure/WSAS19_alpha_wpli.png)

### WSAS20
![WSAS20 wpli at Alpha](./.figure/WSAS20_alpha_wpli.png)

### WSAS22
![WSAS22 wpli at Alpha](./.figure/WSAS22_alpha_wpli.png)

## Binarized wPLI per Participant
Here we are trying various binary threshold in order to visualize their effect on the resulting binary wpli. This is important as the hub location currently needs a binarized matrix to work with. We show only participant 09 and 20, but all the other participant follow the same trend.

These plots were generated using `ex_24_generate_binarized_wpli_matrices.m`:

### WSAS09
threshold = 0.1:
![WSAS09 binarized wPLI at 0.1 matrix](./.figure/bin_wpli/WSAS09_alpha_wpli_binarized_0.1.png)
threshold = 0.2:
![WSAS09 binarized wPLI at 0.2 matrix](./.figure/bin_wpli/WSAS09_alpha_wpli_binarized_0.2.png)
threshold = 0.3:
![WSAS09 binarized wPLI at 0.3 matrix](./.figure/bin_wpli/WSAS09_alpha_wpli_binarized_0.3.png)


### WSAS20
threshold = 0.1:
![WSAS20 binarized wPLI at 0.1 matrix](./.figure/bin_wpli/WSAS20_alpha_wpli_binarized_0.1.png)
threshold = 0.2:
![WSAS20 binarized wPLI at 0.2 matrix](./.figure/bin_wpli/WSAS20_alpha_wpli_binarized_0.2.png)
threshold = 0.3:
![WSAS20 binarized wPLI at 0.3 matrix](./.figure/bin_wpli/WSAS20_alpha_wpli_binarized_0.3.png)


## Hub per Participant
Here we used three level of threshold to calculate the hub location. Threshold = 0.1, 0.2 and 0.3. We did this in order to be able to understand a bit better what effect the thresholding had on the resulting hub location. 
The script used to generate these topographic map is `ex_25_generate_hub_location_at_different_thresholds.m`

### WSAS02
threshold = 0.1
![WSAS02 Hub Location at 0.1](./.figure/hub_location/WSAS02_alpha_hub_0.1.png)
threshold = 0.2
![WSAS02 Hub Location at 0.2](./.figure/hub_location/WSAS02_alpha_hub_0.2.png)
threshold = 0.3
![WSAS02 Hub Location at 0.3](./.figure/hub_location/WSAS02_alpha_hub_0.3.png)

### WSAS05
threshold = 0.1
![WSAS05 Hub Location at 0.1](./.figure/hub_location/WSAS05_alpha_hub_0.1.png)
threshold = 0.2
![WSAS05 Hub Location at 0.2](./.figure/hub_location/WSAS05_alpha_hub_0.2.png)
threshold = 0.3
![WSAS05 Hub Location at 0.3](./.figure/hub_location/WSAS05_alpha_hub_0.3.png)

### WSAS09
threshold = 0.1
![WSAS09 Hub Location at 0.1](./.figure/hub_location/WSAS09_alpha_hub_0.1.png)
threshold = 0.2
![WSAS09 Hub Location at 0.2](./.figure/hub_location/WSAS09_alpha_hub_0.2.png)
threshold = 0.3
![WSAS09 Hub Location at 0.3](./.figure/hub_location/WSAS09_alpha_hub_0.3.png)

### WSAS10
threshold = 0.1
![WSAS10 Hub Location at 0.1](./.figure/hub_location/WSAS10_alpha_hub_0.1.png)
threshold = 0.2
![WSAS10 Hub Location at 0.2](./.figure/hub_location/WSAS10_alpha_hub_0.2.png)
threshold = 0.3
![WSAS10 Hub Location at 0.3](./.figure/hub_location/WSAS10_alpha_hub_0.3.png)

### WSAS11
threshold = 0.1
![WSAS11 Hub Location at 0.1](./.figure/hub_location/WSAS11_alpha_hub_0.1.png)
threshold = 0.2
![WSAS11 Hub Location at 0.2](./.figure/hub_location/WSAS11_alpha_hub_0.2.png)
threshold = 0.3
![WSAS11 Hub Location at 0.3](./.figure/hub_location/WSAS11_alpha_hub_0.3.png)

### WSAS12
threshold = 0.1
![WSAS12 Hub Location at 0.1](./.figure/hub_location/WSAS12_alpha_hub_0.1.png)
threshold = 0.2
![WSAS12 Hub Location at 0.2](./.figure/hub_location/WSAS12_alpha_hub_0.2.png)
threshold = 0.3
![WSAS12 Hub Location at 0.3](./.figure/hub_location/WSAS12_alpha_hub_0.3.png)

### WSAS13
threshold = 0.1
![WSAS13 Hub Location at 0.1](./.figure/hub_location/WSAS13_alpha_hub_0.1.png)
threshold = 0.2
![WSAS13 Hub Location at 0.2](./.figure/hub_location/WSAS13_alpha_hub_0.2.png)
threshold = 0.3
![WSAS13 Hub Location at 0.3](./.figure/hub_location/WSAS13_alpha_hub_0.3.png)

### WSAS17
threshold = 0.1
![WSAS17 Hub Location at 0.1](./.figure/hub_location/WSAS17_alpha_hub_0.1.png)
threshold = 0.2
![WSAS17 Hub Location at 0.2](./.figure/hub_location/WSAS17_alpha_hub_0.2.png)
threshold = 0.3
![WSAS17 Hub Location at 0.3](./.figure/hub_location/WSAS17_alpha_hub_0.3.png)

### WSAS18
threshold = 0.1
![WSAS18 Hub Location at 0.1](./.figure/hub_location/WSAS18_alpha_hub_0.1.png)
threshold = 0.2
![WSAS18 Hub Location at 0.2](./.figure/hub_location/WSAS18_alpha_hub_0.2.png)
threshold = 0.3
![WSAS18 Hub Location at 0.3](./.figure/hub_location/WSAS18_alpha_hub_0.3.png)

### WSAS19
threshold = 0.1
![WSAS19 Hub Location at 0.1](./.figure/hub_location/WSAS19_alpha_hub_0.1.png)
threshold = 0.2
![WSAS19 Hub Location at 0.2](./.figure/hub_location/WSAS19_alpha_hub_0.2.png)
threshold = 0.3
![WSAS19 Hub Location at 0.3](./.figure/hub_location/WSAS19_alpha_hub_0.3.png)

### WSAS20
threshold = 0.1
![WSAS20 Hub Location at 0.1](./.figure/hub_location/WSAS20_alpha_hub_0.1.png)
threshold = 0.2
![WSAS20 Hub Location at 0.2](./.figure/hub_location/WSAS20_alpha_hub_0.2.png)
threshold = 0.3
![WSAS20 Hub Location at 0.3](./.figure/hub_location/WSAS20_alpha_hub_0.3.png)

### WSAS22
threshold = 0.1
![WSAS22 Hub Location at 0.1](./.figure/hub_location/WSAS22_alpha_hub_0.1.png)
threshold = 0.2
![WSAS22 Hub Location at 0.2](./.figure/hub_location/WSAS22_alpha_hub_0.2.png)
threshold = 0.3
![WSAS22 Hub Location at 0.3](./.figure/hub_location/WSAS22_alpha_hub_0.3.png)

## Cosine Similarity per Participant
After calculating the hubs at different threshold we can then calculate the cosine simliarity between each of the state with each other states. The cosine similarity here ranges between -1 and 1 since we do have negative values. Before calculating the cosine similarity we do a standard normalization :`norm_weights = (weights - mean(weights))  / std(weights)`. We still calculate the hubs on three thresholds before feeding it to the cosine similarity. The plot were generated using `ex_26_calculate_cosine_similarity_across_states.m`.

### WSAS02
threshold = 0.1
![WSAS02 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS02_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS02 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS02_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS02 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS02_alpha_cosine_similarity_0.3.png)

### WSAS05
threshold = 0.1
![WSAS05 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS05_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS05 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS05_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS05 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS05_alpha_cosine_similarity_0.3.png)

### WSAS09
threshold = 0.1
![WSAS09 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS09_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS09 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS09_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS09 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS09_alpha_cosine_similarity_0.3.png)

### WSAS10
threshold = 0.1
![WSAS10 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS10_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS10 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS10_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS10 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS10_alpha_cosine_similarity_0.3.png)

### WSAS11
threshold = 0.1
![WSAS11 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS11_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS11 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS11_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS11 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS11_alpha_cosine_similarity_0.3.png)

### WSAS12
threshold = 0.1
![WSAS12 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS12_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS12 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS12_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS12 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS12_alpha_cosine_similarity_0.3.png)

### WSAS13
threshold = 0.1
![WSAS13 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS13_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS13 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS13_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS13 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS13_alpha_cosine_similarity_0.3.png)

### WSAS17
threshold = 0.1
![WSAS17 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS17_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS17 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS17_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS17 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS17_alpha_cosine_similarity_0.3.png)

### WSAS18
threshold = 0.1
![WSAS18 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS18_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS18 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS18_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS18 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS18_alpha_cosine_similarity_0.3.png)

### WSAS19
threshold = 0.1
![WSAS19 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS19_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS19 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS19_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS19 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS19_alpha_cosine_similarity_0.3.png)

### WSAS20
threshold = 0.1
![WSAS20 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS20_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS20 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS20_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS20 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS20_alpha_cosine_similarity_0.3.png)

### WSAS22
threshold = 0.1
![WSAS22 Cosine Similarity at 0.1](./.figure/cosine_similarity/WSAS22_alpha_cosine_similarity_0.1.png)
threshold = 0.2
![WSAS22 Cosine Similarity at 0.2](./.figure/cosine_similarity/WSAS22_alpha_cosine_similarity_0.2.png)
threshold = 0.3
![WSAS22 Cosine Similarity at 0.3](./.figure/cosine_similarity/WSAS22_alpha_cosine_similarity_0.3.png)

## Hub Dynamic Reconfiguration Index
The hub dynamic reconfiguration index takes the cosine similarity scalar and add them in a linear fashion. The formula that is currently being used is: `w1*BvR - (w2*BvA + w3*RvA)`
We are still generating the cosine similarity scalar at the three threshold 0.1, 0.2 and 0.3. The plot were generate using `ex_27_calculate_first_draft_hub_dri.m`

threshold = 0.1
![Hub DRI at 0.1](./.figure/hub_dri/hub_dri_0.1_1.png)
threshold = 0.2
![Hub DRI at 0.2](./.figure/hub_dri/hub_dri_0.2_1.png)
threshold = 0.3
![Hub DRI at 0.3](./.figure/hub_dri/hub_dri_0.3_1.png)

## Both Dynamic Reconfiguration Index
Here we use the Hub-DRI formula we have just calculated (still under the three thresholds) and we also calculate the 5th attempt of dpli-dri without the directional weighting. The patient that were marked as in recovery stage are WSAS02, 09, 19, 20 and the patient not recovered were marked as the rest. This was generated using `ex_28a_cluster_participant_on_dri_using_dpli_dri_5.m`

threshold = 0.1
![Both DRI at 0.1 attempt 1](./.figure/both_dri_0.1_1.png)
threshold = 0.2
![Both DRI at 0.2 attempt 2](./.figure/both_dri_0.2_1.png)
threshold = 0.3
![Both DRI at 0.3 attempt 3](./.figure/both_dri_0.3_1.png)

We also tested using the 6th definition of dpli-dri with switch_weight set to 100. This was generated using `ex_28b_cluster_participant_on_dri_using_dpli_dri_6.m`

![Both DRI at 0.1 attempt 2](./.figure/both_dri_0.1_2.png)
threshold = 0.2
![Both DRI at 0.2 attempt 2](./.figure/both_dri_0.2_2.png)
threshold = 0.3
![Both DRI at 0.3 attempt 2](./.figure/both_dri_0.3_2.png)

Finally we did a dynamic thresholding in order to not have to set up the threshold ourselves. We disconnected the graph until we got a minimally spanning graph. The plot was generated using `ex_33_generate_second_draft_dri_with_disconnection.m`

![Both DRI at dynamic threshold attempt 3](./.figure/both_dri_3.png)
