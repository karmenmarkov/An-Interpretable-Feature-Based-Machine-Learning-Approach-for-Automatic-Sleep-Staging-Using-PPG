function featuresTable = extractPPIfdFeatures(data, detected_peaks, fs)
    % Extracts frequency domain features from Peak-to-Peak Intervals (PPI) derived from PPG data for each epoch.
    % This function interpolates PPI data to a regular time grid and then calculates the power spectral density (PSD)
    % to extract features within defined Very Low Frequency (VLF), Low Frequency (LF), and High Frequency (HF) bands.
    % The calculated features include power in the VLF, LF, HF, and total frequency bands, as well as logarithmic
    % transformations of these powers, their ratios, and the frequencies at which the peak power occurs within each band.
    %
    % Inputs:
    %   data - The PPG signal data matrix, with each column representing an epoch. The first row should contain labels.
    %   detected_peaks - A cell array where each cell contains the indices of detected peaks within each epoch of the PPG data.
    %   fs - The sampling frequency of the original PPG signal.
    %
    % Outputs:
    %   featuresTable - A table containing the calculated frequency domain features for each epoch.
    %

    
    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction
    
    numEpochs = size(data, 2);  % Number of epochs
    featureNames = {'PPI_VLF_power', 'PPI_LF_power', 'PPI_HF_power', 'PPI_Total_power', 'PPI_LogVLF', 'PPI_LogLF', 'PPI_LogHF', 'PPI_LogTotal','PPI_VLF_LF_power','PPI_VLF_HF_power','PPI_VLF_Total_power', 'PPI_LF_Total_power', 'PPI_HF_Total_power', 'PPI_LF_HF_power', 'PPI_peakVLF', 'PPI_peakLF', 'PPI_peakHF'};
    features_all_epochs = zeros(numEpochs, length(featureNames)); % Preallocate for speed
        
    for epoch = 1:numEpochs
        epochData = data(1:end, epoch); % Exclude label row
        S_peaks = detected_peaks{epoch}; % Get the indices of S peaks for the epoch
    
        % Extract PPI intervals for the current epoch
        PPI = diff(S_peaks) / fs * 1000; % Convert to milliseconds

        % Interpolation frequency
        fs_interpolated = 4; % Hz, which corresponds to a 250 ms time grid
        t_interpolated = (0:1/fs_interpolated:max(S_peaks)/fs)'; % Regular time grid in seconds
        
        % Interpolate PPI onto a regular time grid
        PPI_interpolated = interp1((S_peaks(1:end-1) + diff(S_peaks)/2) / fs, PPI, t_interpolated, 'linear', 'extrap');


        % Calculate the frequency domain representation of the PPI signal
        [psd, f] = pwelch(PPI_interpolated , hanning(length(PPI_interpolated)), [], [], fs_interpolated);
        
        % Define frequency bands
        VLF_band = [0.0033, 0.04];
        LF_band = [0.04, 0.15];
        HF_band = [0.15, 0.4];
        Total_band = [0.0033, 0.4];
    
        % Extract power in each frequency band
        PPI_VLF_power = bandpower(psd, f, VLF_band,'psd');
        PPI_LF_power = bandpower(psd, f, LF_band,'psd');
        PPI_HF_power = bandpower(psd, f, HF_band,'psd');
        PPI_Total_power = bandpower(psd, f, Total_band,'psd');
        
        % Log values
        PPI_LogVLF = log(PPI_VLF_power);
        PPI_LogLF = log(PPI_LF_power);
        PPI_LogHF = log(PPI_HF_power);
        PPI_LogTotal = log(PPI_Total_power);
        
        % Ratios
        PPI_VLF_LF_power = PPI_VLF_power / PPI_LF_power; 
        PPI_VLF_HF_power = PPI_VLF_power / PPI_HF_power;
        PPI_VLF_Total_power = PPI_VLF_power / PPI_Total_power; % same as normalized VLF power
        PPI_LF_Total_power = PPI_LF_power / PPI_Total_power; % same as normalized LF power
        PPI_HF_Total_power = PPI_HF_power / PPI_Total_power; % same as normalized HF power
        PPI_LF_HF_power = PPI_LF_power / PPI_HF_power;
    
        % Find peaks in the PSD for each band
        [~, idxVLF] = max(psd(f >= VLF_band(1) & f <= VLF_band(2)));
        PPI_peakVLF = f(idxVLF + find(f >= VLF_band(1),1) - 1);
        
        [~, idxLF] = max(psd(f >= LF_band(1) & f <= LF_band(2)));
        PPI_peakLF = f(idxLF + find(f >= LF_band(1),1) - 1);
        
        [~, idxHF] = max(psd(f >= HF_band(1) & f <= HF_band(2)));
        PPI_peakHF = f(idxHF + find(f >= HF_band(1),1) - 1);
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [PPI_VLF_power, PPI_LF_power, PPI_HF_power, PPI_Total_power, PPI_LogVLF, PPI_LogLF, PPI_LogHF, PPI_LogTotal,PPI_VLF_LF_power,PPI_VLF_HF_power,PPI_VLF_Total_power, PPI_LF_Total_power, PPI_HF_Total_power, PPI_LF_HF_power, PPI_peakVLF, PPI_peakLF, PPI_peakHF];
    
    end

    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
    
end

