% Feature Extraction for PPG Data Analysis
% This script processes preprocessed PPG data to extract various physiological and statistical features.
% The script reads data from CSV files,  and extracts features related to peaks, onsets, APG, time-domain, frequency-domain,
% wavelet transform, IMF, PPI, and entropy measures.
%
% Input: Preprocessed PPG data stored in CSV files.
% Output: Features extracted from the PPG data stored in new CSV files.
% Requires: Signal Processing Toolbox, Statistics and Machine Learning
% Toolbox, custom functions for feature extraction.
%

% Add path to functions
addpath('/Users/kmarkov/Documents/Matlab_codes');
addpath('/Users/kmarkov/Documents/Matlab_codes/ppg-beats-main/source');

cleanDataFolder = '/Users/kmarkov/Documents/clean_data_normalized/';
outputFolder = '/Users/kmarkov/Documents/extracted_features_normalized/';


% List all CSV files in the clean data folder
dataFiles = dir(fullfile(cleanDataFolder, '*.csv'));

% Make sure to define failedFiles and failedFeatures before the loop
failedFiles = {};
failedFeatures = {};

% Loop through each file
for fileIdx = 1:length(dataFiles)
    fileName = dataFiles(fileIdx).name; % Extract the file name
    filePath = fullfile(cleanDataFolder, fileName); % Construct full file path
    featuresFailedForFile = {}; % Initialize list to keep track of features that fail to extract
    try
        % Load the data
        data = csvread(filePath, 0, 0);
        fs = 128; % Sampling frequency

        % Initialize an empty table to hold all extracted features
        merged_features_table = table();

        % Individual try-catch for each feature extraction function

        % Get Speaks and Opoints
        try
            [detected_peaks, detected_onsets, data, valid_epochs_index] = detectPeaksOnsets(data, fs);
        catch ME
            disp(['Failed to detect peaks and onsets for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'detectPeaksOnsets';
            continue; % Skip to next iteration if critical step fails
        end

        % Remove epochs with railing
        try
            [data, valid_epochs, removed_epochs] = removeEpochswRailing(data, detected_peaks, fs);
        catch ME
            disp(['Failed to remove epochs with railing for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'removeEpochswRailing';
        end

        % 1. Extract the PPG signal geometric features from Speaks and Opoints
        try
            features_table1 = extractPPGSignalFeatures(data, detected_peaks, detected_onsets, fs);
            merged_features_table = [merged_features_table, features_table1];
        catch ME
            disp(['Failed to extract PPG Signal Features for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGSignalFeatures';
        end
        
       
        % Get apeaks, bpeaks, epeaks
        try
        [a_peaks_epochs, b_peaks_epochs, e_peaks_epochs] = detectABEpeaks(data, detected_peaks, detected_onsets, fs);
        
        catch ME
            disp(['Failed to detect apeaks, bpeaks, epeaks for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'detectABEpeaks';
        end

        % 2. Extract APG features
      
        try
            features_table2 = extractAPGFeatures(data, a_peaks_epochs, b_peaks_epochs, e_peaks_epochs);
            merged_features_table = [features_table1, features_table2]; % Merge the PPG & APG features tables
        catch ME
            disp(['Failed to extract APG features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractAPGFeatures';
        end

        % 3. Extract time-domain PPG features      
        try
            features_table3 = extractPPGTDFeatures(data, detected_peaks, detected_onsets, fs);
            merged_features_table = [merged_features_table, features_table3];
        catch ME
            disp(['Failed to extract PPG TD features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGTDFeatures';
        end

        % 4. Extract frequency-domain PPG features      
        try
            features_table4 = extractPPGFDFeatures(data, fs);
            merged_features_table = [merged_features_table, features_table4];
        catch ME
            disp(['Failed to extract PPG FD features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGFDFeatures';
        end

        % 5. Extract PPG wavelet transform features      
        try
            features_table5 = extractPPGWTF(data, fs);
            merged_features_table = [merged_features_table, features_table5];
        catch ME
            disp(['Failed to extract PPG wavelet transform features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGWTF';
        end

        % 6. Extract PPG IMF features      
        try
            features_table6 = extractPPGIMFFeatures(data, fs);
            merged_features_table = [merged_features_table, features_table6];
        catch ME
            disp(['Failed to extract PPG IMF features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGIMFFeatures';
        end

        % 7. Extract PPI TD features   
        try
            features_table7 = extractPPITDFeatures(data, detected_peaks, fs);
            merged_features_table = [merged_features_table, features_table7];
        catch ME
            disp(['Failed to extract PPI TD features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPITDFeatures';
        end

         % 8. Extract PPI FD features   
        try
            features_table8 = extractPPIfdFeatures(data, detected_peaks, fs);
            merged_features_table = [merged_features_table, features_table8];
        catch ME
            disp(['Failed to extract PPI FD features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPIfdFeatures';
        end

        % 9. Extract PPI visibility graph features  
        try
            features_table9 = extractPPIvgFeatures(data, detected_peaks, fs);
            merged_features_table = [merged_features_table, features_table9];
        catch ME
            disp(['Failed to extract PPI visibility graph features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPIvgFeatures';
        end

        % 10. Extract PPI entropy features  
        try
            features_table10 = extractPPIEntropyFeatures(data, detected_peaks, fs);
            merged_features_table = [merged_features_table, features_table10]; 
        catch ME
            disp(['Failed to extract PPI entropy features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPIEntropyFeatures';
        end

        % 11. Extract PPI detrended fluctuation analysis measures and
        % related features
        try
            features_table11 = extractPPIdfaFeatures(data, detected_peaks, fs);
            merged_features_table = [merged_features_table, features_table11];
        catch ME
            disp(['Failed to extract PPI dfa features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPIdfaFeatures';
        end

        % 12. Extract the PPG entropy features
        try
            features_table12 = extractPPGEntropyFeatures(data, fs);
            merged_features_table = [merged_features_table, features_table12];
        catch ME
            disp(['Failed to extract PPG Entropy Features for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGEntropyFeatures';
        end

        % 13. Extract the RR and DET features
        try
            features_table13 = extractPPGRRandDET(data, fs);
            merged_features_table = [merged_features_table, features_table13];
        catch ME
            disp(['Failed to extract PPG RR and DET Features for file: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGRRandDETFeatures';
        end

        % 14. Extract PPG Lyapunov Exponent, Higuchi and Katz fractal dimension measures features.
        % related features
        try
            features_table14 = extractPPGLcHfdKfdFeatures(data, fs);
            merged_features_table = [merged_features_table, features_table14];
        catch ME
            disp(['Failed to extract PPG LC features: ', fileName, ' Error: ', ME.message]);
            featuresFailedForFile{end+1} = 'extractPPGlcFeatures';
        end


        % Save the resulting table to a CSV file if any feature extraction was successful
        if ~isempty(merged_features_table)
            outputFilePath = fullfile(outputFolder, replace(fileName, '.csv', '_features.csv'));
            writetable(merged_features_table, outputFilePath);
            disp(['Processed file: ', fileName]);
        else
            disp(['No features extracted for file: ', fileName]);
        end
    catch ME
        disp(['Failed to process file: ', fileName, ' Error: ', ME.message]);
        failedFiles{end+1} = fileName; % Keep track of failed files
    end

    % Log files and their failed features
    if ~isempty(featuresFailedForFile)
        failedFeatures{end+1} = {fileName, featuresFailedForFile};
    end
end


% Display failed files
if ~isempty(failedFiles)
    disp('Failed files:');
    disp(failedFiles);
end

% Display files with failed features
if ~isempty(failedFeatures)
    disp('Files with failed features:');
    disp(failedFeatures);
end
