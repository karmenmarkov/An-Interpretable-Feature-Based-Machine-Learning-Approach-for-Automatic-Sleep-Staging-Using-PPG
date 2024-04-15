function [cleaned_data, valid_epochs, removed_epochs] = removeEpochswRailing(data, detected_peaks, fs)

    % Remove epochs with problematic peak detection in PPG data.
    % This function identifies and removes epochs that exhibit 'railing', 
    % where peaks are too closely spaced to be physiologically plausible.
    %
    % Inputs:
    %   data - Matrix of PPG signal data, with each column representing an epoch.
    %   detected_peaks - Cell array with detected peaks for each epoch.
    %   fs - Sampling frequency of the PPG signal.
    %
    % Outputs:
    %   cleaned_data - Data matrix excluding epochs identified as problematic.
    %   valid_epochs - Logical array indicating valid epochs.
    %   removed_epochs - Array of indices corresponding to removed epochs due to railing.
    %
    % Example:
    %   [cleanedData, validEpochs, removedEpochs] = removeEpochswRailing(ppgData, detectedPeaks, 128);
    %
    % Notes:
    %   Epochs are considered problematic if they contain at least three peaks 
    %   less than 20 data points apart, indicating railing artifacts.
    %   This helps ensure the integrity of subsequent analysis by excluding 
    %   physiologically improbable data.


    % Initialize a logical vector to mark valid epochs
    num_epochs = size(data, 2);
    valid_epochs = true(1, num_epochs);
    removed_epochs = []; % Initialize an array to keep track of removed epochs
    
    % Iterate through each epoch to identify problematic ones based on detected peaks
    for epoch = 1:num_epochs
        % Retrieve detected peaks for the current epoch
        peaks = detected_peaks{epoch};
        
        % Check for closely spaced peaks: at least 3 peaks less than 20 data points apart
        problematic = false; % Initialize flag for problematic epoch
        for i = 1:length(peaks)-2
            if (peaks(i+2) - peaks(i)) < 20
                problematic = true;
                break; % No need to check further for this epoch
            end
        end

        if problematic
            valid_epochs(epoch) = false; % Mark epoch as problematic
            removed_epochs = [removed_epochs, epoch]; % Keep track of removed epoch
            fprintf('Removed epoch %d due to problematic peaks.\n', epoch);
        end

    end
    
    
    % Remove problematic epochs from data
    cleaned_data = data(:, valid_epochs);
end