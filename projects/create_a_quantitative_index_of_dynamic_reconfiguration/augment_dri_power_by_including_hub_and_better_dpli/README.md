# Report for Augment DRI Power by Including Hub and Better dPLI
This is the report for the milestone `Augment DRI Power by Including Hub and Better dPLI`. You will find figures, results and general explanation on the codebase ( all the figures are in the hidden folder `.figure`).

**Goal**: Build upon the rough dpli contrast index that we created in the [Create Rough dPLI Contrast Index](../create_rough_dpli_contrast_indexes/README.md) milestone. What we came up with was that the attempt 4 and 5 in that milestone were promising. The next steps were to add wpli based hub location and to try a last way of weighting the attempt 5 in order to have a FP metric that is weighting more the channels that flip from phase lead to phase lag (or vice versa).

## Table of Content
- [dPLI Dynamic Reconfiguration Index](#dpli-dynamic-reconfiguration-index)
  - [Weighted FP Contrast Matrix](#weighted-fp-contrast-matrix)
  - [Attempt #6](#attempt-6)

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