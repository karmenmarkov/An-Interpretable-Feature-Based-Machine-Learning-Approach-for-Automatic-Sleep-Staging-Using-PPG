function featuresTable = extractPPGTDFeatures(data, detected_peaks, detected_onsets, fs)
    % Extract time-domain features from PPG data for each epoch
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch. Assumes the first row contains labels which are excluded from calculations.
    %   detected_peaks - A cell array where each cell contains the indices of detected S_peaks for each epoch.
    %   detected_onsets - A cell array where each cell contains the indices of detected O_points for each epoch.
    %   fs - The sampling rate of the PPG signal.
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    % Dependencies:
    %   Accurate Peak and Onset Detection: The function relies on the accurate detection of peaks and onsets
    %   MATLAB’s Base and Statistics Toolboxes: Required for mathematical operations and statistical functions like mean, std, median, range, prctile, etc.
    
    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPG_Min', 'PPG_MAD', 'PPG_TM25', 'PPG_TM50', 'PPG_avgCL', 'PPG_avgE', 'PPG_Max', 'PPG_Mean', 'PPG_Range', 'PPG_SD', 'PPG_Median', 'PPG_avgAD', 'PPG_CM', 'PPG_RMSSD', 'PPG_RMS', 'PPG_SE', 'PPG_Signtest_p', 'PPG_Signtest_h', 'PPG_Q10', 'PPG_Q25', 'PPG_Q75', 'PPG_Q90', 'PPG_CoV', 'PPG_SDSD', 'PPG_SPV', 'PPG_Var', 'PPG_stdAD', 'PPG_Ymax', 'PPG_Ymin', 'PPG_avgTe', 'PPG_SD1', 'PPG_SD2', 'PPG_RSD1SD2', 'PPG_kurt', 'PPG_skew', 'PPG_IQR', 'PPG_SF', 'PPG_HaM','PPG_GM', 'PPG_Ha', 'PPG_Hm', 'PPG_Hc', 'PPG_SVD', 'PPG_CCM'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
    
    for epoch = 1:numEpochs
        epochData = data(2:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
        O_peaks = detected_onsets{epoch};
        
        % Feature Calculations
    
        % Minum value within the PPG signal  
        PPG_Min = min(epochData);
    
        % Median Absolute Deviation
        PPG_MAD = mad(epochData, 1);
    
        % 25% trimmed mean
        PPG_TM25 = trimmean(epochData, 25);
    
        % 50% trimmed mean
        PPG_TM50 = trimmean(epochData, 50);
        
        % Average Curve Length
        n = length(epochData); % Total number of samples in the epoch
        PPG_avgCL = sum(abs(diff(epochData))) / (n-1); % Average curve length
    
        % Average Energy
        n = length(epochData); % Total number of samples in the epoch
        PPG_avgE = sum(epochData.^2) / n; % Average energy
    
        % Max value within the PPG signa
        PPG_Max = max(epochData);
    
        % The average value of the PPG signal
        PPG_Mean = mean(epochData);
    
        % The difference beteen the highest and lowest values in the PPG signal
        PPG_Range = range(epochData);
    
        % The standard deviation of the PPG signal 
        PPG_SD = std(epochData);
    
        % Median value of the PPG signal
        PPG_Median = median(epochData);
    
        % Mean Absolute Deviation
        PPG_avgAD = mean(abs(epochData - mean(epochData)));
    
        % 10th central moment of PPG signal
        PPG_CM = moment(epochData, 10);
    
        % RMSSD (root mean square of successive differences)
        ppgIntervals = diff(S_peaks) * (1000 / fs); % Calculate the time intervals between S peaks in milliseconds. Convert sample intervals to milliseconds
        PPG_RMSSD = sqrt(mean(ppgIntervals.^2)); % RMSSD in milliseconds
    
        % RMS (root mean square)
        PPG_RMS = rms(epochData);
    
        % Standard Error
        PPG_SE = std(epochData) / sqrt(length(epochData));
    
        % Sign tests
        [p, h] = signtest(epochData);
        PPG_Signtest_p = p;
        PPG_Signtest_h = h;
    
        % Percentials of PPG
        PPG_Q10 = prctile(epochData, 10);
        PPG_Q25 = prctile(epochData, 25);
        PPG_Q75 = prctile(epochData, 75);
        PPG_Q90 = prctile(epochData, 90);
    
        % Coefficient of Variation
        PPG_CoV = (PPG_SD/PPG_Mean)*100; 
    
        % SDSD of successive peak-to-peak interval differences
        ppgIntervalDiffs = diff(ppgIntervals); % Successive differences between intervals
        PPG_SDSD = std(ppgIntervalDiffs);
    
        % SPV - The maximum value of the systolic peak in one PPG cycle
        PPG_SPV = max(epochData(S_peaks));
    
        % Variance of PPG signal
        PPG_Var = var(epochData);
    
        % Std of absolute deviation of PPG signal
        PPG_stdAD = std(abs(epochData - mean(epochData)));
    
        % Number of local maximum in epochs
        PPG_Ymax = length(S_peaks);
    
        % Number of local minimum in epochs
        PPG_Ymin = length(O_peaks);
    
        % Average Teager energy
        n = length(epochData);
        TE = 0;
        for i = 3:n
            TE = TE + (epochData(i-1)^2 - epochData(i) * epochData(i-2));
        end
        PPG_avgTe = TE / n;
    
        % Poincaré SD1 (short-term variability)
        PPG_SD1 = std(ppgIntervalDiffs) / sqrt(2);
    
        % Poincaré SD2 (long-term variability)
        covariance = cov(ppgIntervals(1:end-1), ppgIntervals(2:end));
        PPG_SD2 = sqrt(2 * var(ppgIntervals) - covariance(1, 2));

        % Ratio between Poincaré SD1 and SD2
        PPG_RSD1SD2 = PPG_SD1/PPG_SD2;
    
        % Kurtosis
        PPG_kurt = kurtosis(epochData);
    
        % Skewness
        PPG_skew = skewness(epochData);
    
        % Interquartile range
        PPG_IQR = iqr(epochData);
    
        % Harmonic mean
        PPG_HaM = harmmean(epochData);
    
        % Geometric mean
        PPG_GM = geomean(epochData + 1e-10);
    
        % Shape factor
        % denominator
        denominator = mean(sqrt(abs(epochData)));
        PPG_SF = PPG_RMS / denominator;
    
        % Hjorth Activity (Variance of the signal)
        PPG_Ha = var(epochData);
        
        % Hjorth Mobility (Variance of the first derivative over the Variance of the signal)
        dx = diff(epochData); % First derivative of the signal
        PPG_Hm = sqrt(var(dx) / PPG_Ha);
        
        % Hjorth Complexity (Variance of the second derivative over the Variance of the first derivative)l
        ddx = diff(dx); % Second derivative of the signal
        PPG_Hc = sqrt(max(var(ddx) / var(dx) - 1, 0));
    
        % Singular value decomposition
        PPG_SVD = svd(epochData);
    
        % Complex correlation measure
        CCM_sum = 0;

        % 1. Calculate the areas of triangles for overlapping windows of three points
        for i = 1:(n - 2)
            % Define the points
            x1 = epochData(i);
            y1 = epochData(i + 1);
            x2 = epochData(i + 1);
            y2 = epochData(i + 2);
            
            % Compute the area of the triangle
            A = abs(x1*y2 - x2*y1) / 2;
            
            % Sum the areas
            CCM_sum = CCM_sum + A;
        end
        
        % 2. Normalizing constant Cn
        Cn = pi * PPG_SD1 * PPG_SD2;
    
        % 3. Compute CCM
        PPG_CCM = CCM_sum / (n - 2) / Cn; % Normalize by the number of triangles and Cn

        % Lyapunov exponent of PPG signal - time-consuming, add later
        %PPG_LC = lyapunovExponent(epochData, fs);
    
        % Higuchi fractal dimension of PPG signal - time-consuming, add later
        %epoch_transposed = epochData.';
        %PPG_HFD = Higuchi_FD(epoch_transposed, 100); 
    
        % Katz fractal dimension of PPG signal  - time-consuming, add later
        %PPG_KFD = Katz_FD(epoch_transposed);

        % Pulse contour characteristic value mean
        %PPG_K_avg - too complicated, need blood pressure values
    
        % Pulse contour characteristic value std
        %PPG_K_std - too complicated, need blood pressure values


        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPG_Min, PPG_MAD, PPG_TM25, PPG_TM50, PPG_avgCL, PPG_avgE, PPG_Max, PPG_Mean, PPG_Range, PPG_SD, PPG_Median, PPG_avgAD, PPG_CM, PPG_RMSSD, PPG_RMS, PPG_SE, PPG_Signtest_p, PPG_Signtest_h, PPG_Q10, PPG_Q25, PPG_Q75, PPG_Q90, PPG_CoV, PPG_SDSD, PPG_SPV, PPG_Var, PPG_stdAD, PPG_Ymax, PPG_Ymin, PPG_avgTe, PPG_SD1, PPG_SD2, PPG_RSD1SD2, PPG_kurt, PPG_skew, PPG_IQR, PPG_SF, PPG_HaM, PPG_GM, PPG_Ha, PPG_Hm, PPG_Hc, PPG_SVD, PPG_CCM];
    end
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end



