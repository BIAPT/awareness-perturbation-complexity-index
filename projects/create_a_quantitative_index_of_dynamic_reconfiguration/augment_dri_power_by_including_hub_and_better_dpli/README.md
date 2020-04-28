# Report for Augment DRI Power by Including Hub and Better dPLI
This is the report for the milestone `Augment DRI Power by Including Hub and Better dPLI`. You will find figures, results and general explanation on the codebase ( all the figures are in the hidden folder `.figure`).

**Goal**: Build upon the rough dpli contrast index that we created in the [Create Rough dPLI Contrast Index](../create_rough_dpli_contrast_indexes/README.md) milestone. What we came up with was that the attempt 4 and 5 in that milestone were promising. The next steps were to add wpli based hub location and to try a last way of weighting the attempt 5 in order to have a FP metric that is weighting more the channels that flip from phase lead to phase lag (or vice versa).

## Table of Content
- [dPLI Dynamic Reconfiguration Index](#dpli-dynamic-reconfiguration-index)
  - [Attempt #6](#attempt-6)

## dPLI Dynamic Reconfiguration Index
The current version of the dpli-dri make use of contrast matrices and filters out all the region except the fronto-parietal ones. What we currently get in terms of dpli-dri for each of the participant is this:
