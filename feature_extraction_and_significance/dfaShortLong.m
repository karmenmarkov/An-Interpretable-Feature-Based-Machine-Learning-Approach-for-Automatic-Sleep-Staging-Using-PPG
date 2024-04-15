function [PPI_DFA_short_exponent, PPI_DFA_long_exponent] = dfaShortLong(PPI)
    % dfaShortLong calculates Detrended Fluctuation Analysis (DFA) exponents for short-term and long-term scales.
    % This function is useful for identifying different correlation behaviors in small and large scale structures within PPI data.
    %
    % Inputs:
    %   PPI - The array of Peak-to-Peak Intervals derived from PPG signal.
    %
    % Outputs:
    %   PPI_DFA_short_exponent - DFA exponent calculated over short-term scales.
    %   PPI_DFA_long_exponent - DFA exponent calculated over long-term scales.
    
    % Define the range of scales for short-term and long-term analyses
    scalesShort = 3:4;
    scalesLong = 6:min([30, length(PPI)]);

    % Perform DFA on the defined short-term scales
    [~, ~, PPI_DFA_short_exponent] = generalDFA(PPI, scalesShort);
    [~, ~, PPI_DFA_long_exponent] = generalDFA(PPI, scalesLong);
end
