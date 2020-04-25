# Report of Create Rough dPLI Contrast Indexes 
This is the report for the milestone `create rough dpli contrast indexes`. You will find figures, results and general explanation on the codebase ( all the figures are in the hidden folder `.figure`).

## Why is the documentation here?
The documentation was in the wiki page of Github, I (yacine mahdid) decided to switch to an in-code documentation for two reasons:
1. To not be tied to Github for documenting and reporting
2. To be able to version control the documentation page

I'm open to other suggestions to document the code and the analysis, however due to the highly changing nature of the analysis it is difficult to keep the documentation up-to-date the further away from the code it lies.

## Table of Content
- [Code Structure](#code-structure)
- [Participant Information](#participant-information)
- [dPLI per Participant](#dpli-per-participant)
- [dPLI Similarity Matrix](#dpli-similarity-matrix)
- [dPLI Contrast Matrx](#dpli-contrast-matrix)
- [dPLI Fronto-Parietal Contrast Matrix](#dpli-fronto-parietal-contrast-matrix)
- [dPLI Dynamic Reconfiguration Index](#dpli-dynamic-reconfiguration-index)
  - [Attempt #1](#attempt-1)
  - [Attempt #2](#attempt-2)
  - [Attempt #3](#attempt-3)
  - [Attempt #4](#attempt-4)
  - [Attempt #5 (Current Version)] (#attempt-5)
- [dPLI-DRI Prediction of Recovery of Consciousness](#dpli-dri-prediction-of-recovery-of-consciousness)
- [Meeting 1 Notes](#meeting-1-notes)
- [Brain Product to EGI Mapping](#brain-product-to-egi-mapping)

## Code Structure
The codebase is structured in experiments where each one is directly tied to one of the issues on our task management system (here it is Github kanban functionality). The nomenclature you will find is `ex_XX` where XX means is a digit that maps to the issue number on this repository. If you see an experiment with a given number missing, it might be due by the fact that the given issue was not directly tied to code in the repository. For instance it could have been a documentation task or a reporting task which didn't require any sort of scripting.

## Participant Information
It is very difficult to know the exact state a participant is in. For this experiment we will be using the recovery outcomes instead of point-in-time label.
- The participant that recovered for sure are: **WSAS02,WSAS09,WSAS19 and WSAS20**
- The participant that didn't recover are: **WSAS05, WSAS11, WSAS12, WSAS13, WSAS18, WSAS22**
- The participant which we can't put a recovery outcome is: **WSAS10 and WSAS17**

## dPLI per Participant
This is the dPLI matrices that were generate using the code at `ex_10e_validate_dpli_matrices_with_bp.mat`. This particular script allows us to analyze the Brain Product headset as well as the Electrical Geodesic one. It make uses of a KNN-based algorithm to map the two electrodes position to have a similar nomenclature. This allows us to reorder easily the connectivity matrices in the `FTCPO` format (frontal, temporal, central, parietal and occipital). 

We have three states:
- baseline
- anesthesia
- recovery

The matrix are normalized within subject with mean() +- 3*std. This was done since normalizing the color map with the real min/max was giving mostly green matrices for baseline and recovery. 

**WSAS17 is currently excluded since it doesn't have a recovery.**

### WSAS02
![WSAS02 dpli at Alpha](./.figure/WSAS02_alpha_dpli.png)

### WSAS05
![WSAS05 dpli at Alpha](./.figure/WSAS05_alpha_dpli.png)

### WSAS09
![WSAS09 dpli at Alpha](./.figure/WSAS09_alpha_dpli.png)

### WSAS10
![WSAS10 dpli at Alpha](./.figure/WSAS10_alpha_dpli.png)

### WSAS11
![WSAS11 dpli at Alpha](./.figure/WSAS11_alpha_dpli.png)

### WSAS12
![WSAS12 dpli at Alpha](./.figure/WSAS12_alpha_dpli.png)

### WSAS13
![WSAS13 dpli at Alpha](./.figure/WSAS13_alpha_dpli.png)

### WSAS17
![WSAS17 dpli at Alpha](./.figure/WSAS17_alpha_dpli.png)

### WSAS18
![WSAS18 dpli at Alpha](./.figure/WSAS18_alpha_dpli.png)

### WSAS19
![WSAS19 dpli at Alpha](./.figure/WSAS19_alpha_dpli.png)

### WSAS20
![WSAS20 dpli at Alpha](./.figure/WSAS20_alpha_dpli.png)

### WSAS22
![WSAS22 dpli at Alpha](./.figure/WSAS22_alpha_dpli.png)

## dPLI Similarity Matrix
These matrices are used for the first, second and third attempt at making a dpli Dynamic Reconfiguration Index (dpli-dri). 

These result were generated with `ex_10e_validate_dpli_matrices_with_bp`

We have three similarity matrices we want to create: 
- baseline vs recovery
- baseline vs anesthesia 
- recovery vs anesthesia

The similarity matrix was calculated as follow: `sim_matrix = 1 - abs(matrix1 - matrix2)`.
If the matrix are highly similar channel-wise then they will have similar dPLI values and the max score of 1 will be achieved. If the matrix are highly dissimilar in the positive or negative direction we will get a number smaller than 1. At the extreme we have one channel a 1 in mat1 and a channel at 0 for mat2 which given 1 - 1 = 0.


### WSAS02
![WSAS02 dpli Similarity Matrix at Alpha](./.figure/WSAS02_alpha_sim_dpli.png)

### WSAS05
![WSAS05 dpli Similarity Matrix at Alpha](./.figure/WSAS05_alpha_sim_dpli.png)

### WSAS09
![WSAS09 dpli Similarity Matrix at Alpha](./.figure/WSAS09_alpha_sim_dpli.png)

### WSAS10
![WSAS10 dpli Similarity Matrix at Alpha](./.figure/WSAS10_alpha_sim_dpli.png)

### WSAS11
![WSAS11 dpli Similarity Matrix at Alpha](./.figure/WSAS11_alpha_sim_dpli.png)

### WSAS12
![WSAS12 dpli Similarity Matrix at Alpha](./.figure/WSAS12_alpha_sim_dpli.png)

### WSAS13
![WSAS13 dpli Similarity Matrix at Alpha](./.figure/WSAS13_alpha_sim_dpli.png)

### WSAS17
![WSAS17 dpli Similarity Matrix at Alpha](./.figure/WSAS17_alpha_sim_dpli.png)

### WSAS18
![WSAS18 dpli Similarity Matrix at Alpha](./.figure/WSAS18_alpha_sim_dpli.png)

### WSAS19
![WSAS19 dpli Similarity Matrix at Alpha](./.figure/WSAS19_alpha_sim_dpli.png)

### WSAS20
![WSAS20 dpli Similarity Matrix at Alpha](./.figure/WSAS20_alpha_sim_dpli.png)

### WSAS22
![WSAS22 dpli Similarity Matrix at Alpha](./.figure/WSAS22_alpha_sim_dpli.png)

## dPLI Contrast Matrix
These matrix are used for the fourth version of the dpli-dri in which we have an equivalent formula than before, but with a contrast instead of a similarity.

The contrast matrix is 1 - the similarity matrix. Which gives us:
`contrast_matrix = abs(matrix1 - matrix2)`.

We have everyone here except WSAS17.

### WSAS02
![WSAS02 dpli Contrast Matrix at Alpha](./.figure/WSAS02_alpha_contrast_dpli.png)

### WSAS05
![WSAS05 dpli Contrast Matrix at Alpha](./.figure/WSAS05_alpha_contrast_dpli.png)

### WSAS09
![WSAS09 dpli Contrast Matrix at Alpha](./.figure/WSAS09_alpha_contrast_dpli.png)

### WSAS10
![WSAS10 dpli Contrast Matrix at Alpha](./.figure/WSAS10_alpha_contrast_dpli.png)

### WSAS11
![WSAS11 dpli Contrast Matrix at Alpha](./.figure/WSAS11_alpha_contrast_dpli.png)

### WSAS12
![WSAS12 dpli Contrast Matrix at Alpha](./.figure/WSAS12_alpha_contrast_dpli.png)

### WSAS13
![WSAS13 dpli Contrast Matrix at Alpha](./.figure/WSAS13_alpha_contrast_dpli.png)

### WSAS17
![WSAS17 dpli Contrast Matrix at Alpha](./.figure/WSAS17_alpha_contrast_dpli.png)

### WSAS18
![WSAS18 dpli Contrast Matrix at Alpha](./.figure/WSAS18_alpha_contrast_dpli.png)

### WSAS19
![WSAS19 dpli Contrast Matrix at Alpha](./.figure/WSAS19_alpha_contrast_dpli.png)

### WSAS20
![WSAS20 dpli Contrast Matrix at Alpha](./.figure/WSAS20_alpha_contrast_dpli.png)

### WSAS22
![WSAS22 dpli Contrast Matrix at Alpha](./.figure/WSAS22_alpha_contrast_dpli.png)

## dPLI Fronto-Parietal Contrast Matrix
These matrix are used for the fifth version of the dpli-dri in which we have an equivalent formula than before, but with a contrast only calculated for the front-parietal regions.

We have everyone here except WSAS17.

### WSAS02
![WSAS02 FP dpli Contrast Matrix at Alpha](./.figure/WSAS02_alpha_contrast_fp_dpli.png)

### WSAS05
![WSAS05 FP dpli Contrast Matrix at Alpha](./.figure/WSAS05_alpha_contrast_fp_dpli.png)

### WSAS09
![WSAS09 FP dpli Contrast Matrix at Alpha](./.figure/WSAS09_alpha_contrast_fp_dpli.png)

### WSAS10
![WSAS10 FP dpli Contrast Matrix at Alpha](./.figure/WSAS10_alpha_contrast_fp_dpli.png)

### WSAS11
![WSAS11 FP dpli Contrast Matrix at Alpha](./.figure/WSAS11_alpha_contrast_fp_dpli.png)

### WSAS12
![WSAS12 FP dpli Contrast Matrix at Alpha](./.figure/WSAS12_alpha_contrast_fp_dpli.png)

### WSAS13
![WSAS13 FP dpli Contrast Matrix at Alpha](./.figure/WSAS13_alpha_contrast_fp_dpli.png)

### WSAS17
![WSAS17 FP dpli Contrast Matrix at Alpha](./.figure/WSAS17_alpha_contrast_fp_dpli.png)

### WSAS18
![WSAS18 FP dpli Contrast Matrix at Alpha](./.figure/WSAS18_alpha_contrast_fp_dpli.png)

### WSAS19
![WSAS19 FP dpli Contrast Matrix at Alpha](./.figure/WSAS19_alpha_contrast_fp_dpli.png)

### WSAS20
![WSAS20 FP dpli Contrast Matrix at Alpha](./.figure/WSAS20_alpha_contrast_fp_dpli.png)

### WSAS22
![WSAS22 FP dpli Contrast Matrix at Alpha](./.figure/WSAS22_alpha_contrast_fp_dpli.png)

## dPLI Dynamic Reconfiguration Index
Here is where I document all of our incremental attempt in making the dpli-dri.

### Attempt 1
This is the first attempt at building the dpli-dri index. Here what we did: We assume that Baseline vs Anesthesia (BvA) and Recovery vs Anesthesia (RvA) have the same weight, which might not be the case depending on the amount of time the recovery took. The more general form is then: `dri_dpli = sum(BvR) / (w1*(sum(BvA)) + w2*(sum(RvA))) where w1 and w2 = 1`. We might need to change these parameters depending on whatever prior we have.

The matlab code is the following:

```matlab
function [dpli_dri] = calculate_dpli_dri_1(bvr, bva, rva, w1, w2)
% CALCULATE DPLI DRI 1 is the first attempt at calculating the dpli-dri
% which uses division
%
% bvr: baseline vs recovery SIMILARITY matrix
% bva: baseline vs anesthesia SIMILARITY matrix
% rva: recovery vs anesthesia SIMILIARTY matrix
% w1: weight for the bva
% w2: weight for the rva

    dpli_dri = sum(bvr(:)) / (w1*(sum(bva(:))) + w2*(sum(rva(:))));
end
```

and the figure was generated by `ex_06_generate_first_draft_dpli_dri.m`

![dPLI-DRI attempt number 1](./.figure/dpli_dri_1.png)

### Attempt 2
For the second attempt we changed the formula to have the following: `dri_dpli = 2*sum(BvR) - (w1*(sum(BvA)) + w2*(sum(RvA)))`. 

```matlab
function [dpli_dri] = calculate_dpli_dri_2(bvr, bva, rva, w1, w2)
% CALCULATE DPLI DRI 2 is the second attempt at calculating the dpli-dri
% which uses substraction instead of the division
%
% bvr: baseline vs recovery SIMILARITY matrix
% bva: baseline vs anesthesia SIMILARITY matrix
% rva: recovery vs anesthesia SIMILIARTY matrix
% w1: weight for the bva
% w2: weight for the rva
    dpli_dri = 2*sum(bvr(:)) - (w1*(sum(bva(:))) + w2*(sum(rva(:))));
end
```

The weights we choose are 1.0 for both w1 and w2.
We normalize the resulting dpli dris by the number of connection within one of the similarity matrix.
```matlab
  % Calculate the dpli-dri with w1 and w2 = 1.0
  w1 = 1.0;
  w2 = 1.0;
  dpli_dris_2(p) = calculate_dpli_dri_2(baseline_vs_recovery, baseline_vs_anesthesia, recovery_vs_anesthesia, w1, w2);
  % normalize it so that headset with more channels aren't artificially
  % inflated
  dpli_dris_2(p) = dpli_dris_2(p)/length(baseline_vs_recovery(:));
```

The figure was generate with `ex_10d_generate_second_draft_dpli_dri_with_bp.m`

![dPLI-DRI attempt number 2](./.figure/dpli_dri_2.png)

### Attempt 3
In the third attempt we are modifying the similarity matrix to put more weight on the channels connexion that goes from phase leading to phase lagging.
Given two matrices `matrix1` and `matrix2` which are dPLI matrices at different states.

First we will shift the original matrix by 0.5 to check for phase switch.
```matlab
    shift_matrix1 = matrix1 - 0.5;
    shift_matrix2 = matrix2 - 0.5;
```

Then we check which element of the matrix is phase leading or lagging
```matlab 
    pos_matrix1 = shift_matrix1 > 0;
    pos_matrix2 = shift_matrix2 > 0;
```
We sum up both boolean matrices to be able to tell the difference between lead/lag switch.
```matlab
    sign_matrix = pos_matrix1 + pos_matrix2;
```
Finally we check the amount of crossing over in the shift matrices
```matlab
    amount_crossing_matrix = abs(shift_matrix1 - shift_matrix2);
``` 
This will allow us to create a cross matrix which will have a number for channel connection that crossed the 0.5 threshold and 0 for region which didn't cross.
```matlab   
   cross_matrix = amount_crossing_matrix.*(sign_matrix == 1);
```

We then use the tanh function to weight more heavily shift in phase lead/lag using the shift weight variable which tells how much the boost should be (in this case we set it to 2).
```matlab
    weight_matrix = shift_weight*tanh(cross_matrix) + 1;
```
The weight matrix is then use to calculate the difference matrix which will reduce the similarity if we have phase lead/lag crossing.
```matlab
    sim_matrix = 1 - (abs(matrix1 - matrix2).*weight_matrix);
```

These matrix can be generated with `ex_10f_generate_shift_weighted_similarity_matrices_with_bp.m`

### WSAS02
![WSAS02 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS02_alpha_sim_dpli_augmented.png)

### WSAS05
![WSAS05 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS05_alpha_sim_dpli_augmented.png)

### WSAS09
![WSAS09 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS09_alpha_sim_dpli_augmented.png)

### WSAS10
![WSAS10 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS10_alpha_sim_dpli_augmented.png)

### WSAS11
![WSAS11 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS11_alpha_sim_dpli_augmented.png)

### WSAS12
![WSAS12 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS12_alpha_sim_dpli_augmented.png)

### WSAS13
![WSAS13 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS13_alpha_sim_dpli_augmented.png)

### WSAS18
![WSAS18 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS18_alpha_sim_dpli_augmented.png)

### WSAS19
![WSAS19 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS19_alpha_sim_dpli_augmented.png)

### WSAS20
![WSAS20 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS20_alpha_sim_dpli_augmented.png)

### WSAS22
![WSAS22 dpli Weighted Similarity Matrix at Alpha](./.figure/WSAS22_alpha_sim_dpli_augmented.png)


For the dpli-dri we use the same definition as the attempt #2 and we generate the dpli-dri with `ex_10g_generate_third_draft_dpli_dri_with_bp.m`

![dPLI-DRI attempt number 3](./.figure/dpli_dri_3.png)

Which is similar to what we had before except with increased values everywhere. Also, the participant WSAS22 gained proportionally more dpli-dri. This participant had a different dpli similarity matrix than the other with high phase lead/lag shift only within the occipital region.

### Attempt 4

For the new version we want to rework the formula to instead use [contrast matrix](#dpli-contrast-matrix) and to remove the arbitrary 2 as a weight for bva:
`dpli_dri = w1*sum(BvA) + w2*sum(RvA) - w3*sum(BvR)`

We use the third version of the dpli_dri which looks like this:

```matlab
function [dpli_dri] = calculate_dpli_dri_3(bvr, bva, rva, w1, w2, w3)
% CALCULATE DPLI DRI 3 is the third version of the dpli-dri formula
%
% bvr: baseline vs recovery SIMILARITY matrix
% bva: baseline vs anesthesia SIMILARITY matrix
% rva: recovery vs anesthesia SIMILIARTY matrix
% w1: weight for the bva
% w2: weight for the rva
% w3: weight for the bvr

    dpli_dri = w1*sum(bva(:)) + w2*sum(rva(:)) - w3*sum(bvr(:));
end
```

**Here BvA, RvA and BvR are contrast matrix and not similarity matrices**.

We also use w1,w2,w3 = 1.0 currently and we normalize the dpli-dri by the number of connexion in a contrast matrix:

```matlab
% Calculate the dpli-dri with w1, w2 and w3
dpli_dris_3(p) = calculate_dpli_dri_3(baseline_vs_recovery, baseline_vs_anesthesia, recovery_vs_anesthesia, w1, w2, w3);
% normalize it so that headset with more channels aren't artificially
% inflated
dpli_dris_3(p) = dpli_dris_3(p)/length(baseline_vs_recovery(:));
```
The figure of dpli-dri was generated using `ex_12b_generate_fourth_draft_dpli_dri.m`

![dPLI-DRI attempt number 4](./.figure/dpli_dri_4.png)
### Attempt 5
**This is the latest version**
This version of the dpli-dri is almost identical than attempt 4 except that we filter the regions to only keep the fronto-parietal connections. 

The figure of dpli-dri was generated using
`ex_17b_generate_fifth_draft_dpli_dri.m`

![dPLI-DRI attempt number 5](./.figure/dpli_dri_5.png)

## dPLI-DRI Prediction of Recovery of Consciousness
With attempt `#4` we have an index that illustrate that there is something there in terms of prediction of RoC. However, it is not fullfilling the 'prediction' part of our narrative. We need to use either statistical analysis of significance or machine learning to build a predictive model.

My (Yacine Mahdid) exchange with my collegue:
```
@sbmoraes and @cduclos could you remind me of the big picture for the dpli-dri analysis. What are we trying to say with that index?

cduclos  8:17 PM
We are trying a capture, with a single index, how much the brain network re-organizes under anesthesia. Our aim is to show that this reorganization can reliably predict potential for consciousness (i.e. eventual recovery of consciousness) in unresponsive patients.

8:19
Our other argument is that baseline connectivity/network hubs alone aren’t sufficient to predict recovery, and that the adaptive reconfiguration under anesthesia is what is most predictive of potential for recovery.
```

So the objectives of this index of consciousness is two-fold:
- Aim 1: show that reorganization under anesthesia can reliably predict RoC in WSASXX patient.
- Aim 2: show that baseline connectivity alone is performing worse in predicting RoC in WSASXX patient than reorganization.

If we want to attain aim 1 or 2 we will need more than the number of timepoints we currently have (only `10` points). A solution for this problem is to make a classifier of the binary recovery outcome based on all of the windows of data we currently have and make it interpretable. 

I propose that we go with the following plan:
- Calculate dPLI on 10second windows for each state (~30 windows)
- Generate a dataset where we take all the permutation of the three state windows to generate BvA, RvA and BvR.
- Store in a dataframe sum(BvA), sum(RvA) and sum(BvR). This will generate a 270 000 data points * 3 feature data set.
- Train a logistic regression or a decision tree (interpretable models) on the dataset using a Leave-One-Subject-Out (LOSO) cross validation. This will allow us to quantify the predictive power of our index.
- Train the best model on the full dataset and look at the resulting weights to define our dpli-dri index (it will be a linear combination of sum(BvA) sum(RvA) and sum(BvR).

We are making the assumption that by using the full sum of the contrast matrix we will have separable state, but we can see that by eye that it is the case for the average so I am pretty confident we can get a robust classifier.

**This is put on hold**

## Meeting 1 Notes
Two features seems to be important, hub location and dPLI. However, hub location as it currently stands is very experimental and has conceptual problems. The dPLI feature is stable however.
For the dPLI we want to do similarity/difference matrix
- Baseline vs Recovery similarity matrix
- Baseline vs Anesthesia difference matrix
- Recovery vs Anesthesia difference matrix

These difference matrix will tell us if our intuition is correct and will help out in developing a metric. One thing to keep in mind is that for the visual we should be using the full matrix, however half of the matrix is fully redundant. **Keeping only the top or the bottom triangle will help reduce the dimensionality**.

There was something about cosine similarity of alpha hubs and something about k-mean clustering with 2 clusters and training a classifier on these clusters.

**Should really take more notes or record such meeting since we lost a lot of information**

## Brain Product to EGI Mapping
One of our participant `WSAS02` was recorded with the brain product headset which has 66 electrodes. All of our other participant were recorded with the high density EGI headset which has 129 electrodes. To be able to use this dataset along with the other we need to be able to find a mapping between the two.

This mapping was initially found by Danielle Nadin using the K-nearest-neighbour algorithm. Here are the findings.

# Maping
The KNN algorithm was run with K = 3, which gives us the three column we see in the table below. If we want a mapping based solely on the euclidean distance we can use `egi_nearest_1`, however some channels have the same labels in the two headset but are not necessary the nearest to one another. The column egi_location is the mapping where when the same label isn't the nearest it was picked anyway. 

The mapping file `bp_to_egi_mapping.csv` can be found [in the .doc folder](https://github.com/BIAPT/awareness-perturbation-complexity-index/tree/master/.doc/wsas02_information) along with the helper script that generated it. 

| bp_location | egi_location | egi_nearest_1 | egi_nearest_2 | egi_nearest_3 |
|-------------|--------------|---------------|---------------|---------------|
| Fp1         | Fp1          | **Fp1**       | E25           | E21           |
| Fp2         | Fp2          | **Fp2**       | E8            | E14           |
| F7          | F7           | **F7**        | E32           | E26           |
| F3          | F3           | **F3**        | E27           | E28           |
| Fz          | Fz           | E5            | E12           | **Fz**        |
| F4          | F4           | **F4**        | E123          | E117          |
| F8          | F8           | **F8**        | E1            | E2            |
| FC5         | E34          | **E34**       | E40           | E35           |
| FC1         | E13          | **E13**       | E29           | E20           |
| FC2         | E112         | **E112**      | E111          | E118          |
| FC6         | E116         | **E116**      | E109          | E110          |
| T7          | T7           | E39           | **T7**        | E40           |
| C3          | C3           | **C3**        | E41           | E35           |
| Cz          | Cz           | **Cz**        | E7            | E106          |
| C4          | C4           | **C4**        | E103          | E110          |
| T8          | T8           | E115          | **T8**        | E109          |
| TP9         | E56          | **E56**       | LM            | E63           |
| CP5         | E46          | **E46**       | E47           | E51           |
| CP1         | E53          | **E53**       | E54           | E37           |
| CP2         | E86          | **E86**       | E79           | E87           |
| CP6         | E102         | **E102**      | E98           | E97           |
| TP10        | E107         | **E107**      | RM            | E99           |
| P7          | P7           | E50           | **P7**        | LM            |
| P3          | E59          | **E59**       | E60           | P3            |
| Pz          | Pz           | **Pz**        | E72           | E77           |
| P4          | E91          | **E91**       | E85           | P4            |
| P8          | P8           | E101          | **P8**        | RM            |
| PO9         | E68          | **E68**       | E64           | E69           |
| O1          | O1           | **O1**        | E65           | E69           |
| Oz          | Oz           | **Oz**        | E82           | E74           |
| O2          | O2           | **O2**        | E90           | E89           |
| PO10        | E94          | **E94**       | E95           | E89           |
| AF7         | E26          | **E26**       | E25           | E32           |
| AF3         | E23          | **E23**       | Fp1           | E18           |
| AF4         | E3           | **E3**        | Fp2           | E10           |
| AF8         | E2           | **E2**        | E8            | E1            |
| F5          | E27          | **E27**       | E26           | F7            |
| F1          | E19          | **E19**       | E20           | E12           |
| F2          | E4           | **E4**        | E118          | E5            |
| F6          | E123         | **E123**      | E2            | F8            |
| FT9         | E43          | **E43**       | E44           | E38           |
| FT7         | E39          | **E39**       | F7            | E38           |
| FC3         | E28          | **E28**       | E29           | E35           |
| FC4         | E117         | **E117**      | E111          | E110          |
| FT8         | E115         | **E115**      | F8            | E121          |
| FT10        | E120         | **E120**      | E114          | E121          |
| C5          | E40          | **E40**       | E41           | E46           |
| C1          | E30          | **E30**       | E37           | E31           |
| C2          | E105         | **E105**      | E87           | E80           |
| C6          | E109         | **E109**      | E103          | E102          |
| TP7         | E50          | T7            | **E50**       | LM            |
| CP3         | E42          | **E42**       | E47           | P3            |
| CPz         | E55          | **E55**       | E79           | E54           |
| CP4         | E93          | **E93**       | E98           | P4            |
| TP8         | E101         | T8            | **E101**      | RM            |
| P5          | E51          | **E51**       | P7            | E59           |
| P1          | E60          | **E60**       | E67           | E61           |
| P2          | E85          | **E85**       | E77           | E78           |
| P6          | E97          | **E97**       | P8            | E91           |
| PO7         | E65          | **E65**       | P7            | E64           |
| PO3         | E66          | **E66**       | O1            | E71           |
| POz         | E72          | E76           | E71           | **E72**       |
| PO4         | E84          | **E84**       | O2            | E76           |
| PO8         | E90          | **E90**       | P8            | E95           |
| Fpz         | E15          | **E15**       | NaN           | NaN           |

We cannot use however this mapping file as it stands for this current study because some recording don't have the same label nomenclature as the bp row. We need to dynamically find the best mapping in code. 
