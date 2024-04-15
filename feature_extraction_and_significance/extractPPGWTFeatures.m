function featuresTable = extractPPGWTF(data, fs)

    % Extracts wavelet transform features from PPG data using a symlet wavelet. This function performs a 
    % multilevel wavelet decomposition of the PPG signal and calculates various statistical features 
    % at each level of decomposition, including mean, std, energy and variance, which are critical for analyzing the frequency content of the signal
    % at different scales. Approximation coefficients at the last level are also analyzed to capture 
    % the overall trend of the signal.
    %
    % Inputs:
    %   data - Matrix of PPG signal data, where each column represents an epoch. The first row containing labels is excluded from the analysis.
    %   fs - Sampling rate of the PPG signal.
    %
    % Outputs:
    %   featuresTable - A table where each row contains the wavelet features for a single epoch, with each feature described by a unique name.
    %
    % Wavelet details:
    %   The function uses a 'sym6' wavelet (Symlet of order 6) for decomposition, which is suited for PPG signal analysis due to its similarity to the shape of typical biomedical signals.
    %
    % Example Usage:
    %   WTFeatures = extractPPGWTF(PPGData, 128); % Assume PPGData is preloaded and fs = 128 Hz


    % Define the levels of wavelet decomposition
    levels = 1:5;
    % Wavelet name
    waveletName = 'sym6';
    
    % Assuming the first row is labels and the rest is data
    data = data(2:end, :); % Exclude labels row for feature extraction
    
    numEpochs = size(data, 2);
    featureNames = [];
    for lvl = levels
        featureNames = [featureNames, {...
            sprintf('PPG_WTF_L%d_Energy', lvl), ...
            sprintf('PPG_WTF_L%d_Mean', lvl), ...
            sprintf('PPG_WTF_L%d_SD', lvl), ...
            sprintf('PPG_WTF_L%d_Var', lvl)}];
    end
    featureNames = [featureNames, 'PPG_WTF_AF_Energy', 'PPG_WTF_AF_Mean', 'PPG_WTF_AF_SD', 'PPG_WTF_AF_Var'];
    
    features_all_epochs = zeros(numEpochs, length(featureNames));
    
    for epoch = 1:numEpochs
        epochData = data(:, epoch);
        [C, L] = wavedec(epochData, max(levels), waveletName);
        featureIdx = 1;
        
        for lvl = levels
            % Extract detail coefficients at current level
            D = detcoef(C, L, lvl);
            % Calculate features
            features_all_epochs(epoch, featureIdx) = sum(D.^2); % Energy
            features_all_epochs(epoch, featureIdx+1) = mean(D); % Mean
            features_all_epochs(epoch, featureIdx+2) = std(D); % SD
            features_all_epochs(epoch, featureIdx+3) = var(D); % Var
            featureIdx = featureIdx + 4;
        end
        
        % Approximation coefficients at last level for AF features
        A = appcoef(C, L, waveletName, levels(end));
        features_all_epochs(epoch, featureIdx:featureIdx+3) = [sum(A.^2), mean(A), std(A), var(A)]; % AF features
    end
    
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end

