function [] = plot_dpli_hub_two(baseline_f_dpli,anesthesia_f_dpli,baseline_norm_weights,anesthesia_norm_weights,common_location,participant,OUT_DIR)
    %% this function is to create and save the figure
    % with dPLI and HUBS for each particiant
    % the input are all dPLI and HUB values for the three conditions

    % plot the dPLI
    handle = figure('visible','off');
    subplot(2,3,1);
    imagesc(baseline_f_dpli)
    set(gca,'FontSize',20)
    colormap('jet');
    caxis([0.4,0.6])

    subplot(2,3,2);
    imagesc(anesthesia_f_dpli)
    set(gca,'FontSize',20)
    colormap('jet');
    caxis([0.4,0.6])
    title(strcat(participant,'  dPLI'))

    % plot the HUB
    subplot(2,3,4);
    topoplot(baseline_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'on');
    caxis([0,2])

    subplot(2,3,5);
    topoplot(anesthesia_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'on');
    caxis([0,2])
    set(gca,'FontSize',20)
    title(strcat(participant,'  HUB'))

    x0=10;
    y0=10;
    width=1200;
    height=600;
    set(gcf,'position',[x0,y0,width,height])

    % Save it to disk
    filename = strcat(OUT_DIR,'/',participant,'_','summary.png');
    saveas(handle,filename);
    close all; 

end
