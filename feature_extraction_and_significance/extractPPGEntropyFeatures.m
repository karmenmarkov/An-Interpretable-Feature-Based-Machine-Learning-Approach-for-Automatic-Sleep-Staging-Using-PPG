function featuresTable = extractPPGEntropyFeatures(data, fs)
    % Extracts entropy-based features from photoplethysmogram (PPG) data for each epoch to analyze the complexity and regularity of the PPG signal. Entropy measures are used to quantify the unpredictability and the dynamic changes in the signal that might be indicative of physiological states or conditions.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   The first row is assumed to contain labels and is excluded from calculations.
    %   fs - The sampling rate of the PPG signal.
    %
    % Outputs:
    %   featuresTable - Table containing the calculated features for each epoch
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

    % Initialize parallel pool if not already started
    if isempty(gcp('nocreate'))
        parpool; % Automatically chooses the default cluster profile
    end

    % Assuming the first row is labels and the rest is data
    [num_samples, num_epochs] = size(data);

    featureNames = {'PPG_ApEn', 'PPG_SampEn', 'PPG_FuzzyEn', 'PPG_PerEn', 'PPG_En1st', 'PPG_En2nd', 'PPG_En1st_2nd'};
    features_all_epochs = zeros(num_epochs, length(featureNames)); % Preallocate for speed
    
    m = 2;  % Embedding dimension
    r_factor = 0.15; % Tolerance factor relative to the standard deviation

    % Loop through each epoch to calculate entropies
    parfor epoch = 1:num_epochs
        epochData = data(2:end, epoch); % Exclude labels row
        sd = std(epochData); % Standard deviation of the epoch
        r = r_factor * sd; % Tolerance

        % Approximate Entropy
        PPG_ApEn = approximateEntropy(epochData, 'Dimension', m,'Radius', r);
        
        % Sample Entropy
        PPG_SampEn= SampleEn(epochData, m, r, 'chebychev');
        
        % Fuzzy Entropy
        PPG_FuzzEn= FuzzyEn(epochData, m, r);
        
        % Permutation Entropy
        PPG_PerEn= PerEn(epochData, m, 1);
        
        % First and Second-order differences and their entropies
        D1 = diff(epochData, 1); % First-order difference
        D2 = diff(D1, 1); % Second-order difference
        PPG_En1st = PerEn(D1, m, 1);
        PPG_En2nd = PerEn(D2, m, 1);
        PPG_En1st_2nd = PPG_En1st / PPG_En2nd;
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPG_ApEn, PPG_SampEn, PPG_FuzzEn, PPG_PerEn, PPG_En1st, PPG_En2nd, PPG_En1st_2nd];
    end
    
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
