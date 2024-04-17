function featuresTable = extractPPITDFeatures(data, detected_peaks, fs)
    % Extracts time-domain and related physiological features from peak-to-peak intervals (PPI) 
    % of PPG data for each epoch. This function calculates various heart rate variability metrics,
    % statistical features, and non-linear characteristics from the intervals between detected peaks.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   fs - The sampling rate of the PPG signal.
    %   detected_peaks - The detected peaks in the PPG signal.
    % Outputs:
    %   featuresTable - Table containing the calculated features for each epoch
    % Dependencies:
    %   Requires the Signal Processing Toolbox for some statistical calculations and transformations.
    %   `TINN` and `Triangular_Index` are computed using the `triangularInterp` function, which estimates the base width and regularity of the NN interval histogram. This measurement is crucial for assessing the autonomic nervous system's regulation of heart intervals.

    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction

    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPI_RMSSD', 'PPI_RMS', 'PPI_SDNN', 'PPI_Mean', 'PPI_SDSD', 'PPI_Max', 'PPI_Min', 'PPI_NN50', 'PPI_pNN50', 'PPI_NN20', 'PPI_pNN20', 'PPI_MAD', 'PPI_stdAD', 'PPI_avgAD', 'PPI_Range', 'PPI_Median', 'PPI_SE', 'PPI_avgCL', 'PPI_avgE', 'PPI_TM25', 'PPI_TM50', 'PPI_Q5', 'PPI_Q10', 'PPI_Q25', 'PPI_Q50', 'PPI_Q75', 'PPI_Q90', 'PPI_Q95', 'PPI_CM', 'PPI_CoV', 'PPI_Signtest_p', 'PPI_Signtest_h', 'PPI_Normalitytest_p', 'PPI_Normalitytest_h', 'PPI_rPP', 'PPI_avgTe', 'PPI_LM_Amp_Mean', 'PPI_LM_Amp_SD', 'PPI_LM_Int_Mean', 'PPI_LM_Int_SD', 'PPI_LM_Ratio', 'PPI_TP_Amp_Mean', 'PPI_TP_Amp_SD', 'PPI_TP_Int_Mean', 'PPI_TP_Int_SD', 'PPI_TP_Ratio', 'PPI_IMF1_avgTe', 'PPI_IMF1_LM_Amp_Mean', 'PPI_IMF1_LM_Amp_SD', 'PPI_IMF1_LM_Int_Mean', 'PPI_IMF1_LM_Int_SD', 'PPI_IMF1_LM_Ratio', 'PPI_IMF1_TP_Amp_Mean', 'PPI_IMF1_TP_Amp_SD', 'PPI_IMF1_TP_Int_Mean', 'PPI_IMF1_TP_Int_SD', 'PPI_IMF1_TP_Ratio', 'PPI_SD1', 'PPI_SD2', 'PPI_RSD1SD2', 'PPI_GM', 'PPI_HaM', 'PPI_Ha', 'PPI_Hm', 'PPI_Hc', 'PPI_Kurt', 'PPI_Skew', 'PPI_SF', 'PPI_IQR', 'PPI_CCM', 'PPI_SVD', 'PPI_TINN', 'PPI_Triangular_Index'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
    
    for epoch = 1:numEpochs
        epochData = data(1:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
        
        % Extract PPI intervals for the current epoch
        PPI = diff(S_peaks) / fs * 1000; % Convert to milliseconds
       
        % Feature Calculations
    
        % Root mean square of successive differences
        PPI_RMSSD =  sqrt(mean(diff(PPI).^2));
    
        % Root mean square of PPI
        PPI_RMS = sqrt(mean(PPI).^2);
    
        %Standard deviation of peak-to-peak intervals
        PPI_SDNN = std(PPI);
    
        % Mean of PPI
        PPI_Mean = mean (PPI);
        
        % Standard deviation of successive differences
        PPI_SDSD = std(diff(PPI));
        
        % Max and min of PPI
        PPI_Max = max(PPI);
        PPI_Min = min(PPI);
    
        % Count of differences greater than 50ms
        PPI_NN50 = sum(abs(diff(PPI)) > 50);
    
        % Percentage of differences between adjacent intervals greater than 50 ms
        PPI_pNN50 = sum(abs(diff(PPI)) > 50) / (length(PPI) - 1) * 100;
    
        % Number of interval differences greater than 20ms
        PPI_NN20 = sum(abs(diff(PPI)) > 20);
    
        % Percentage of differences greater than 20 ms
        PPI_pNN20 = sum(abs(diff(PPI)) > 20) / (length(PPI) - 1) * 100;
    
        % Median absolute deviation
        PPI_MAD = mad(PPI, 1);
    
        % Standard deviation of absolute deviation
        PPI_stdAD = std(abs(PPI - PPI_Mean));
    
        % Mean absolute deviation
        PPI_avgAD = mean(abs(PPI - PPI_Mean));
    
        % Range
        PPI_Range = max(PPI) - min(PPI); 
    
        % Median
        PPI_Median = median(PPI);
    
        %Standard error
        PPI_SE = std(PPI) / sqrt(length(PPI)); 
    
        % Average Curve Length
        n = length(PPI); % Total number of samples in the epoch
        PPI_avgCL = sum(abs(diff(PPI))) / (n-1); % Average curve length
    
        % Average energy - TODO
        PPI_avgE = mean(PPI.^2);
    
        % Trimmed means
        PPI_TM25 = trimmean(PPI,25); % 25% trimmed mean
        PPI_TM50 = trimmean (PPI,50); % 50% trimmed mean
    
        % Percentiles
        PPI_Q5 = prctile(PPI, 5);
        PPI_Q10 = prctile(PPI, 10);
        PPI_Q25 = prctile(PPI, 25);
        PPI_Q50 = prctile(PPI, 50);
        PPI_Q75 = prctile(PPI, 75);
        PPI_Q90 = prctile(PPI, 90);
        PPI_Q95 = prctile(PPI, 95);
    
        % 10th central moment of PPG signal
        PPI_CM = moment(PPI, 10);
    
        % Coefficient of variation 
        PPI_CoV = PPI_SDNN/PPI_Mean*100;
       
        % Sign tests
        [p, h] = signtest(PPI);
        PPI_Signtest_p = p;
        PPI_Signtest_h = h;
    
        % Normality tests
        [h1, p1] = kstest(PPI);
        PPI_Normalitytest_p = p1;
        PPI_Normalitytest_h = h1;
    
        % Autocorrelation for PPI
        % Shift PPI by one to get ppt+1 and compute the means
        ppt = PPI(1:end-1); % PP interval series excluding the last element
        ppt_plus_1 = PPI(2:end); % PP interval series excluding the first element
        R = corrcoef(ppt, ppt_plus_1); % Calculate Pearson correlation coefficient using corrcoef
        PPI_rPP = R(1,2); % The autocorrelation coefficient rPP is the off-diagonal element of R
        
        % Teager energy features
        % 1. Calculate Teager Energy for PPI
        TeagerEnergy = [0; PPI(2:end-1).^2 - PPI(3:end).*PPI(1:end-2); 0];
    
        % 2. Calculate average Teager energy
        TeagerEnergy_NoPadding = PPI(2:end-1).^2 - PPI(3:end).*PPI(1:end-2); % Calculate Teager energy without padding for accurate average
        PPI_avgTe = mean(TeagerEnergy_NoPadding); % Calculate average Teager energy
    
        % 3. Find Local Maxima (LM) and calculate features
        [LM_Amp, LM_Loc] = findpeaks(TeagerEnergy);
    
        % 4. Calculate LM features
        PPI_LM_Amp_Mean = mean(LM_Amp); % The average amplitudes of TeagerEnergy at LM
        PPI_LM_Amp_SD = std(LM_Amp); % The std of amplitudes of TeagerEnergy  at LM
        PPI_LM_Int_Mean = mean(diff(LM_Loc)); % The average distance between LM points in TeagerEnergy
        PPI_LM_Int_SD = std(diff(LM_Loc)); % The std of distance between LM points in TeagerEnergy
        PPI_LM_Ratio = length(LM_Loc) / length(PPI) * 100; %The proportion of TeagerEnergy that are identified as LM
    
        % 5. Find Transition Points (TPs) by finding zero-crossings in the first
        % derivative of Teager energy, calculate features
        TE_diff = diff(TeagerEnergy); 
        TP_Loc = find(TE_diff(1:end-1) .* TE_diff(2:end) < 0) + 1;
        TP_Amp = TeagerEnergy(TP_Loc);
        
        % 6. Calculate TP features
        PPI_TP_Amp_Mean = mean(TP_Amp);% The average amplitudes of TeagerEnergy  at TP
        PPI_TP_Amp_SD = std(TP_Amp); % The std of amplitudes of TeagerEnergy  at TP
        PPI_TP_Int_Mean = mean(diff(TP_Loc)); % The average time between TP points in TeagerEnergy in milliseconds
        PPI_TP_Int_SD = std(diff(TP_Loc)); % The std of time between TP points in TeagerEnergy in milliseconds
        PPI_TP_Ratio = length(TP_Loc) / length(PPI) * 100; %The proportion of TeagerEnergy that are identified as TP
    
        % Teager energy features of IMF1
        % 1. Get IMF1
        [imfs, ~] = emd(PPI); % Extract IMFs
        IMF1 = imfs(:,1); % Consider only the first IMF for simplicity
    
        % 2. Calculate Teager Energy for IMF1
        TeagerEnergy_IMF1 = [0; IMF1(2:end-1).^2 - IMF1(3:end).*IMF1(1:end-2); 0];
    
        % 3. Calculate average Teager Energy for IMF1
        TeagerEnergy_IMF1_NoPadding = IMF1(2:end-1).^2 - IMF1(3:end).*IMF1(1:end-2); % Calculate Teager energy without padding for accurate average
        PPI_IMF1_avgTe = mean(TeagerEnergy_IMF1_NoPadding); % Calculate average Teager energy
        
        % 4. Find Local Maxima
        [IMF1_LM_Amp, IMF1_LM_Loc] = findpeaks(TeagerEnergy_IMF1);
    
        % 5. Calculate IMF1 Teager Energy LM features
        PPI_IMF1_LM_Amp_Mean = mean(IMF1_LM_Amp); % The average amplitudes of TeagerEnergy at LM
        PPI_IMF1_LM_Amp_SD = std(IMF1_LM_Amp); % The std of amplitudes of TeagerEnergy  at LM
        PPI_IMF1_LM_Int_Mean = mean(diff(IMF1_LM_Loc)); % The average distance between LM points in TeagerEnergy
        PPI_IMF1_LM_Int_SD = std(diff(IMF1_LM_Loc)); % The std of distance between LM points in TeagerEnergy
        PPI_IMF1_LM_Ratio = length(IMF1_LM_Loc) / length(IMF1) * 100; %The proportion of TeagerEnergy that are identified as LM
        
        % 6. Find Transition Points
        TE_diff = diff(TeagerEnergy_IMF1);
        IMF1_TP_Loc = find(TE_diff(1:end-1) .* TE_diff(2:end) < 0) + 1;
        IMF1_TP_Amp = TeagerEnergy_IMF1(IMF1_TP_Loc);
    
        % 7. Calculate TP features
        PPI_IMF1_TP_Amp_Mean = mean(IMF1_TP_Amp);% The average amplitudes of TeagerEnergy  at TP
        PPI_IMF1_TP_Amp_SD = std(IMF1_TP_Amp); % The std of amplitudes of TeagerEnergy  at TP
        PPI_IMF1_TP_Int_Mean = mean(diff(IMF1_TP_Loc)); % The average time between TP points in TeagerEnergy in milliseconds
        PPI_IMF1_TP_Int_SD = std(diff(IMF1_TP_Loc)); % The std of time between TP points in TeagerEnergy in milliseconds
        PPI_IMF1_TP_Ratio = length(IMF1_TP_Loc) / length(IMF1) * 100; %The proportion of TeagerEnergy that are identified as TP
      
       
        % Poincaré features
        ppiIntervalDiffs = diff(PPI); % Successive differences between intervals
    
        % Poincaré SD1 (short-term variability)
        PPI_SD1 = std(ppiIntervalDiffs) / sqrt(2);
        
        % Poincaré SD2 (long-term variability)
        covariance = cov(ppiIntervalDiffs(1:end-1), ppiIntervalDiffs(2:end)); % Calculate covariance
        PPI_SD2 = sqrt(2 * var(ppiIntervalDiffs) - covariance(1, 2));
    
        % Ratio between Poincaré SD1 and SD2
        PPI_RSD1SD2 = PPI_SD1/PPI_SD2;
    
        % Geometric mean
        PPI_GM = geomean(PPI + 1e-10);
    
        % Harmonic mean
        PPI_HaM = harmmean(PPI);
    
        % Hjorth Activity (Variance of the signal)
        PPI_Ha =  var(PPI);
    
        % Hjorth Mobility (Variance of the first derivative over the Variance of the signal)
        dx = diff(PPI); % First derivative of the signal
        PPI_Hm = sqrt(var(dx) / PPI_Ha);
    
        % Hjorth Complexity (Variance of the second derivative over the Variance of the first derivative)l
        ddx = diff(dx); % Second derivative of the signal
        PPI_Hc = sqrt(max(var(ddx) / var(dx) - 1, 0));
    
        % Kurtosis
        PPI_Kurt = kurtosis(PPI);
    
        % Skewness
        PPI_Skew = skewness(PPI);
    
        % Shape factor
        denominator = mean(sqrt(abs(PPI)));
        PPI_SF = PPI_RMS / denominator;
    
        % Interfuartile range
        PPI_IQR = iqr(PPI);
    
        % Complex correlation measure - TODO
        CCM_sum = 0;
        
        % Calculate the areas of triangles for overlapping windows of three points
        for i = 1:(n - 2)
            % Define the points
            x1 = PPI(i);
            y1 = PPI(i + 1);
            x2 = PPI(i + 1);
            y2 = PPI(i + 2);
            
            % Compute the area of the triangle
            A = abs(x1*y2 - x2*y1) / 2;
            
            % Sum the areas
            CCM_sum = CCM_sum + A;
        end
        
        % Normalizing constant Cn
        Cn = pi * PPI_SD1 * PPI_SD2;
    
        % Compute CCM
        PPI_CCM = CCM_sum / (n - 2) / Cn; % Normalize by the number of triangles and Cn
        
        % Singular value decomposition
        PPI_SVD = svd(PPI);

        % Calculate the Triangular Interpolation of NN Interval Histogram
        % and triangular index

        % Calculate bin width
        IQR_PPI = iqr(PPI);
        n = length(PPI);
        
        % Calculate bin width only if IQR_PPI is positive
        if IQR_PPI > 0
            bin_width = 2 * IQR_PPI / (n^(1/3));
        else
            bin_width = 1000 / 128; % Default positive bin width; % You need to determine what value is appropriate for your data
        end

        % Calculate the features
        [PPI_TINN, PPI_Triangular_Index] = triangularInterp(PPI, bin_width);
    
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPI_RMSSD, PPI_RMS, PPI_SDNN, PPI_Mean, PPI_SDSD, PPI_Max, PPI_Min, PPI_NN50, PPI_pNN50, PPI_NN20, PPI_pNN20, PPI_MAD, PPI_stdAD, PPI_avgAD, PPI_Range, PPI_Median, PPI_SE, PPI_avgCL, PPI_avgE, PPI_TM25, PPI_TM50, PPI_Q5, PPI_Q10, PPI_Q25, PPI_Q50, PPI_Q75, PPI_Q90, PPI_Q95, PPI_CM, PPI_CoV, PPI_Signtest_p, PPI_Signtest_h, PPI_Normalitytest_p, PPI_Normalitytest_h, PPI_rPP, PPI_avgTe, PPI_LM_Amp_Mean, PPI_LM_Amp_SD, PPI_LM_Int_Mean, PPI_LM_Int_SD, PPI_LM_Ratio, PPI_TP_Amp_Mean, PPI_TP_Amp_SD, PPI_TP_Int_Mean, PPI_TP_Int_SD, PPI_TP_Ratio, PPI_IMF1_avgTe, PPI_IMF1_LM_Amp_Mean, PPI_IMF1_LM_Amp_SD, PPI_IMF1_LM_Int_Mean, PPI_IMF1_LM_Int_SD, PPI_IMF1_LM_Ratio, PPI_IMF1_TP_Amp_Mean, PPI_IMF1_TP_Amp_SD, PPI_IMF1_TP_Int_Mean, PPI_IMF1_TP_Int_SD, PPI_IMF1_TP_Ratio, PPI_SD1, PPI_SD2, PPI_RSD1SD2, PPI_GM, PPI_HaM, PPI_Ha, PPI_Hm, PPI_Hc, PPI_Kurt, PPI_Skew, PPI_SF, PPI_IQR, PPI_CCM, PPI_SVD, PPI_TINN, PPI_Triangular_Index];
    
    end
    
    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end

