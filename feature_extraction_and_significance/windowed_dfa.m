function PPI_WDFA = windowed_dfa(PPI, window_size)
    % windowed_dfa calculates the Detrended Fluctuation Analysis (DFA) exponent in a sliding window approach across a PPI series.
    % This function provides insights into how DFA exponents change over the course of the PPI series, reflecting non-stationarities.
    %
    % Inputs:
    %   PPI - The array of Peak-to-Peak Intervals derived from PPG signals.
    %   window_size - The size of each sliding window for DFA calculation.
    %
    % Outputs:
    %   PPI_WDFA - The average DFA exponent computed across all windows.

    % Determine the number of windows that can slide across the length of PPI
    num_windows = length(PPI) - window_size + 1;

    % Preallocate array to store DFA exponents for each window
    alpha_values = zeros(num_windows, 1); % To store DFA exponents of each window

    % Perform DFA for each window and store the exponents
    for i = 1:num_windows
        window = PPI(i:i + window_size - 1);
        [~, ~, alpha] = generalDFA(window, 4:min([window_size, length(window)/2])); % Adjust scale range as needed
        alpha_values(i) = alpha;
    end

    % Calculate the mean of all DFA exponents to get a single value representing the windowed DFA
    PPI_WDFA = mean(alpha_values);
end
