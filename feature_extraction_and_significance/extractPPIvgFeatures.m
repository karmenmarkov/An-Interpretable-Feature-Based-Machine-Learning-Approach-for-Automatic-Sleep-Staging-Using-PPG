function featuresTable = extractPPIvgFeatures(data, detected_peaks, fs)
    % Extract visibility graph features from Peak-to-Peak Intervals (PPI) of PPG data for each epoch.
    % This function uses visibility graph analysis to characterize the structural and dynamic properties
    % of PPI sequences extracted from PPG signals.
    % Inputs:
    %   data - The PPG signal data, with each column representing an
    %   epoch. First row is labels.
    %   detected_peaks - A cell array where each cell contains the indices of detected S_peaks for each epoch.
    %   fs - The sampling rate of the PPG signal.
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %   - fast_NVG: Constructs natural visibility graphs from time series data.
    %   - NVG_alg: Algorithm to process visibility graphs.
    %   - graphProperties: Calculates various graph theoretical properties.
    %
    % References:
    %   - Giovanni Iacobello (2024). Fast natural visibility graph (NVG) for MATLAB. MATLAB Central File Exchange. Retrieved April 12, 2024.
    %   - Nathan D. Cahill (2014). Graph properties function. GitHub repository. URL: https://github.com/Roberock/NetworkTopologyvsFlowVulnerbaility
    %

    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction
    
    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPI_VG_Nodes_SmallDegree', 'PPI_VG_Nodes_HighDegree', 'PPI_VG_Slope_PowerLawFit', 'PPI_VG_Degrees_Mean', 'PPI_VG_Degrees_SD', 'PPI_VG_CharPathL', 'PPI_VG_GlobalEff', 'PPI_VG_CClosed_Mean', 'PPI_VG_CClosed_SD', 'PPI_VG_Closed_LocalEff', 'PPI_VG_COpen_Mean', 'PPI_VG_COpen_SD', 'PPI_VG_Open_LocalEff'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
        
    for epoch = 1:numEpochs
        epochData = data(1:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
    
        % Extract PPI intervals for the current epoch
        PPI = diff(S_peaks) / fs * 1000; % Convert to milliseconds
        
        % Step 1: Generate the visibility graph
        VG = fast_NVG(PPI, (1:length(PPI))', 'u', 0);  % 'u' for unweighted, 0 for no boundary periodicity
    
        % Step 2: Compute the degree of each node in VG
        degrees = sum(VG, 2);  % Summing across rows gives the degree of each node
    
        % Step 3: Define small and high degree thresholds based on quartiles
        quartiles = quantile(degrees, [0.25 0.75]); % Calculate quartiles
        small_degree_threshold = quartiles(1); 
        high_degree_threshold = quartiles(2);
    
        % Step 4: Extract Visibility Graph Features
    
        %Percentage of nodes with small degree
        PPI_VG_Nodes_SmallDegree = sum(degrees <= small_degree_threshold) / length(degrees); 
    
        %Percentage of nodes with high degree
        PPI_VG_Nodes_HighDegree = sum(degrees >= high_degree_threshold) / length(degrees);
    
        % Slope of power-law fit to degree distribution
        % Assuming a power-law distribution, use log-log scales for line fitting
        [logDegrees, logCounts] = hist(log(degrees), unique(log(degrees)));
        coeffs = polyfit(logDegrees, log(logCounts), 1);
        PPI_VG_Slope_PowerLawFit = coeffs(1);  % The slope of the line fit
    
        % Mean of degrees
        PPI_VG_Degrees_Mean = mean(degrees);
    
        % SD of degrees
        PPI_VG_Degrees_SD = std(degrees);
    
        % Characteristic path length, global efficiency, mean and sd of clustering coefficients (closed and open), local efficiency (closed and open)
        [PPI_VG_CharPathL, PPI_VG_GlobalEff, PPI_VG_CClosed_Mean, PPI_VG_CClosed_SD, PPI_VG_Closed_LocalEff, PPI_VG_COpen_Mean, PPI_VG_COpen_SD, PPI_VG_Open_LocalEff] = graphProperties(VG);
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPI_VG_Nodes_SmallDegree, PPI_VG_Nodes_HighDegree, PPI_VG_Slope_PowerLawFit, PPI_VG_Degrees_Mean, PPI_VG_Degrees_SD, PPI_VG_CharPathL, PPI_VG_GlobalEff, PPI_VG_CClosed_Mean, PPI_VG_CClosed_SD, PPI_VG_Closed_LocalEff, PPI_VG_COpen_Mean, PPI_VG_COpen_SD, PPI_VG_Open_LocalEff];
    
    end
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
