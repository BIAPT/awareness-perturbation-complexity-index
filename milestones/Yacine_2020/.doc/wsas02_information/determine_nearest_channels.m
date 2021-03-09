%Danielle Nadin
%Version 1 - June 26, 2019
%--------------------------
%Find k-nearest neighbors of Brain Products electrodes amongst the set of EGI electrodes. 

%% Set k
k = 3;

%% Load data and transform froms struct to matrix
load EGI_positions
EGI_positions = [];
EGI_labels = [];

for i=1:size(temp,2)
    EGI_positions = [EGI_positions; temp(i).X temp(i).Y temp(i).Z];
    EGI_labels = char(EGI_labels,temp(i).labels);
end
EGI_labels(1,:)=[]; 

load BP_positions
BP_positions = [];
BP_labels = [];

%note: Brain Products coordinates are a scale of 10 higher than EGI
%coordinates (range from 1-100 vs. EGI which ranges from 1-10).
for i=1:size(temp,2)
    BP_positions = [BP_positions; temp(i).X/10 temp(i).Y/10 temp(i).Z/10];
    BP_labels = char(BP_labels,temp(i).labels);
end
BP_labels(1,:)=[];

%% Search for 3 nearest neighbors
[Idx,D] = knnsearch(EGI_positions,BP_positions,'K',k);

%% Print table of results
table(BP_labels,EGI_labels(Idx(:,1),:),EGI_labels(Idx(:,2),:),EGI_labels(Idx(:,3),:),...
    'VariableNames',{'Brain_Products','EGI_1st','EGI_2nd','EGI_3rd'})
 
%% Plot EGI electrode positions versus corresponding Brain Products electrodes
figure(1)
clf
scatter3(EGI_positions(:,1),EGI_positions(:,2),EGI_positions(:,3),'filled','MarkerFaceColor','b')
text(EGI_positions(:,1)+0.5,EGI_positions(:,2)+0.5,EGI_positions(:,3)+0.5,EGI_labels,'Color','b','FontSize',8)
hold on
scatter3(BP_positions(:,1),BP_positions(:,2),BP_positions(:,3),'filled','MarkerFaceColor','r')
text(BP_positions(:,1)-0.5,BP_positions(:,2)-0.5,BP_positions(:,3)-0.5,BP_labels,'Color','r','FontSize',8)
hold off
legend('EGI','Brain Products')