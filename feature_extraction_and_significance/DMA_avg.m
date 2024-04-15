function FDMA_avg = DMA_avg(PPI, scales)
    % DMA_avg calculates the Detrended Moving Average (DMA) over multiple scales for Peak-to-Peak Interval (PPI) data.
    % DMA is a method used to analyze the scaling properties of a time series by detrending the data with a moving average and analyzing the variance of the residuals.
    %
    % Inputs:
    %   PPI - The array of Peak-to-Peak Intervals derived from PPG signals.
    %   scales - An array of integers defining the window sizes over which the moving average is computed.
    %
    % Outputs:
    %   FDMA_avg - The average of DMA values computed across all specified scales, providing a single measure of complexity across different scales.
    
    % Calculate the length of the PPI array
    N = length(PPI);

    % Calculate the cumulative sum of the PPI series centered by subtracting the mean
    Y = cumsum(PPI - mean(PPI));
    
    % Preallocate the array to store DMA values for each scale
    FDMA = zeros(length(scales), 1);
    
    % Loop through each scale, compute DMA
    for idx = 1:length(scales)
        n = scales(idx);
        % Compute the moving average of the series
        movingAverage = movmean(Y, [n-1, 0], 'Endpoints', 'discard');
        % Calculate the residuals after subtracting the moving average from the cumulative sum
        Dn = Y((n:end)) - movingAverage;
        % Calculate the root mean square of the residuals to quantify the variability at this scale
        FDMA(idx) = sqrt(mean(Dn.^2));
    end
    
    % Calculate the average of the DMA values across all scales to provide a single complexity measure
    FDMA_avg = mean(FDMA);
end
