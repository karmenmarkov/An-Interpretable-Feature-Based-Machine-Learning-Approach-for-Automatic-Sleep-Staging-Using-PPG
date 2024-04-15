function featuresTable = extractPPGLcHfdKfdFeatures(data, fs)
    % Extract Lyapunov exponent, Higuchi fractal dimension, and Katz fractal dimension from PPG data for each epoch. These features are used to analyze the complexity and chaotic nature of physiological signals.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   First row contains labels.
    %   fs - The sampling rate of the PPG signal.
    %
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %   lyapunovExponent - MATLAB function to calculate the Lyapunov exponent, indicating the rate of separation of infinitesimally close trajectories.
    %   Higuchi_FD - Custom function to compute the Higuchi fractal dimension.
    %   Katz_FD - Custom function to compute the Katz fractal dimension.
    %
    % References:
    %   Jesús Monge-Álvarez (2024). Higuchi and Katz fractal dimension measures
    %   (https://www.mathworks.com/matlabcentral/fileexchange/50290-higuchi-and-katz-fractal-dimension-measures),
    %   MATLAB Central File Exchange. Retrieved April 12, 2024.
    %   MATLAB's lyapunovExponent function from the Predictive Maintenance Toolbox for calculating the Lyapunov exponent.
    
    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPG_LC', 'PPG_HFD','PPG_KFD'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed

    % Enable parallel processing
    if isempty(gcp('nocreate')) % Check if a parallel pool exists
        parpool; % Start a parallel pool if it doesn't exist
    end
    
    parfor epoch = 1:numEpochs
        epochData = data(2:end, epoch); % Exclude label row

        % Feature Calculations

        % Lyapunov exponent of PPG signal
        PPG_LC = lyapunovExponent(epochData, fs);
    
        % Higuchi fractal dimension of PPG signal
        epoch_transposed = epochData.';
        PPG_HFD = Higuchi_FD(epoch_transposed, 100); 
    
        % Katz fractal dimension of PPG signal
        PPG_KFD = Katz_FD(epoch_transposed);

        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPG_LC, PPG_HFD, PPG_KFD];
    end
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
