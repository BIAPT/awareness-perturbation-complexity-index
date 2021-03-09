# Adaptive Reconfiguration Index_2021
Development of an index for assessing the level of consciousness of healthy and disorder of consciousness individuals. This pipeline was used for submission in 2021. 

Step 1 and 2 are performed in MATLAB. Step 3 is runs in a python notebook  

## Steps :

##### step1

- navigate to `step1_connectivity/calculate_connectivity.m`  specify the location of your data and the saving directory and participant IDS. 
- calculate the functional connectivity by running `calculate_connectivity.m` 
- this will save you .mat files of functional connectivity (dPLI: directed Phase Lag Index and wPLI: weighted Phase Lag Index) for the Baseline, Anesthesia and Recovery condition

##### step2: 

- navigate to the `step2_ARI/ARI_Analysis.m` adapt your input and output path as well as participant information

- running the script will generate one image per participant , such as the one below: 

- ![WSAS19_summary](C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\reduced_wd_best_hemisphere\WSAS19_summary.png)

- It will also save `ARI.txt` which contains the ARI (dPLI-R and Hub-R) for all participants as well as a graphic representation of recovered and non-recovered patients ARI:   

  (red: recovered, blue: non-recovered)

- ![DPLI_DRI](C:\Users\User\Documents\GitHub\ARI\milestones\Final_Pipeline_2021\results\reduced_wd_best_hemisphere\DPLI_DRI.png)

  ##### step3: (Python notebook)

- navigate to `step3_clustering/K-Means_dPLI_Hub.ipynb`  specify the location of the previous output ARI.txt  

- Running the notebook and performs the k-means clustering and outputs the overall separability

- If the data is separable with an accuracy over chance, you can perform `K-Means_ARI_LOSO.ipynb` . This step performs Leave one subject out cross validation on the chosen dataset. 



