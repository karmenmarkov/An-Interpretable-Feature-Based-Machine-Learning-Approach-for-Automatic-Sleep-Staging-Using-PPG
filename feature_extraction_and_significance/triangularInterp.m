function [tinn, triangular_index] = triangularInterp(PPI, bin_width)

    % Calculates the Triangular Interpolation of NN Interval Histogram (TINN) and triangular index from PPI data.
    % TINN is used to measure the baseline width of the histogram of the NN intervals (peak-to-peak intervals),
    % providing a measure of the HRV. The triangular index is a ratio used to assess the regularity of the heart rate.
    %
    % Inputs:
    %   PPI - Array of peak-to-peak intervals, typically derived from PPG or ECG data, in milliseconds.
    %   bin_width - Optional; the width of the histogram bins used to calculate TINN. If not specified,
    %              a default value based on typical heart rate sampling frequency is used.
    % Outputs:
    %   tinn - Triangular Interpolation of NN Interval Histogram, a measure of the base of the histogram triangle.
    %   triangular_index - A ratio representing the total number of intervals divided by the height of the histogram's mode.
    %


    % Check if bin_width is specified, otherwise set a default based on PPI assumed to be in milliseconds
    if nargin < 2 || isempty(bin_width) || bin_width <= 0
        bin_width = 1000 / 128; % Default positive bin width
    end

    % Calculate the histogram of the PPI data using specified bin width
    h = histcounts(PPI, 'BinWidth', bin_width);
    bin_edges = linspace(min(PPI), max(PPI), length(h) + 1); % Calculate bin edges for histogram

    % Identify the bin with the maximum count (mode of the histogram)
    X = find(h == max(h), 1); % Index of the mode in histogram
    mode_bin_center = (bin_edges(X) + bin_edges(X+1)) / 2; % Center value of the mode bin

    % Initialize search parameters
    N = 1; % Start of the triangular base
    M = length(h); % End of the triangular base
    min_n_fit = inf; % Minimum error for N side of the triangle
    min_m_fit = inf; % Minimum error for M side of the triangle

    % Optimize N by iterating over possible values before the mode
    for n = 1:(X-1)
        % Calculate fit error if using current bin as start of triangle base
        current_n_fit = sum((interp1([bin_edges(n) mode_bin_center], [0 max(h)], bin_edges(n:X)) - h(n:X)).^2) + sum(h(1:n-1).^2);
        % Update N if this configuration minimizes the error
        if current_n_fit < min_n_fit
            N = n;
            min_n_fit = current_n_fit;
        end
    end

    % Optimize M by iterating over possible values after the mode
    for m = (X+1):length(bin_edges)-1
        % Calculate fit error if using current bin as end of triangle base
        current_m_fit = sum((interp1([mode_bin_center bin_edges(m)], [max(h) 0], bin_edges(X:m)) - h(X:m)).^2) + sum(h(m+1:end).^2);
        % Update M if this configuration minimizes the error
        if current_m_fit < min_m_fit
            M = m;
            min_m_fit = current_m_fit;
        end
    end

    % Calculate TINN as the base of the triangle in milliseconds
    tinn = (bin_edges(M+1) - bin_edges(N)) * 1000; % Includes the endpoint of the Mth bin

    % Calculate the Triangular Index
    total_intervals = sum(h); % Total count of PPI intervals
    max_bin_count = max(h); % Maximum count in any histogram bin
    triangular_index = total_intervals / max_bin_count; % Triangular Index calculation
end
