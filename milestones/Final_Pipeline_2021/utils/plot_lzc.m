function [] = plot_lzc(lz_matrix_base, lz_matrix_anes, lz_matrix_reco, lz_base, lz_anes, lz_reco, participant,OUT_DIR)
    %% this function is to create and save the figure
    % with dPLI and HUBS for each particiant
    % the input are all dPLI and HUB values for the three conditions

    % plot the LZC
    handle = figure;
    set(gcf, 'Position',  [100, 100, 1500, 500])
    subplot(1,4,1);
    imagesc(lz_matrix_base)
    colormap('jet');
    caxis([0,3])

    subplot(1,4,2);
    imagesc(lz_matrix_anes)
    colormap('jet');
    caxis([0,3])
    title(strcat(participant,'  Lempel-ziv-complexity'))

    subplot(1,4,3);
    imagesc(lz_matrix_reco)
    colormap('jet');
    caxis([0,3])
    colorbar

    % plot the HUB
    subplot(1,4,4);
    
    cond = repelem([{'Baseline'}, {'Anesthesia'}, {'Recovery'}], ...
        [size(lz_base,2) size(lz_anes,2) size(lz_reco,2)]);
    pos = repelem([1, 2, 3], ...
        [size(lz_base,2) size(lz_anes,2) size(lz_reco,2)]);
    toplot = reshape([lz_base,lz_anes,lz_reco],[],1);
    cond = reshape(categorical(cond),[],1);
    boxplot(toplot,cond, 'positions', pos);
        
    % Save it to disk
    filename = strcat(OUT_DIR,'\',participant,'_','LZC_summary.png');
    saveas(handle,filename);
    close all; 

end
