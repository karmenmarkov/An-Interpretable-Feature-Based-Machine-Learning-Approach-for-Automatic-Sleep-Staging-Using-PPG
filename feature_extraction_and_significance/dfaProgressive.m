function PPI_PDFA_avg = dfaProgressive(PPI, segment_length)
    % dfaProgressive calculates the average Detrended Fluctuation Analysis (DFA) exponent across multiple segments of a PPI series.
    % This method helps in understanding the scaling behavior over smaller, progressive segments of the PPI data.
    %
    % Inputs:
    %   PPI - The array of Peak-to-Peak Intervals derived from PPG signals.
    %   segment_length - The length of each segment over which DFA is calculated.
    %
    % Outputs:
    %   PPI_PDFA_avg - The average DFA exponent computed across all segments.

    % Calculate the number of complete segments that can fit into the PPI array
    num_segments = floor(length(PPI) / segment_length);

     % Handle the case where the PPI array is too short to form even one segment
    if num_segments == 0
        PPI_PDFA_avg = NaN; % Handle case with not enough data for even one segment
        return;
    end
    
    % Preallocate array to hold DFA exponents for each segment
    DFA_exponents = zeros(num_segments, 1);
    
    % Define scales for DFA based on segment length
    minScale = 4;  
    maxScale = floor(segment_length / 2);  
    numScales = 10; % Number of logarithmically spaced scales
    scales = unique(floor(logspace(log10(minScale), log10(maxScale), numScales)));
    
    % Calculate DFA for each segment and store the results
    for i = 1:num_segments
        segment = PPI((i-1)*segment_length + 1:i*segment_length);
        [~, ~, DFA_exponents(i)] = generalDFA(segment, scales);
    end
    
    % Compute the average of DFA exponents across all segments
    PPI_PDFA_avg = mean(DFA_exponents, 'omitnan');
    
end
