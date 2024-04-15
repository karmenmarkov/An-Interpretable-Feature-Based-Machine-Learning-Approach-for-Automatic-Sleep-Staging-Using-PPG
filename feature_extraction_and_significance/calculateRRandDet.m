function [RP, RR, DET] = calculateRRandDet(epochData, epsilon, l_min)
    % Calculates the Recurrence Plot (RP), Recurrence Rate (RR),
    % and Determinism (DET) of a given epoch of time-series data.
    
    % Inputs:
    %   epochData - A vector containing the epoch of time-series data.
    %   epsilon - A threshold distance below which points are considered recurrent.
    %   l_min - The minimum length of diagonal lines considered for DET calculation.
    
    % Outputs:
    %   RP - The Recurrence Plot matrix.
    %   RR - The Recurrence Rate, indicating the proportion of recurrent points.
    %   DET - The Determinism, representing the predictability of the time-series data.

    N = length(epochData); % Define N based on the length of epochData.
    RP = zeros(N); % Initialize the Recurrence Plot matrix with zeros.
    
    % Fill the RP matrix based on the condition.
    for i = 1:N
        for j = 1:N
            % If the distance between points is less than or equal to epsilon,
            % mark it as 1 (recurrent), else it remains 0 (non-recurrent).
            RP(i, j) = norm(epochData(i) - epochData(j)) <= epsilon;
        end
    end

    % Calculate Recurrence Rate (RR) as the ratio of recurrent points
    % to the total number of points in the RP matrix.
    RR = sum(RP(:)) / (N^2);

    % Calculate Determinism (DET) using a helper function.
    % 'l_min' is the minimum diagonal line length to be considered; it needs to be defined.
    DET = calculateDet(RP, l_min);
end

function DET = calculateDet(RP, l_min)
    % Initialize the size of the RP matrix to determine the range of diagonals.
    N = size(RP, 1);

    % Initialize counters for the total number of points on valid diagonals and the total points on all diagonals.
    validDiagonalPoints = 0; % Points on valid diagonals
    totalDiagonalPoints = 0; % Total points on all diagonals

    % Iterate through each diagonal of the RP matrix. 
    % The offset defines the diagonal being processed, ranging from the bottom-left to the top-right of the matrix.
    for offset = -N+1:N-1
        diagLine = diag(RP, offset); % Extract the current diagonal line from the RP matrix.
        startIdx = []; % Start indices of diagonals

         % Loop through the elements of the diagonal line to identify diagonals.
        for i = 2:length(diagLine)
            % Detect the start of a diagonal when the current point is 1 (recurrent)
            % and the previous point is 0 (non-recurrent).
            if diagLine(i) == 1 && diagLine(i-1) == 0
                startIdx = [startIdx, i];
            % Detect the end of a diagonal when the current point is 0 (non-recurrent)
            % and the previous point is 1 (recurrent), provided that a start was previously identified.
            elseif diagLine(i) == 0 && diagLine(i-1) == 1 && ~isempty(startIdx)
                diagLength = i - startIdx(end);

                % If the diagonal length is greater than or equal to the minimum length,
                % it's considered a valid diagonal, and its length is added to the count.
                if diagLength >= l_min
                    validDiagonalPoints = validDiagonalPoints + diagLength;
                end

                % Regardless of its validity, the diagonal length is added to the total count.
                totalDiagonalPoints = totalDiagonalPoints + diagLength;
                startIdx(end) = []; % Remove processed start index
            end
        end
        % Check for a diagonal that reaches to the end of diagLine
        if ~isempty(startIdx)
            diagLength = length(diagLine) + 1 - startIdx(end);
            if diagLength >= l_min
                validDiagonalPoints = validDiagonalPoints + diagLength;
            end
            totalDiagonalPoints = totalDiagonalPoints + diagLength;
        end
    end

    % Calculate DET as the ratio of valid diagonal points to total diagonal points,
    % ensuring no division by zero occurs.
    if totalDiagonalPoints == 0
        DET = 0; % Avoid division by zero
    else
        DET = validDiagonalPoints / totalDiagonalPoints;
    end
end
