function featuresTable = extractAPGFeatures(data, a_peaks_epochs, b_peaks_epochs, e_peaks_epochs)
    % Extract APG features from the second derivative of the PPG signal, focusing on the relationships between the a, b, and e points.
    % Inputs:
    %   data - Matrix of PPG signal data, with each column representing an epoch (first row contains labels);
    %   a_peaks_epochs - Cell array containing detected a peaks for each epoch
    %   b_peaks_epochs - Cell array containing detected b peaks for each epoch
    %   e_peaks_epochs - Cell array containing detected e peaks for each epoch
    %   fs - Sampling rate of the PPG signal
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    % Dependencies:
    %   Peak Detection: The function requires the outputs from the `detectABEpeaks` function, which provides `a_peaks_epochs`, `b_peaks_epochs`, and `e_peaks_epochs`. This step is critical as it identifies the specific points in the PPG waveform needed for feature calculation.
    %   MATLAB's Signal Processing Toolbox**: Needed for functions like `diff`, which are used in calculating derivatives essential for determining the dynamics between the identified peaks.

    % Initialize an array to store all feature values for each epoch
    featuresAllEpochs = []; 

    % Determine the number of epochs
    numEpochs = size(data, 2); 

    % Loop through each epoch to calculate features
    for epoch = 1:numEpochs
        % Extract the PPG signal for the current epoch, excluding the label row
        ppgSignal = data(2:end, epoch);

        % Compute the first and second derivatives of the PPG signal
        diff1 = diff(ppgSignal);
        diff2 = diff(diff1);

        % Get peaks for the epoch from the cell arrays
        a_peaks = a_peaks_epochs{epoch};
        b_peaks = b_peaks_epochs{epoch};
        e_peaks = e_peaks_epochs{epoch};

        % Filter out NaN values to ensure arrays are of equal length
        validIndices = ~isnan(a_peaks) & ~isnan(b_peaks) & ~isnan(e_peaks);
        a_peaks_filtered = a_peaks(validIndices);
        b_peaks_filtered = b_peaks(validIndices);
        e_peaks_filtered = e_peaks(validIndices);

        % Calculate the features for the current epoch
        a_b_diff = diff2(a_peaks_filtered) + diff2(b_peaks_filtered);
        b_a_ratio = diff2(b_peaks_filtered) ./ diff2(a_peaks_filtered);
        e_a_ratio = diff2(e_peaks_filtered) ./ diff2(a_peaks_filtered);
        b_e_a_ratio = (diff2(b_peaks_filtered) - diff2(e_peaks_filtered)) ./ diff2(a_peaks_filtered);

        % Calculate the mean and standard deviation for the features
        a_b_mean = mean(a_b_diff);
        a_b_std = std(a_b_diff);
        b_a_ratio_mean = mean(b_a_ratio);
        b_a_ratio_std = std(b_a_ratio);
        e_a_ratio_mean = mean(e_a_ratio);
        e_a_ratio_std = std(e_a_ratio);
        b_e_a_ratio_mean = mean(b_e_a_ratio);
        b_e_a_ratio_std = std(b_e_a_ratio);

        % Collect features for the current epoch
        featureValuesEpoch = [a_b_mean, a_b_std, b_a_ratio_mean, b_a_ratio_std, e_a_ratio_mean, e_a_ratio_std, b_e_a_ratio_mean, b_e_a_ratio_std];

        % Append to the array of all feature values
        featuresAllEpochs = [featuresAllEpochs; featureValuesEpoch];
    end

    % Convert the array to a table with specified variable names
    featuresTable = array2table(featuresAllEpochs, 'VariableNames', {'a_b_mean', 'a_b_std', 'b_a_ratio_mean', 'b_a_ratio_std', 'e_a_ratio_mean', 'e_a_ratio_std', 'b_e_a_ratio_mean', 'b_e_a_ratio_std'});
end