function [a_peaks_epochs, b_peaks_epochs, e_peaks_epochs] = detectABEpeaks(data, detected_peaks, detected_onsets, fs)
    % Detect a, b and e points
    % Inputs:
    %   data - Matrix of PPG signal data, with each column representing an epoch (first row contains labels)
    %   detected_peaks - Cell array containing detected peaks for each epoch
    %   detected_onsets - Cell array containing detected onsets for each epoch
    %   fs - Sampling rate of the PPG signal
    % Outputs:
    %   a_peaks_epochs - Cell array containing detected a peaks for each epoch
    %   b_peaks_epochs - Cell array containing detected b peaks for each epoch
    %   e_peaks_epochs - Cell array containing detected e peaks for each epoch
    % Notes:
    %   This function relies on accurate peak and onset detection as prerequisites.
    %   It uses the second derivative of the PPG signal to find points where the slope changes
    %   markedly, corresponding to physiological landmarks in the PPG waveform.

    num_epochs = size(data, 2);
    a_peaks_epochs = cell(1, num_epochs);
    b_peaks_epochs = cell(1, num_epochs);
    e_peaks_epochs = cell(1, num_epochs);

    for epoch = 1:num_epochs
        % Extract the PPG signal for the current epoch, excluding the label row
        ppgSignal = data(2:end, epoch);  
        
        % Retrieve S_peaks and O_points for the current epoch
        S_peaks = detected_peaks{epoch};
        O_points = detected_onsets{epoch};

        % Compute the first and second derivatives of the PPG signal
        diff1 = diff(ppgSignal);
        diff2 = diff(diff1);

        % Initialize arrays to store indices of a, b, and e peaks for this epoch
        a_peaks = zeros(size(S_peaks));
        b_peaks = zeros(size(S_peaks));
        e_peaks = zeros(size(S_peaks));
        
        for i = 1:length(S_peaks)
            if i > length(O_points)
                break; % Ensure we do not exceed the length of O_points
            end
            
            % a_peaks detection, ensuring segment length > 2
            if S_peaks(i) - O_points(i) > 2
                segment = diff2(O_points(i):S_peaks(i));
                [~, locs] = findpeaks(segment, 'NPeaks', 1, 'SortStr', 'descend'); % Use findpeaks to identify the most prominent peak within this segment. 'SortStr', 'descend' sorts peaks by amplitude in descending order, 'NPeaks', 1 restricts the output to the single highest peak.
                if ~isempty(locs)
                    a_peaks(i) = locs(1) + O_points(i) - 1;
                else
                    a_peaks(i) = NaN;
                end
            else
                a_peaks(i) = NaN;
            end
            
            % b_peaks detection, ensuring segment length > 2
            if ~isnan(a_peaks(i)) && S_peaks(i) - a_peaks(i) > 2
                segment = -diff2(a_peaks(i):S_peaks(i));
                [~, locs] = findpeaks(segment, 'NPeaks', 1, 'SortStr', 'descend');
                if ~isempty(locs)
                    b_peaks(i) = locs(1) + a_peaks(i) - 1; % locs(1) gives the index within 'segment', so adding a_peaks(i) - 1 adjusts it to the full signal's indexing.
                else
                    b_peaks(i) = NaN;
                end
            else
                b_peaks(i) = NaN;
            end
        end
    
        % e_peaks detection, handling all but the last b_peak within the loop
        for j = 1:length(b_peaks)-1  % Loop through all b_peaks except the last one to avoid exceeding array bounds.
            if ~isnan(b_peaks(j)) && (a_peaks(j+1) - b_peaks(j) > 2) % Check if the current b_peak is valid (not NaN) and there is a sufficient distance to the next a_peak.
                segment = diff2(b_peaks(j):a_peaks(j+1)); % This segment starts from the current b_peak and extends to the next a_peak
                [~, locs] = findpeaks(segment, 'SortStr', 'descend', 'NPeaks', 1);
                if ~isempty(locs)
                    e_peaks(j) = locs(1) + b_peaks(j) - 1; % locs(1) gives the index within 'segment', so adding b_peaks(j) - 1 adjusts it to the full signal's indexing.
                else
                    e_peaks(j) = NaN;
                end
            else
                e_peaks(j) = NaN;
            end
        end
        
        % e_peaks detection, handling the last b_peak
        if ~isnan(b_peaks(end))
            % If there's no next a_peak, define an endpoint for the search. 
            % This could be the end of the signal or a fixed distance after the last b_peak.
            searchEnd = min(length(diff2), b_peaks(end) + fs * 0.5); % Example: Search up to half a second after the last b_peak
            segment = diff2(b_peaks(end):searchEnd);
            [~, locs] = findpeaks(segment, 'SortStr', 'descend', 'NPeaks', 1);
            if ~isempty(locs)
                e_peaks(end) = locs(1) + b_peaks(end) - 1;
            else
                e_peaks(end) = NaN;
            end
        else
            e_peaks(end) = NaN;
        end
        
        % Ensure there's no index with a value of 0
        e_peaks(e_peaks == 0) = NaN; % Replace any 0 index with NaN, if necessary
    
        % Clean up the peaks to ensre e_peak is not higher than a_peak
        for i = 1:length(a_peaks)
            if isnan(a_peaks(i)) || isnan(b_peaks(i)) || isnan(e_peaks(i))
                % If any peak is NaN, continue to the next iteration
                continue;
            end
        
            % Check if e_peak amplitude is higher than a_peak amplitude
            if diff2(e_peaks(i)) > diff2(a_peaks(i))
                % Mark them as NaN
                a_peaks(i) = NaN;
                b_peaks(i) = NaN;
                e_peaks(i) = NaN;
            end
        end
                
        % After detecting a_peaks, b_peaks, and e_peaks, apply the filter
        valid_indices = ~isnan(a_peaks) & ~isnan(b_peaks) & ~isnan(e_peaks);
        a_peaks_filtered = a_peaks(valid_indices);
        b_peaks_filtered = b_peaks(valid_indices);
        e_peaks_filtered = e_peaks(valid_indices);
        
        % Now store the filtered values
        a_peaks_epochs{epoch} = a_peaks_filtered;
        b_peaks_epochs{epoch} = b_peaks_filtered;
        e_peaks_epochs{epoch} = e_peaks_filtered;
    end
end
