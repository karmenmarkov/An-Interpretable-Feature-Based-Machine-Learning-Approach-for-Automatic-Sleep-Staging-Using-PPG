function featuresTable = extractPPGIMFFeatures(data, fs)
    % Extracts intrinsic mode function (IMF) features from PPG data using the empirical mode decomposition (EMD) method.
    % Each IMF reflects different intrinsic oscillatory modes in the signal, with the Hilbert transform applied to
    % extract instantaneous amplitude, frequency, and phase. This function focuses on comprehensive feature extraction
    % from the first IMF to analyze subtle changes in the PPG signal that may indicate physiological states.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch. The first row containing labels is excluded from the feature extraction.
    %   fs - The sampling rate of the PPG signal.
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    %
    % Dependencies:
    %   Requires the Signal Processing Toolbox for EMD and Hilbert transform functions.
    %


    % Assuming the first row is labels and the rest is data
    labels = data(1, :);  
    data = data(2:end, :); % Exclude labels row for feature extraction
    [num_samples, num_epochs] = size(data);
    
    % Define the names of the features for the first IMF
    featureNames = {
        'IMF1_Inst_Amp_Mean', 'IMF1_Inst_Amp_SD', 'IMF1_Inst_Amp_Min', 'IMF1_Inst_Amp_Max', 'IMF1_Inst_Amp_Var',...
        'IMF1_Inst_Freq_Mean', 'IMF1_Inst_Freq_SD', 'IMF1_Inst_Freq_Min', 'IMF1_Inst_Freq_Max', 'IMF1_Inst_Freq_Var',...
        'IMF1_Inst_Phase_Mean', 'IMF1_Inst_Phase_SD', 'IMF1_Inst_Phase_Min', 'IMF1_Inst_Phase_Max', 'IMF1_Inst_Phase_Var',...
        'IMF1_Kurt', 'IMF1_Skew', 'IMF1_LM_Amp_Mean', 'IMF1_LM_Amp_SD', 'IMF1_LM_Int_Mean', 'IMF1_LM_Int_SD',...
        'IMF1_LM_Ratio', 'IMF1_TP_Amp_Mean', 'IMF1_TP_Amp_SD', 'IMF1_TP_Int_Mean', 'IMF1_TP_Int_SD', 'IMF1_TP_Ratio',...
        'IMF1_avgTE', 'IMF1_VLF_Energy', 'IMF1_LF_Energy', 'IMF1_HF_Energy', 'IMF1_Total_Energy', 'IMF1_VLF/Total_energy',...
        'IMF1_LF/Total_energy', 'IMF1_HF/Total_energy', 'IMF1_VLF/HF_energy', 'IMF1_LF/HF_energy', 'IMF1_VLF/LF_energy',...
        'IMF1_Env_Mean', 'IMF1_Env_SD', 'IMF1_Env_Max', 'IMF1_Env_Min', 'IMF1_Env_Var', 'IMF1_Env_Energy', 'IMF1_Env_Area',...
        'IMF1_Env_P2P_Dist', 'IMF1_Env_Skew', 'IMF1_Env_Kurt', 'IMF1_Env_Cross_Rate'
    };
    
    % Initialize a matrix to store features for all epochs
    features_all_epochs = zeros(num_epochs, length(featureNames)); % Preallocate for speed
    
    for epoch = 1:num_epochs
        epochData = data(:, epoch);
        [imfs, ~] = emd(epochData); % Extract IMFs
        imf1 = imfs(:,1); % Consider only the first IMF for simplicity
    
        % Calculate Hilbert transform
        analyticSignal = hilbert(imf1);
        amplitudeEnvelope = abs(analyticSignal);
        instAmplitude = abs(analyticSignal);
        instPhase = unwrap(angle(analyticSignal));
        instFrequency = diff(instPhase) * (fs/(2*pi));
        
        % Calculate features for the first IMF
    
        % Mean instantaneous amplitude
        IMF1_Inst_Amp_Mean = mean(instAmplitude); 
        
        % SD of instantaneous amplitude
        IMF1_Inst_Amp_SD = std(instAmplitude); 
    
        % Min instantaneous amplitude
        IMF1_Inst_Amp_Min = min(instAmplitude); 
    
        % Max instantaneous amplitude
        IMF1_Inst_Amp_Max = max(instAmplitude); 
    
        % Variance of instantaneous amplitude
        IMF1_Inst_Amp_Var = var(instAmplitude); 
    
        % Mean instantaneous frequency
        IMF1_Inst_Freq_Mean = mean(instFrequency); 
        
        % SD of instantaneous frequency
        IMF1_Inst_Freq_SD = std(instFrequency); 
    
        % Min instantaneous frequency
        IMF1_Inst_Freq_Min = min(instFrequency); 
    
        % Max instantaneous frequency
        IMF1_Inst_Freq_Max = max(instFrequency); 
    
        % Variance of instantaneous frequency
        IMF1_Inst_Freq_Var = var(instFrequency); 
    
        % Mean instantaneous phase
        IMF1_Inst_Phase_Mean = mean(instPhase); 
        
        % SD of instantaneous phase
        IMF1_Inst_Phase_SD = std(instPhase); 
    
        % Min instantaneous phase
        IMF1_Inst_Phase_Min = min(instPhase); 
    
        % Max instantaneous phase
        IMF1_Inst_Phase_Max = max(instPhase); 
    
        % Variance of instantaneous phase
        IMF1_Inst_Phase_Var = var(instPhase); 
    
        % Kurtosis of IMF
        IMF1_Kurt = kurtosis(imf1);
    
        % Skewness of IMF
        IMF1_Skew = skewness(imf1);
    
        % IMF1 local maxima (LM)
        % Calculate the mean and standard deviation of the signal amplitude
        meanAmp = mean(imf1);
        stdAmp = std(imf1);
    
        % Use 'findpeaks' to find LM
        [LM_Amp, LM_Loc] = findpeaks(imf1, 'MinPeakHeight', meanAmp, 'MinPeakDistance', fs*0.1); % Example criteria
        N = length(imf1);
    
        % The average amplitudes of IMF1  at LM
        IMF1_LM_Amp_Mean = mean(LM_Amp);
    
        % The SD in the amplitudes of IMF1  at LM
        IMF1_LM_Amp_SD = std(LM_Amp);
    
        % The average time between points of LM 
        IMF1_LM_Int_Mean = mean(diff(LM_Loc)) / fs;
    
        % The SD in time between consecutive LM points
        IMF1_LM_Int_SD = std(diff(LM_Loc)) / fs;
    
        % The proportion of IMF1 that are identified as LM
        IMF1_LM_Ratio = length(LM_Loc) / N * 100;
    
        % IMF1 transition points (TP)
        dImf1 = diff(imf1); % First derivative
        zeroCrossings = find(dImf1(1:end-1) .* dImf1(2:end) < 0) + 1; % Transition points
        TP_Amp = imf1(zeroCrossings);  % Amplitudes at Transition Points
        
        % The average amplitude of IMF1  at TP
        IMF1_TP_Amp_Mean = mean(TP_Amp);
    
        % The SD in the amplitudes of IMF1  at TP
        IMF1_TP_Amp_SD = std(TP_Amp);
    
        % The average time between points of TP
        IMF1_TP_Int_Mean = mean(diff(zeroCrossings)) / fs;
    
        % The SD in the time between consecutive TP points
        IMF1_TP_Int_SD = std(diff(zeroCrossings)) / fs;
    
        % The proportion of IMF1 that are identified as TP (%)
        IMF1_TP_Ratio = length(zeroCrossings) / N * 100;
    
        % The average Teager energy computed across IMF1
        TeagerEnergy = imf1(2:end-1).^2 - imf1(3:end).*imf1(1:end-2);
        IMF1_avgTe = mean(TeagerEnergy);
    
        % Extracting energy features
        N = length(imf1); % Length of the signal
        f = fs*(0:(N/2))/N; % Frequency range
        IMF1_fft = fft(imf1); % Perform FFT
        IMF1_fft = IMF1_fft(1:N/2+1); % Keep only the positive half
        IMF1_PSD = (1/(fs*N)) * abs(IMF1_fft).^2; % Power spectral density
        IMF1_PSD(2:end-1) = 2*IMF1_PSD(2:end-1); % Double the energy except for DC and Nyquist
        
        % Define frequency bands
        VLF_band = [0 0.04];
        LF_band = [0.04 0.15];
        HF_band = [0.15 0.4];
        Total_band = [0 0.4];
        
        % Helper function to calculate band energy
        band_energy = @(band) sum(IMF1_PSD(f>=band(1) & f<=band(2))) * (f(2)-f(1));
        
        % Calculate the energy in each band
        IMF1_VLF_Energy = band_energy(VLF_band);
        IMF1_LF_Energy = band_energy(LF_band);
        IMF1_HF_Energy = band_energy(HF_band);
        IMF1_Total_Energy = band_energy(Total_band);
    
        % The ratio between VLF and Total Energies
        IMF1_VLF_Total_Energy = IMF1_VLF_Energy/IMF1_Total_Energy;
    
        % The ratio between LF and Total Energies
        IMF1_LF_Total_Energy = IMF1_LF_Energy/IMF1_Total_Energy;
    
        % The ratio between HF and Total Energies
        IMF1_HF_Total_Energy = IMF1_HF_Energy/IMF1_Total_Energy;
    
        % The ratio between VLF and HF energies
        IMF1_VLF_HF_Energy = IMF1_VLF_Energy/IMF1_HF_Energy;
    
        % The ratio between LF and HF energies
        IMF1_LF_HF_Energy = IMF1_LF_Energy/IMF1_HF_Energy;
    
        % The ratio between VLF and LF energies
        IMF1_VLF_LF_Energy = IMF1_VLF_Energy/IMF1_LF_Energy;
    
        % The average value of the amplitude envelope
        IMF1_Env_Mean = mean(amplitudeEnvelope);
    
        % The SD of the amplitude envelope
        IMF1_Env_SD = std(amplitudeEnvelope);
    
        % The highest value of the amplitude envelope
        IMF1_Env_Max = max(amplitudeEnvelope);
    
        % The lowest value of the amplitude envelope
        IMF1_Env_Min = min(amplitudeEnvelope);
    
        % The variance of the amplitude envelope
        IMF1_Env_Var = var(amplitudeEnvelope);
    
        % The total energy of the amplitude envelope
        IMF1_Env_Energy = sum(amplitudeEnvelope.^2);
    
        % The area of amplitude envelope
        IMF1_Env_Area = trapz(amplitudeEnvelope); 
    
        % The average distance between consecutive peaks in the amplitude envelope
        [~, peakLocs] = findpeaks(amplitudeEnvelope); % try to adjust
        IMF1_Env_P2P_Dist = mean(diff(peakLocs));
    
        % The skewness of amplitude envelope
        IMF1_Env_Skew = skewness(amplitudeEnvelope);
    
        % The kurtosis of amplitude envelope
        IMF1_Env_Kurt = kurtosis(amplitudeEnvelope);
    
        % The rate at which the amplitude envelope crosses its mean value
        crosses = diff(amplitudeEnvelope > IMF1_Env_Mean) ~= 0;  % Detects crossings
        IMF1_Env_Cross_Rate = sum(crosses) / length(amplitudeEnvelope);
    
    
        % Assign the calculated features for the current epoch to the preallocated matrix
        features_all_epochs(epoch,:) = [IMF1_Inst_Amp_Mean, IMF1_Inst_Amp_SD, IMF1_Inst_Amp_Min, IMF1_Inst_Amp_Max, IMF1_Inst_Amp_Var,...
        IMF1_Inst_Freq_Mean, IMF1_Inst_Freq_SD, IMF1_Inst_Freq_Min, IMF1_Inst_Freq_Max, IMF1_Inst_Freq_Var,...
        IMF1_Inst_Phase_Mean, IMF1_Inst_Phase_SD, IMF1_Inst_Phase_Min, IMF1_Inst_Phase_Max, IMF1_Inst_Phase_Var,...
        IMF1_Kurt, IMF1_Skew, IMF1_LM_Amp_Mean, IMF1_LM_Amp_SD, IMF1_LM_Int_Mean, IMF1_LM_Int_SD,...
        IMF1_LM_Ratio, IMF1_TP_Amp_Mean, IMF1_TP_Amp_SD, IMF1_TP_Int_Mean, IMF1_TP_Int_SD, IMF1_TP_Ratio,...
        IMF1_avgTe, IMF1_VLF_Energy, IMF1_LF_Energy, IMF1_HF_Energy, IMF1_Total_Energy, IMF1_VLF_Total_Energy,...
        IMF1_LF_Total_Energy, IMF1_HF_Total_Energy, IMF1_VLF_HF_Energy, IMF1_LF_HF_Energy, IMF1_VLF_LF_Energy,...
        IMF1_Env_Mean, IMF1_Env_SD, IMF1_Env_Max, IMF1_Env_Min, IMF1_Env_Var, IMF1_Env_Energy, IMF1_Env_Area,...
        IMF1_Env_P2P_Dist, IMF1_Env_Skew, IMF1_Env_Kurt, IMF1_Env_Cross_Rate];
    end

    % Create the output table with feature names as column headers
    featuresTable = array2table(features_all_epochs, 'VariableNames', featureNames);
end
