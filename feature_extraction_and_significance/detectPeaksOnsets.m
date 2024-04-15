function [detected_peaks, detected_onsets, clean_data, valid_epochs_index] = detectPeaksOnsets(data, fs)
    % Detect Speaks and Opoints
    % Inputs:
    %   data - Matrix of PPG signal data, with each column representing an epoch (first row contains labels)
    %   fs - Sampling rate of the PPG signal
    % Outputs:
    %   detected_peaks - Cell array containing detected peaks for each epoch
    %   detected_onsets - Cell array containing detected onsets for each epoch
    %   clean_data - Filtered data matrix including only epochs where peaks and onsets were successfully detected
    %   valid_epochs_index - Indices of epochs that were successfully processed
    % Dependency:
    %   Requires the PPG_Beats toolbox (https://ppg-beats.readthedocs.io/en/latest/).
    % Example:
    %   [peaks, onsets, cleanData, validIdx] = detectPeaksOnsets(ppgData, 128);
    % Note:
    %   This function uses the MSPTD algorithm for beat detection, which is robust to typical PPG noise.
    % Reference: 
    % Charlton PH et al., Detecting beats in the photoplethysmogram: benchmarking open-source algorithms, Physiological Measurement, 2022.
    
    % Add path to toolbox
    addpath('/Users/kmarkov/Documents/Matlab_codes/ppg-beats-main/source');
   
    % Determine the number of epochs (columns) in the data
    num_epochs = size(data, 2);

    % Initialize cell arrays to store detected peaks and onsets for each
    % epoch, and valid epochs (epochs where peaks and onsets were detected)
    temp_detected_peaks = cell(1, num_epochs);
    temp_detected_onsets = cell(1, num_epochs);
    valid_epochs_index = [];
    

    % Iterate through each epoch to detect peaks and onsets
    for epoch = 1:num_epochs

        % Extract the PPG signal for the current epoch, excluding the label in the first row
        S.v = data(2:end, epoch); % Exclude labels row
        S.fs = fs; % Set the sampling frequency
        
        % Specify the beat detection algorithm to use
        beat_detector = 'MSPTD';
        
        % Try-catch block to catch any errors during peak detection
        try
            [peaks, onsets, ~] = detect_ppg_beats(S, beat_detector); % Detect peaks and onsets using the specified beat detector
            if isempty(peaks) || isempty(onsets)
                % Handle the case where peaks or onsets are empty
                % For example, by storing NaN or continuing to the next iteration
                disp(['No peaks or onsets detected for epoch ', num2str(epoch)]);
                continue; % Skip the rest of the processing for this epoch
            end
            temp_detected_peaks{epoch} = peaks;
            temp_detected_onsets{epoch} = onsets;
            valid_epochs_index = [valid_epochs_index, epoch]; % Keep track of valid epoch indices
        catch ME
            disp(['Error detecting peaks/onsets for epoch ', num2str(epoch), ': ', ME.message]);
        end
    end
    % Filter the data to include only valid epochs
    clean_data = data(:, valid_epochs_index);

    % Filter detected peaks and onsets based on valid epochs
    detected_peaks = temp_detected_peaks(valid_epochs_index);
    detected_onsets = temp_detected_onsets(valid_epochs_index);
end
