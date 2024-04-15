function features_table = extractPPGSignalFeatures(data, detected_peaks, detected_onsets, fs)
    % Extract PPG signal geometric features
    %
    % Inputs:
    %   data - The PPG signal data, with each column representing an epoch.
    %   detected_peaks - A cell array where each cell contains the indices of detected S_peaks for each epoch.
    %   detected_onsets - A cell array where each cell contains the indices of detected O_peaks for each epoch.
    %   fs - The sampling rate of the PPG signal.
    %
    % Outputs:
    %   features_table - Table containing the calculated features for each epoch
    %
    % Dependency:
    %   Functions for peak and onset detection must be run prior to this analysis to provide `detected_peaks` and `detected_onsets`.
    %   MATLAB's Signal Processing Toolbox for functions like `trapz` used in integrating areas under the curve.
    %

    num_epochs = size(data, 2);  % Number of epochs
    features_all_epochs = [];  % To store features for all epochs

    for epoch = 1:num_epochs
        epochData = data(2:end, epoch);  % Assuming the first row is labels
        S_peaks = detected_peaks{epoch};
        O_peaks = detected_onsets{epoch};
        label = data(1, epoch); % Get label for current epoch

        % Calculate the systolic time (SysTime)
        t1_samples = S_peaks - O_peaks;
        SysTime = t1_samples / fs;
        SysTime_avg = mean(SysTime);
        SysTime_std = std(SysTime);
        
        % Calculate the systolic peak (SysPeak)
        SysPeak = epochData(S_peaks) - epochData(O_peaks);
        SysPeak_avg = mean(SysPeak);
        SysPeak_std = std(SysPeak);
    
        % Calculate systolic area (SysArea) from O_point to S_peak
        SysArea = arrayfun(@(o, p) trapz(epochData(o:p)), O_peaks, S_peaks);
        SysArea_avg = mean(SysArea);
        SysArea_std = std(SysArea);
    
        % Calculate absolute systolic area (SysArea) from O_point to S_peak
        SysArea_abs = arrayfun(@(o, p) trapz(abs(epochData(o:p)))/fs, O_peaks, S_peaks);
        SysArea_abs_avg = mean(SysArea_abs);
        SysArea_abs_std = std(SysArea_abs);
    
        % Calculate the slope
        slope = SysTime ./ SysPeak;
        slope_avg = mean(slope);
        slope_std = std(slope);
    
        % Calculate the total area
        total_area = trapz(abs(epochData))/fs; 
    
        % Calculate diastolic time (DiasTime)
        Time_falling = diff([O_peaks; length(epochData)]) / fs; % Time falling from peak to onset (to next O_point)
        DiasTime_avg = mean(Time_falling);
        DiasTime_std = std(Time_falling);
        
        % Calculate diastolic area (DiasArea) from S_peak to next O_point
        DiasArea = arrayfun(@(p, o) trapz(epochData(p:o)), S_peaks(1:end-1), O_peaks(2:end));
        DiasArea_avg= mean(DiasArea);
        DiasArea_std = std(DiasArea);
    
        % Calculate absolute diastolic area (DiasArea) from S_peak to next O_point
        DiasArea_abs = arrayfun(@(p, o) trapz(abs(epochData(p:o)))/fs, S_peaks(1:end-1), O_peaks(2:end));
        DiasArea_abs_avg= mean(DiasArea_abs);
        DiasArea_abs_std = std(DiasArea_abs);
    
        % Calculate cycle area (CycleArea) from O_point to next O_point
        CycleArea = arrayfun(@(o1, o2) trapz(epochData(o1:o2)), O_peaks(1:end-1), O_peaks(2:end));
        CycleArea_avg = mean(CycleArea);
        CycleArea_std = std(CycleArea);
    
        % Calculate absolute cycle area (CycleArea) from O_point to next O_point
        CycleArea_abs = arrayfun(@(o1, o2) trapz(abs(epochData(o1:o2)))/fs, O_peaks(1:end-1), O_peaks(2:end));
        CycleArea_abs_avg = mean(CycleArea_abs);
        CycleArea_abs_std = std(CycleArea_abs);
    
        % Calculate cycle duration (CycleDuration) from O_point to next O_point
        CycleDuration = diff([O_peaks; length(epochData)]) / fs;
        CycleDuration_avg = mean(CycleDuration);
        CycleDuration_std = std(CycleDuration);
    
        % Calculate the area from onset to half systolic peak on the negative
        % slope (Area_NegHalfPeak_FromStart) and from half systolic peak on the
        % negative slope to the end of the cycle (Area_NegHalfPeak_ToEnd)
        % Calculate half the amplitude difference for each peak
        half_peak_amplitudes = SysPeak / 2;
        target_amplitudes = epochData(O_peaks)+ half_peak_amplitudes;
    
        % Initialize arrays to store the areas and indices
        NegHalfPeak_Indices = zeros(size(S_peaks));
        Area_NegHalfPeak_FromStart = zeros(size(O_peaks));
        Area_NegHalfPeak_ToEnd = zeros(size(O_peaks));
        Area_NegHalfPeak_FromStart_abs = zeros(size(O_peaks)); % For absolute values
        Area_NegHalfPeak_ToEnd_abs = zeros(size(O_peaks)); % For absolute values
        
        % Loop through each peak to find the half amplitude index on the negative slope
        for i = 1:length(S_peaks)
            % Find the index where the signal crosses the target amplitude on the negative slope
            % Search from the peak to the next onset (or the end of the signal if it's the last peak)
            search_end_idx = length(epochData);
            if i < length(O_peaks)
                search_end_idx = O_peaks(i+1) - 1;  % Stop before the next onset
            end
            
            % The following finds the first point after the peak where the signal is less than or equal to
            % the target amplitude. 
            HalfPeak_Index_Neg = find(epochData(S_peaks(i):search_end_idx) <= target_amplitudes(i), 1, 'first') + S_peaks(i) - 1;
            
            if ~isempty(HalfPeak_Index_Neg)
                NegHalfPeak_Indices(i) = HalfPeak_Index_Neg;
                % Calculate areas under the curve
                Area_NegHalfPeak_FromStart(i) = trapz(epochData(O_peaks(i):HalfPeak_Index_Neg));
                Area_NegHalfPeak_ToEnd(i) = trapz(epochData(HalfPeak_Index_Neg:search_end_idx));
                % Calculate areas under the curve with absolute values and accounting for sampling rate
                Area_NegHalfPeak_FromStart_abs(i) = trapz(abs(epochData(O_peaks(i):HalfPeak_Index_Neg))) / fs;
                Area_NegHalfPeak_ToEnd_abs(i) = trapz(abs(epochData(HalfPeak_Index_Neg:search_end_idx))) / fs;
    
            else
                % If there is no crossing point found, you might want to handle this case, e.g., set to NaN or some default
                NegHalfPeak_Indices(i) = NaN;
                Area_NegHalfPeak_FromStart(i) = NaN;
                Area_NegHalfPeak_ToEnd(i) = NaN;
            end
        end
        
        % Calculate the mean and standard deviation of the areas
        Area_NegHalfPeak_FromStart_avg = nanmean(Area_NegHalfPeak_FromStart);
        Area_NegHalfPeak_FromStart_std = nanstd(Area_NegHalfPeak_FromStart);
        Area_NegHalfPeak_ToEnd_avg = nanmean(Area_NegHalfPeak_ToEnd);
        Area_NegHalfPeak_ToEnd_std = nanstd(Area_NegHalfPeak_ToEnd);
        Area_NegHalfPeak_FromStart_abs_avg = nanmean(Area_NegHalfPeak_FromStart_abs);
        Area_NegHalfPeak_FromStart_abs_std = nanstd(Area_NegHalfPeak_FromStart_abs);
        Area_NegHalfPeak_ToEnd_abs_avg = nanmean(Area_NegHalfPeak_ToEnd_abs);
        Area_NegHalfPeak_ToEnd_abs_std = nanstd(Area_NegHalfPeak_ToEnd_abs);
    
        % Rise time from halved peak on positive slope to Speak
        % Preallocate array for rise times
        RiseTime_FromHalfPeak = zeros(size(S_peaks));
        
        % Loop through each S_peak
        for i = 1:length(S_peaks)
            % We have already calculated the target amplitudes.
            
            % Find the indices where the signal reaches half amplitude on the positive slope. Start searching from the onset to the peak
            HalfPeak_Index_Pos = find(epochData(O_peaks(i):S_peaks(i)) >= target_amplitudes(i), 1, 'first') + O_peaks(i) - 1;
            
            if isempty(HalfPeak_Index_Pos)
                RiseTime_FromHalfPeak(i) = NaN; % Handle cases where no index is found
            else
                % Calculate the rise time from the halved peak to the actual systolic peak
                RiseTime_FromHalfPeak(i) = (S_peaks(i) - HalfPeak_Index_Pos) / fs;
            end
        end
    
        RiseTime_FromHalfPeak_avg = mean(RiseTime_FromHalfPeak);
        RiseTime_FromHalfPeak_std = std(RiseTime_FromHalfPeak);
        
        % Fall time from Speak to half peak on the negative slope
        FallTime_FromSpeak = zeros(size(S_peaks));
        
        % Loop through each S_peak
        for i = 1:length(S_peaks)
            % Check if the negative half peak index is valid
            if ~isnan(NegHalfPeak_Indices(i))
                % Calculate the fall time from the S_peak to the negative half peak
                FallTime_FromSpeak(i) = (NegHalfPeak_Indices(i) - S_peaks(i)) / fs;
            else
                FallTime_FromSpeak(i) = NaN; % Mark as NaN if the half peak on negative slope is not found
            end
        end
        
        FallTime_Half_avg = nanmean(FallTime_FromSpeak);
        FallTime_Half_std = nanstd(FallTime_FromSpeak);
    
        % Calculate the width at halved systolic peaks as duration
        Width_Half_Duration = RiseTime_FromHalfPeak + FallTime_FromSpeak;
        Width_Half_Duration_avg = nanmean(Width_Half_Duration);
        Width_Half_Duration_std = nanstd(Width_Half_Duration);
    
        % Calculate the width at the top of Speak at 90% amplitude as duration
        % Calculate the target amplitude for 10% width
        target_amplitude_10_percent = epochData(O_peaks) + 0.9 * SysPeak;
        
        % Initialize arrays to store the indices and width
        Indices_10_Percent_Width = zeros(size(S_peaks, 1), 2); % Two columns for start and end indices
        Width_10_Percent = zeros(size(S_peaks));
        
        % Loop through each S_peak
        for i = 1:length(S_peaks)
            % Find the index before the peak where the signal drops below 10% target amplitude
            index_before_peak = find(epochData(O_peaks(i):S_peaks(i)) <= target_amplitude_10_percent(i), 1, 'last') + O_peaks(i) - 1;
            
            % Find the index after the peak where the signal drops below 10% target amplitude
            search_end_idx = length(epochData);
            if i < length(O_peaks)
                search_end_idx = O_peaks(i+1) - 1; % Stop before the next onset
            end
            index_after_peak = find(epochData(S_peaks(i):search_end_idx) <= target_amplitude_10_percent(i), 1, 'first') + S_peaks(i) - 1;
            
            % Store the indices
            if ~isempty(index_before_peak) && ~isempty(index_after_peak)
                Indices_10_Percent_Width(i, :) = [index_before_peak, index_after_peak];
                % Calculate the width in samples
                Width_10_Percent(i) = index_after_peak - index_before_peak;
            else
                % Handle cases where no index is found
                Indices_10_Percent_Width(i, :) = [NaN, NaN];
                Width_10_Percent(i) = NaN;
            end
        end
    
        % Convert the width in samples to time (seconds)
        Width_10_Percent_Time = Width_10_Percent / fs;
        Width_10_Percent_Time_avg = nanmean(Width_10_Percent_Time);
        Width_10_Percent_Time_std = nanstd(Width_10_Percent_Time);
        
        % Time between systolic peaks
        Time_Between_SysPeaks = diff(S_peaks) / fs;
        Time_Between_SysPeaks_avg = mean(Time_Between_SysPeaks);
        Time_Between_SysPeaks_std = std(Time_Between_SysPeaks);

        % Since Time_Between_SysPeaks has one less value than the number of peaks (diff reduces length by 1),
        % adjust SysTime to have the same number of elements for a direct comparison.
        SysTime_adj = SysTime(1:end-1); % Adjusting the length
        
        % Calculate T1/T ratio using adjusted SysTime and Time_Between_SysPeaks
        RiseTime_TimeBetweenSysPeaks_ratio = SysTime_adj ./ Time_Between_SysPeaks;
        RiseTime_TimeBetweenSysPeaks_Mean = mean(RiseTime_TimeBetweenSysPeaks_ratio);
        RiseTime_TimeBetweenSysPeaks_SD = std(RiseTime_TimeBetweenSysPeaks_ratio);

        % Autonomic nervous system state

        ANSS = zeros(1, length(S_peaks) - 1);
        
        for i = 1:length(S_peaks)-1
            % Calculate PPI in milliseconds
            PPI = (S_peaks(i+1) - S_peaks(i)) / fs * 1000; % Time between peaks in ms
            
            % Calculate PPGA 
            % Correctly calculate the systolic peak for the current pulse
            SysPeak_current = epochData(S_peaks(i)) - epochData(O_peaks(i)); % Current systolic peak
            PPGA = (SysPeak_current / SysPeak_avg) * 100; % Amplitude as a percentage for the current pulse
         
            % Calculate ANSS
            ANSS(i) = PPI * PPGA;
        end
       
        % Assuming ANSSmax as the maximum ANSS value in the current epoch
        ANSSmax = max(ANSS);
        
        % Calculate ANSSi for each ANSS value
        ANSSi = 100 - (ANSS / ANSSmax) * 90;

        % ANSS Mean and SD for the current epoch
        ANSS_Mean = mean(ANSS);
        ANSS_SD = std(ANSS);
        
        % ANSSi mean and SD 
        ANSSi_Mean = mean(ANSSi);
        ANSSi_SD = std(ANSSi);

        % Calculate PWV for the current epoch
        if ~isempty(SysPeak) % Ensure there are systolic peaks to avoid division by zero
            PPG_PWV = (max(SysPeak) - min(SysPeak)) / ((max(SysPeak) + min(SysPeak)) / 2);
        else
            PPG_PWV = NaN; % Handle epochs without detected peaks appropriately
        end


        % Collect all features in a vector for the current epoch
        feature_values = [label, SysTime_avg, SysTime_std, SysPeak_avg, SysPeak_std, SysArea_avg, SysArea_std, SysArea_abs_avg, SysArea_abs_std, slope_avg, slope_std, total_area, DiasTime_avg, DiasTime_std, DiasArea_avg, DiasArea_std, DiasArea_abs_avg, DiasArea_abs_std, CycleArea_avg, CycleArea_std, CycleArea_abs_avg, CycleArea_abs_std, CycleDuration_avg, CycleDuration_std, Area_NegHalfPeak_FromStart_avg, Area_NegHalfPeak_FromStart_std, Area_NegHalfPeak_FromStart_abs_avg, Area_NegHalfPeak_FromStart_abs_std, Area_NegHalfPeak_ToEnd_avg, Area_NegHalfPeak_ToEnd_std, Area_NegHalfPeak_ToEnd_abs_avg, Area_NegHalfPeak_ToEnd_abs_std, RiseTime_FromHalfPeak_avg, RiseTime_FromHalfPeak_std, FallTime_Half_avg, FallTime_Half_std, Width_Half_Duration_avg, Width_Half_Duration_std, Width_10_Percent_Time_avg, Width_10_Percent_Time_std, Time_Between_SysPeaks_avg, Time_Between_SysPeaks_std, RiseTime_TimeBetweenSysPeaks_Mean, RiseTime_TimeBetweenSysPeaks_SD, ANSS_Mean, ANSS_SD, ANSSi_Mean, ANSSi_SD, PPG_PWV];
        
        % Append calculated features for the current epoch to the features_all_epochs array
        features_all_epochs = [features_all_epochs; feature_values];
    end

    % Convert the features_all_epochs array to a table for better readability
    features_table = array2table(features_all_epochs, 'VariableNames', {'Label','SysTime_avg', 'SysTime_std', 'SysPeak_avg', 'SysPeak_std', 'SysArea_avg', 'SysArea_std', 'SysArea_abs_avg', 'SysArea_abs_std', 'Slope_avg', 'Slope_std', 'TotalArea', 'DiasTime_avg', 'DiasTime_std', 'DiasArea_avg', 'DiasArea_std', 'DiasArea_abs_avg', 'DiasArea_abs_std', 'CycleArea_avg', 'CycleArea_std', 'CycleArea_abs_avg', 'CycleArea_abs_std', 'CycleDuration_avg', 'CycleDuration_std', 'Area_NegHalfPeak_FromStart_avg', 'Area_NegHalfPeak_FromStart_std', 'Area_NegHalfPeak_FromStart_abs_avg', 'Area_NegHalfPeak_FromStart_abs_std','Area_NegHalfPeak_ToEnd_avg', 'Area_NegHalfPeak_ToEnd_std','Area_NegHalfPeak_ToEnd_abs_avg', 'Area_NegHalfPeak_ToEnd_abs_std', 'RiseTime_FromHalfPeak_avg', 'RiseTime_FromHalfPeak_std', 'FallTime_Half_avg', 'FallTime_Half_std', 'Width_Half_Duration_avg', 'Width_Half_Duration_std', 'Width_10_Percent_Time_avg','Width_10_Percent_Time_std', 'Time_Between_SysPeaks_avg', 'Time_Between_SysPeaks_std', 'RiseTime_TimeBetweenSysPeaks_Mean', 'RiseTime_TimeBetweenSysPeaks_SD', 'ANSS_Mean', 'ANSS_SD', 'ANSSi_Mean', 'ANSSi_SD', 'PPG_PWV'});

end