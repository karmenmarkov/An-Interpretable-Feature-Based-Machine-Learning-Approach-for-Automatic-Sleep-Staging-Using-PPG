function featuresTable = extractPPIEntropyFeatures(data, detected_peaks, fs)
    % Extracts entropy-based features from Peak-to-Peak Intervals (PPI) of PPG signals for each epoch. 
    % This function computes various entropy measures including Approximate Entropy, Sample Entropy, 
    % Fuzzy Entropy, and Permutation Entropy, which provide insights into the complexity and regularity 
    % of the PPI signal.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an
    %   epoch.The first row contains labels.
    %   detected_peaks - A cell array where each cell contains the indices of detected S_peaks for each epoch.
    %   fs - The sampling rate of the PPG signal.
    %
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %   Requires custom functions `SampleEn`, `PerEn`, and `FuzzyEn` for entropy calculations.
    %   MATLAB's `approximateEntropy` from the Predictive Maintenance Toolbox.
    %
    % References:
    %   - Víctor Martínez-Cagigal (2018). Sample Entropy. Mathworks. https://ch.mathworks.com/matlabcentral/fileexchange/69381-sample-entropy
    %   - Gaoxiang Ouyang (2024). Permutation entropy (https://www.mathworks.com/matlabcentral/fileexchange/37289-permutation-entropy), MATLAB Central File Exchange.
    %   - Golnaz Baghdadi (2024). func_FE_FuzzEn (https://www.mathworks.com/matlabcentral/fileexchange/98064-func_fe_fuzzen), MATLAB Central File Exchange.
    %
    % The function calculates entropy measures using predefined parameter values for embedding dimension and tolerance.
    %

    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction
    
    numEpochs = size(data, 2);  % Number of epochs
    
    featureNames = {'PPI_ApEn', 'PPI_SampEn', 'PPI_FuzzyEn', 'PPI_PerEn', 'PPI_En1st', 'PPI_En2nd', 'PPI_En1st_2nd'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
        
    m = 2;  % Embedding dimension
    r_factor = 0.15; % Tolerance factor relative to the standard deviation
    
    for epoch = 1:numEpochs
        epochData = data(1:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
    
        % Extract PPI intervals for the current epoch
        PPI = diff(S_peaks) / fs * 1000; % Convert to milliseconds
    
        sd = std(PPI); % Standard deviation of the epoch
        r = r_factor * sd; % Tolerance
        
        % Approximate Entropy
        PPI_ApEn = approximateEntropy(PPI, 'Dimension', m,'Radius', r);
            
        % Sample Entropy
        PPI_SampEn= SampleEn(PPI, m, r, 'chebychev');
            
        % Fuzzy Entropy
        PPI_FuzzEn= FuzzyEn(PPI, m, r);
            
        % Permutation Entropy
        PPI_PerEn= PerEn(PPI, m, 1);
            
        % First and Second-order differences and their entropies
        D1 = diff(PPI, 1); % First-order difference
        D2 = diff(D1, 1); % Second-order difference
        PPI_En1st = PerEn(D1, m, 1);
        PPI_En2nd = PerEn(D2, m, 1);
        PPI_En1st_2nd = PPI_En1st / PPI_En2nd;
        
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPI_ApEn, PPI_SampEn, PPI_FuzzEn, PPI_PerEn, PPI_En1st, PPI_En2nd, PPI_En1st_2nd];
    end

    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end