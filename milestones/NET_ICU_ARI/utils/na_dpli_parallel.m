function [result] = na_dpli_parallel(recording, frequency_band, window_size, step_size, number_surrogate, p_value)
    %NA_dPLI NeuroAlgo implementation of dpli that works with Recording
    
    %only change made to this code is calling dpli_corrected instead of dPLI in line 33
    
    %% Getting the Configuration
    configuration = get_configuration();
    
    %% Setting the Result
    result = Result('dpli', recording);
    % Saving the parameters used
    result.parameters.frequency_band = frequency_band;
    result.parameters.window_size = window_size;
    result.parameters.step_size = step_size;
    result.parameters.number_surrogate = number_surrogate;
    result.parameters.p_value = p_value;
    

    %% Filtering the data
    print_message(strcat("Filtering Data from ",string(frequency_band(1)), "Hz to ", string(frequency_band(2)), "Hz."),configuration.is_verbose);
    recording = recording.filter_data(recording.data, frequency_band);
    
    %% Slice the recording into windows
    %create windows with filtered data 
    sampling_rate = recording.sampling_rate;
    windowed_data = create_sliding_window(recording.filt_data, window_size, step_size, sampling_rate);
    number_window = size(windowed_data,1);
    %% Calculation on the windowed segments
    dpli_tofill = zeros(number_window, recording.number_channels, recording.number_channels);
    
    parfor win_i = 1:number_window
        disp(strcat("dpli at window: ",string(win_i)," of ", string(number_window)));         % Calculate the dpli 
        segment_data = squeeze(windowed_data(win_i,:,:));
        dpli_tofill(win_i,:,:) = dpli_corrected(segment_data, number_surrogate, p_value);
    end
       
    result.data.dpli = dpli_tofill;
    %% Average wPLI
    result.data.avg_dpli = squeeze(mean(result.data.dpli,1));
    
    %% Region specific wPLI
    % TODO: This part is super ugly need to
    % if we don't have channels location we get out
    if(isempty(recording.channels_location))
        return;
    end
    
    % General Mask for the filtering (pre-computed)
    is_left = [recording.channels_location.is_left];
    is_right = [recording.channels_location.is_right];
    is_midline = [recording.channels_location.is_midline];
    is_lateral = [recording.channels_location.is_lateral];
    is_anterior = [recording.channels_location.is_anterior];
    is_posterior = [recording.channels_location.is_posterior];
    
    % Specific Mask
    is_left_lateral = (is_left & is_lateral);
    is_left_lateral_anterior = (is_left_lateral & is_anterior);
    is_left_lateral_posterior = (is_left_lateral & is_posterior);
    
    is_left_midline = (is_left & is_midline);
    is_left_midline_anterior = (is_left_midline & is_anterior);
    is_left_midline_posterior = (is_left_midline & is_posterior);
    
    is_right_lateral = (is_right & is_lateral);
    is_right_lateral_anterior = (is_right_lateral & is_anterior);
    is_right_lateral_posterior = (is_right_lateral & is_posterior);
    
    is_right_midline = (is_right & is_midline);
    is_right_midline_anterior = (is_right_midline & is_anterior);
    is_right_midline_posterior = (is_right_midline & is_posterior);
    
    

    % Calculating wpli for each region
    
    result.data.left_dpli = result.data.dpli(:,logical(is_left),logical(is_left));
    result.data.right_dpli = result.data.dpli(:,logical(is_right),logical(is_right));
    
    result.data.left_lateral_dpli = result.data.dpli(:, is_left_lateral, is_left_lateral);
    result.data.left_lateral_anterior_dpli = result.data.dpli(:, is_left_lateral_anterior, is_left_lateral_anterior);
    result.data.left_lateral_posterior_dpli = result.data.dpli(:, is_left_lateral_posterior, is_left_lateral_posterior);    
    
    result.data.left_midline_dpli = result.data.dpli(:, is_left_midline, is_left_midline);
    result.data.left_midline_anterior_dpli = result.data.dpli(:, is_left_midline_anterior, is_left_midline_anterior);
    result.data.left_midline_posterior_dpli = result.data.dpli(:, is_left_midline_posterior, is_left_midline_posterior); 
    
    result.data.right_lateral_dpli = result.data.dpli(:, is_right_lateral, is_right_lateral);
    result.data.right_lateral_anterior_dpli = result.data.dpli(:, is_right_lateral_anterior, is_right_lateral_anterior);
    result.data.right_lateral_posterior_dpli = result.data.dpli(:, is_right_lateral_posterior, is_right_lateral_posterior);
    
    result.data.right_midline_dpli = result.data.dpli(:, is_right_midline, is_right_midline);
    result.data.right_midline_anterior_dpli = result.data.dpli(:, is_right_midline_anterior, is_right_midline_anterior);
    result.data.right_midline_posterior_dpli = result.data.dpli(:, is_right_midline_posterior, is_right_midline_posterior);    
    
    % Calculating average over time (Nvertices x Nvertices)
    
    result.data.avg_left_dpli = squeeze(mean(result.data.left_dpli,1));
    result.data.avg_right_dpli = squeeze(mean(result.data.right_dpli,1));
    
    % Calculating average per region for each window
    
    result.data.avg_left_lateral_dpli = average_connectivity(result.data.left_lateral_dpli);
    result.data.avg_left_lateral_anterior_dpli = average_connectivity(result.data.left_lateral_anterior_dpli);
    result.data.avg_left_lateral_posterior_dpli = average_connectivity(result.data.left_lateral_posterior_dpli);
    
    
    result.data.avg_left_midline_dpli = average_connectivity(result.data.left_midline_dpli);
    result.data.avg_left_midline_anterior_dpli = average_connectivity(result.data.left_midline_anterior_dpli);
    result.data.avg_left_midline_posterior_dpli = average_connectivity(result.data.left_midline_posterior_dpli);
    
    result.data.avg_right_lateral_dpli = average_connectivity(result.data.right_lateral_dpli);
    result.data.avg_right_lateral_anterior_dpli = average_connectivity(result.data.right_lateral_anterior_dpli);
    result.data.avg_right_lateral_posterior_dpli = average_connectivity(result.data.right_lateral_posterior_dpli);
    
    result.data.avg_right_midline_dpli = average_connectivity(result.data.right_midline_dpli);    
    result.data.avg_right_midline_anterior_dpli = average_connectivity(result.data.right_midline_anterior_dpli);    
    result.data.avg_right_midline_posterior_dpli = average_connectivity(result.data.right_midline_posterior_dpli);     
    
    % Calculating the ratio anterior / posterior for the four value
    result.data.avg_left_lateral_ratio = result.data.avg_left_lateral_anterior_dpli / result.data.avg_left_lateral_posterior_dpli;
    result.data.avg_left_midline_ratio = result.data.avg_left_midline_anterior_dpli / result.data.avg_left_midline_posterior_dpli;
    result.data.avg_right_lateral_ratio = result.data.avg_right_lateral_anterior_dpli / result.data.avg_right_lateral_posterior_dpli;
    result.data.avg_right_midline_ratio = result.data.avg_right_midline_anterior_dpli / result.data.avg_right_midline_posterior_dpli;
end