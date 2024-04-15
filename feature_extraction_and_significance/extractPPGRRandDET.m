function featuresTable = extractPPGRRandDET(data, fs)
    % Extract recurrence rate (RR) and determinism (DET) from PPG data for each epoch
    % to analyze the dynamics and predictability within the physiological signals.
    % Recurrence rate quantifies the number of times a state recurs, whereas determinism
    % assesses the predictability of future states based on their recurrence.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   fs - The sampling rate of the PPG signal.
    %
    % Outputs:
    %   featuresTable - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %  calculateRRandDet - for computing the recurrence metrics, which internally 
    % uses norm calculations for recurrence plots and a custom DET 
    % calculation method for evaluating the predictability of the signal.

    % Assuming the first row is labels and the rest is data
    %labels = data(1, :); % If labels are not needed inside this function, you can comment this line
    data = data(2:end, :); % Exclude labels row for feature extraction
    [num_samples, num_epochs] = size(data);
    
    % Define the names of the features to be calculated
    featureNames = {'PPG_RR', 'PPG_DET'};
    features_all_epochs = zeros(num_epochs, length(featureNames)); % Preallocate for speed
    l_min = 2;    % Minimum length of diagonal lines considered for DET calculation
  

    % Initialize the parallel pool if it's not already started for parallel computation
    if isempty(gcp('nocreate')) % Check if a parallel pool exists
        parpool; % Start a parallel pool if it doesn't exist
    end
    
    % Parallel processing for each epoch to calculate RR and DET
    parfor epoch = 1:num_epochs
        epochData = data(:, epoch); % Data for the current epoch
    
        % Calculate RR and DET
        epsilon = 0.1 * std(epochData); % Threshold for recurrence based on the data's standard deviation
        [RP, PPG_RR, PPG_DET] = calculateRRandDet(epochData, epsilon, l_min); % Calculate RR and DET
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPG_RR, PPG_DET];
    end
    
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
