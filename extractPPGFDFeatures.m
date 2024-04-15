function mergedTable = extractPPGFDFeatures(data, fs)
    % Extract frequency-domain features from PPG data for each epoch, based on methodologies
    % adapted from several key studies.
    %
    % The function segments the frequency domain into bands defined by:
    % - Wu et al., 2020 for basic frequency bands analysis.
    % - Olsen et al., 2023 for VLF, LF, HF, and total power.
    % - Ucar et al., 2018 and Bozkurt et al. for advanced spectral components impacting cardiovascular dynamics.
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch. The first row should contain labels and is not used in feature calculations.
    %   fs - The sampling rate of the PPG signal.
    % Outputs:
    %   mergedTable - Table containing the calculated features for each epoch
    %
    % Dependencies:
    % MATLAB Signal Processing Toolbox: For functions like pwelch for spectral analysis and bandpower for calculating power within specific frequency bands.


    % Assuming the first row is labels and the rest is data
    labels = data(1, :); % If labels are not needed inside this function, you can comment this line
    data = data(2:end, :); % Exclude labels row for feature extraction
    [num_samples, num_epochs] = size(data);
    
    % Define frequency bands for each study
    bandsWu = [0 1.25; 1.25 2.5; 2.5 5; 5 10; 10 20];
    freqBandsOlsen = struct('VLF', [0.0033, 0.04], 'LF', [0.04, 0.15], 'HF', [0.15, 0.4], 'Total', [0.0033, 0.4]);
    freqBandsFD = struct('LF', [0.04, 0.15], 'MF', [0.09, 0.15], 'HF', [0.15, 0.6], 'Total', [0.04, 0.6]);
    
    % Preallocate feature matrices
    featuresWu = extractWuFeatures(data, fs, bandsWu, num_epochs);
    featuresOlsen = extractOlsenFeatures(data, fs, freqBandsOlsen, num_epochs);
    featuresFD = extractFDFeatures(data, fs, freqBandsFD, num_epochs);
    
    % Combine the FD features
    mergedTable = [featuresWu, featuresOlsen, featuresFD];
end



function featuresTable = extractWuFeatures(data, fs, bands, num_epochs)
    % Extracting FD features as done in the study by Wu et al., 2020
    % Define frequency bands
    bands = [0 1.25; 1.25 2.5; 2.5 5; 5 10; 10 20];
    nBands = size(bands, 1);
    
    % Preallocate matrices to store all features for each epoch
    % Features = 5 powers + 5 powerSDs + 5 powerRatios + totalPower + 1 for labels
    featureNames = [strcat('PPG_p', string(1:5), '_Power'), ...
                    strcat('PPG_p', string(1:5), '_Power_SD'), ...
                    strcat('PPG_p', string(1:5), '_Total_Power'), ...
                    'PPG_Total_Power'];
    allFeatures = zeros(num_epochs, length(featureNames));
    
    for epoch = 1:num_epochs
        epochData = data(:, epoch);
    
        % Compute Welch's PSD for the current epoch
        [pxx, f] = pwelch(epochData, hanning(length(epochData)), [], [], fs);
        totalPower = bandpower(pxx, f, [0 20], 'psd');
        
        % Initialize variables for storing power, SD, and ratios
        powers = zeros(1, nBands);
        powerSDs = zeros(1, nBands);
        powerRatios = zeros(1, nBands);
        
        for bandIdx = 1:nBands
            bandPower = bandpower(pxx, f, bands(bandIdx,:), 'psd');
            powers(bandIdx) = bandPower;
            
            % Calculate standard deviation within each band
            bandFreqIndices = (f >= bands(bandIdx, 1)) & (f <= bands(bandIdx, 2));
            bandPxx = pxx(bandFreqIndices);
            powerSDs(bandIdx) = std(bandPxx);
            
            % Calculate power ratios
            powerRatios(bandIdx) = bandPower / totalPower;
        end
        
        % Combine all features for the current epoch
        allFeatures(epoch, :) = [powers, powerSDs, powerRatios, totalPower];
    end
    
    % Convert to table 
    featuresTable = array2table(allFeatures, 'VariableNames', featureNames);
end

function featuresTable = extractOlsenFeatures(data, fs, freqBands, num_epochs)
    % Extracting FD features as defined in Olsen et al., 2023
    freqBands = struct('VLF', [0.0033, 0.04], 'LF', [0.04, 0.15], 'HF', [0.15, 0.4],'Total', [0.0033, 0.4]);
    % Preallocate array to store the new features for each epoch
    featureNames2 = {'PPG_HF_power', 'PPG_LF_power', 'PPG_VLF_power', 'PPG_Total_power2'};
    Features2 = zeros(num_epochs, length(featureNames2)); 
    
    % FFT for loop for 2nd study's features
    for epoch = 1:num_epochs
        epochData = data(:, epoch);
        
        % Compute FFT of the signal
        N = length(epochData);
        fftSignal = fft(epochData);
        P2 = abs(fftSignal/N);
        P1 = P2(1:N/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        fFFT = fs*(0:(N/2))/N;
        
        % Calculate power spectral density in the specified frequency bands
        PPG_HF_power = bandpower(P1, fFFT, freqBands.HF, 'psd');
        PPG_LF_power = bandpower(P1, fFFT, freqBands.LF, 'psd');
        PPG_VLF_power = bandpower(P1, fFFT, freqBands.VLF, 'psd');
        PPG_Total_power2 = bandpower(P1, fFFT, freqBands.Total, 'psd');
        
        % Store the calculated features
        Features2(epoch, :) = [PPG_HF_power, PPG_LF_power, PPG_VLF_power, PPG_Total_power2];
    end
    
    % Convert to table 
    featuresTable = array2table(Features2, 'VariableNames', featureNames2);
end

function featuresTable = extractFDFeatures(data, fs, freqBandsFD, num_epochs)
    % Calculating FD features as defined in Ucar et al., 2018 and Bozkurt et al.
    % Define frequency bands for PPG FD features
    freqBandsFD = struct('LF', [0.04, 0.15], 'MF', [0.09, 0.15], 'HF', [0.15, 0.6], 'Total', [0.04, 0.6]);
    
    % Preallocate array to store the FD features for each epoch
    featureNames3 = {'PPG_LF_energy', 'PPG_MF_energy', 'PPG_HF_energy', 'PPG_Total_energy','PPG_LF/Total_energy', 'PPG_MF/Total_energy', 'PPG_HF/Total_energy', 'PPG_LF/HF_energy', 'PPG_MF/HF_energy', 'PPG_LF/MF_energy'};
    Features3 = zeros(num_epochs, length(featureNames3));
    
    % Calculate energies using FFT for each epoch
    for epoch = 1:num_epochs
        epochData = data(:, epoch);
        
        % FFT calculation
        N = length(epochData);
        fftSignal = fft(epochData);
        P2 = abs(fftSignal/N);
        P1 = P2(1:N/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        fFFT = fs*(0:(N/2))/N;
    
        % Calculate energy in the frequency bands using FFT
        PPG_LF_energy = sum(P1(fFFT >= freqBandsFD.LF(1) & fFFT <= freqBandsFD.LF(2)).^2) * (fs/N);
        PPG_MF_energy = sum(P1(fFFT >= freqBandsFD.MF(1) & fFFT <= freqBandsFD.MF(2)).^2) * (fs/N);
        PPG_HF_energy = sum(P1(fFFT >= freqBandsFD.HF(1) & fFFT <= freqBandsFD.HF(2)).^2) * (fs/N);
        PPG_Total_energy = sum(P1(fFFT >= freqBandsFD.Total(1) & fFFT <= freqBandsFD.Total(2)).^2) * (fs/N);
    
        % Energy ratios
        PPG_LF_Total_energy = PPG_LF_energy / PPG_Total_energy;
        PPG_MF_Total_energy = PPG_MF_energy / PPG_Total_energy;
        PPG_HF_Total_energy = PPG_HF_energy / PPG_Total_energy;
        PPG_LF_HF_energy = PPG_HF_energy / PPG_Total_energy;
        PPG_MF_HF_energy = PPG_HF_energy / PPG_Total_energy;
        PPG_LF_MF_energy = PPG_HF_energy / PPG_Total_energy;
    
        % Store the calculated FD energies
        Features3(epoch, :) = [PPG_LF_energy, PPG_MF_energy, PPG_HF_energy, PPG_Total_energy, PPG_LF_Total_energy, PPG_MF_Total_energy, PPG_HF_Total_energy, PPG_LF_HF_energy, PPG_MF_HF_energy, PPG_LF_MF_energy];
    end
    
    % Convert to table 
    featuresTable = array2table(Features3, 'VariableNames', featureNames3);
end
