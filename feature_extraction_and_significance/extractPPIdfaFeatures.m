function featuresTable = extractPPIdfaFeatures(data, detected_peaks, fs)
    % Extract detrended fluctuation analysis measures and related features
    % for each epoch of PPI data
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   The first row contains labels. 
    %   fs - The sampling rate of the PPG signal.
    %   detected_peaks - The detected peaks in the PPG signal.
    % Outputs:
    %   featuresTable - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %   - Higuchi_FD: Function to calculate the Higuchi Fractal Dimension.
    %   - dfaOverall, dfaShortLong, progressive_dfa, windowed_dfa, DMA_avg: Functions to perform
    %     different types of DFA analyses on the PPI data.
    %
    % References:
    %   - Jesús Monge-Álvarez (2024). Higuchi and Katz fractal dimension measures
    %     (https://www.mathworks.com/matlabcentral/fileexchange/50290-higuchi-and-katz-fractal-dimension-measures),
    %     MATLAB Central File Exchange. Retrieved April 12, 2024.
    %
    
    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction
    
    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPI_HFD','PPI_DFA','PPI_DFA_short_exponent','PPI_DFA_long_exponent','PPI_PDFA', 'PPI_WDFA','PPI_DMA'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
    
    %Calculate the smallest heartbeat count for profressive DFA
    smallestHeartbeatCount = Inf; % Initialize with a large number
    
    for epoch = 1:numEpochs
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
        heartbeatCount = numel(S_peaks); % Count of heartbeats in the current epoch
        
        % Update the smallestHeartbeatCount if the current epoch has fewer heartbeats
        if heartbeatCount < smallestHeartbeatCount
            smallestHeartbeatCount = heartbeatCount;
        end
    end
    
    % Since PDFA uses the difference between consecutive S_peaks (PPI intervals),
    % the segment size for PDFA should be one less than the smallest heartbeat count.
    segmentSizeForPDFA = smallestHeartbeatCount - 1;
        
    for epoch = 1:numEpochs
        epochData = data(1:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
        
        % Extract PPI intervals for the current epoch
        PPI = diff(S_peaks) / fs * 1000; % Convert to milliseconds
    
        % Higuchi fractal dimension of PPG signal
        PPI_transposed = PPI.';
        PPI_HFD = Higuchi_FD(PPI_transposed, 10);
        
        % Detrended fluctuation analysis measuers
        PPI_DFA = dfaOverall(PPI);
    
        % Short and long exponents
        [PPI_DFA_short_exponent, PPI_DFA_long_exponent] = dfaShortLong(PPI);
    
        % Progressive PDFA
        PPI_PDFA = progressive_dfa(PPI, segmentSizeForPDFA);
    
        %PPI_WDFA
        window_size = 15;
        PPI_WDFA = windowed_dfa(PPI, window_size);
    
        %PPI_DMA
        scales = unique(floor(logspace(log10(4), log10(length(PPI)/4), 20))); % Define scales based on the characteristics of this epoch's PPI
        PPI_DMA = DMA_avg(PPI,scales);
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPI_HFD,PPI_DFA,PPI_DFA_short_exponent,PPI_DFA_long_exponent,PPI_PDFA, PPI_WDFA, PPI_DMA];
    
    end
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
