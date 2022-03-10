function [] = plot_dpli_hub_NET_ICU(sedon1_f_dpli,sedoff_f_dpli, sedon2_f_dpli, sedon1_norm_weights,sedoff_norm_weights,sedon2_norm_weights,common_location,participant,OUT_DIR)
    %% this function is to create and save the figure
    % with dPLI and HUBS for each particiant
    % the input are all dPLI and HUB values for the three conditions

    % plot the dPLI
    handle = figure('visible','off');
    subplot(2,3,1);
    imagesc(sedon1_f_dpli)
    set(gca,'FontSize',20)
    colormap('jet');
    caxis([0.4,0.6])

    subplot(2,3,2);
    imagesc(sedoff_f_dpli)
    set(gca,'FontSize',20)
    colormap('jet');
    caxis([0.4,0.6])
    title(strcat(participant,'  dPLI'))

    subplot(2,3,3);
    imagesc(sedon2_f_dpli)
    set(gca,'FontSize',20)
    colormap('jet');
    caxis([0.4,0.6])
    colorbar

    % plot the HUB
    subplot(2,3,4);
    topoplot(sedon1_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'on');
    caxis([0,2])

    subplot(2,3,5);
    topoplot(sedoff_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'on');
    caxis([0,2])
    title(strcat(participant,'  HUB'))

    subplot(2,3,6);
    topoplot(sedon2_norm_weights,common_location,'maplimits','absmax', 'electrodes', 'on');
    caxis([0,2])
    set(gca,'FontSize',20)
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
