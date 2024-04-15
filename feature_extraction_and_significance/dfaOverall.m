function PPI_DFA = dfaOverall(PPI)
    % dfaOverall performs Detrended Fluctuation Analysis (DFA) over the entire range of scales feasible for the given PPI data.
    % This function calculates the overall DFA exponent which characterizes the correlation properties across the entire PPI series.
    %
    % Inputs:
    %   PPI - The array of Peak-to-Peak Intervals derived from PPG signal.
    %
    % Outputs:
    %   PPI_DFA - The overall DFA exponent calculated across a range of scales.
    
    % Define minimum and maximum scales based on the length of PPI
    minScale = 4;  
    maxScale = floor(length(PPI)/4);  

    % Determine the number of scales to use, spaced logarithmically
    numScales = min(30, maxScale - minScale + 1);
    scales = unique(floor(logspace(log10(minScale), log10(maxScale), numScales)));

    % Call the generalDFA function to compute DFA over the identified scale range
    [~, ~, PPI_DFA] = generalDFA(PPI, scales);
end
