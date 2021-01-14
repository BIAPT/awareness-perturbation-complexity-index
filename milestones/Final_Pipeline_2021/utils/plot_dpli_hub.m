function [] = plot_dpli_hub(baseline_f_dpli,anesthesia_f_dpli,recovery_f_dpli,baseline_norm_weights,anesthesia_norm_weights,recovery_norm_weights,common_location,participant,OUT_DIR)
    %% this function is to create and save the figure
    % with dPLI and HUBS for each particiant
    % the input are all dPLI and HUB values for the three conditions

    % plot the dPLI
    handle = figure;
    subplot(2,3,1);
    imagesc(baseline_f_dpli)
    colormap('jet');
    caxis([0.35,0.65])

    subplot(2,3,2);
    imagesc(anesthesia_f_dpli)
    colormap('jet');
    caxis([0.35,0.65])
    title(strcat(participant,'  dPLI'))

    subplot(2,3,3);
    imagesc(recovery_f_dpli)
    colormap('jet');
    caxis([0.35,0.65])
    colorbar

    % plot the HUB
    subplot(2,3,4);
    topoplot(baseline_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'off');
    caxis([0,2])

    subplot(2,3,5);
    topoplot(anesthesia_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'off');
    caxis([0,2])
    title(strcat(participant,'  HUB'))

    subplot(2,3,6);
    topoplot(recovery_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'off');
    caxis([0,2])
    colorbar

    x0=10;
    y0=10;
    width=1200;
    height=600;
    set(gcf,'position',[x0,y0,width,height])

    % Save it to disk
    filename = strcat(OUT_DIR,'\',participant,'_','summary.png');
    saveas(handle,filename);
    close all; 

end
