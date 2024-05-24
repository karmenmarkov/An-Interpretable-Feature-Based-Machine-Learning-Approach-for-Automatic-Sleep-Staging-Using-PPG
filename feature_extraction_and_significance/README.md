# Feature extraction and significance
The following section details the systematic methods employed for extracting significant features from Photoplethysmogram (PPG) data. These features are pivotal for further applications in sleep stage classification. The significance analysis ensures that the features used in predictive models are statistically relevant.

![github2](https://github.com/kmarkoveth/PPG/assets/103241042/98094b6d-f65e-4c03-977e-2670e28568db)

## Main function
### [ExtractAllFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/ExtractAllFeatures.m)
* **Purpose**: Automates extraction of diverse physiological and statistical features from PPG data, essential for sleep stage classification and health monitoring.
* **Inputs**:
  * Directory with preprocessed and cleaned PPG data in .csv format.
* **Outputs**:
  * `featuresTable` - A comprehensive dataset with extracted features for each epoch.
  * Processed `.csv` files - Ready for analysis or machine learning model integration.
  * Log of failed files - Documenting any epochs that could not be processed.
* **Process**:
  * Temporal dynamics from PPG waveforms.
  * Spectral content via frequency and wavelet analyses.
  * Heart rate variability metrics from PPI analysis.
  * Complexity and regularity from entropy calculations.
  * Structural insights through graph-based metrics.
* **Dependencies**:
  * MATLAB (R2021a or later recommended)
  * Signal Processing Toolbox
  * Statistics and Machine Learning Toolbox
  * Custom MATLAB Functions: A suite of specialized functions developed to extract each set of features. 
* **Instructions**:
  * Ensure the script and all custom function scripts are in the MATLAB path.
  * Place preprocessed .csv data files in the specified input directory.
  * Execute the script from MATLAB command window or editor to process data and generate features.

## Sub-functions
The suite of functions and scripts listed below encompasses a comprehensive framework for extracting features across multiple dimensions - temporal, spectral, and non-linear, among others in the context of sleep staging. 

### [detectPeaksOnsets.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/detectPeaksOnsets.m)
* **Purpose**: Detects peaks and onsets in PPG signal data using the `MSPTD` beat detector from the PPG_Beats toolbox. Essential for preprocessing PPG signals in preparation for further analysis or feature extraction.
* **Inputs**:
  *  `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  *  `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  *  `detected_peaks` - Cell array containing detected peaks for each epoch.
  *  `detected_onsets` - Cell array containing detected onsets for each epoch.
  *  `clean_data` - Filtered data matrix including only epochs where peaks and onsets were successfully detected.
  *	 `valid_epochs_index` - Indices of epochs that were successfully processed.
* **Process**: 
  * Utilizes the MSPTD algorithm from the PPG_Beats toolbox for peak and onset detection.
  * Handles PPG signal noise effectively to identify physiologically relevant features:
    * Systolic peaks representing maximum blood volume during a cardiac cycle.
    * Onset points marking the beginning of the systolic upstroke.
  * Adapts to various data acquisition speeds by considering the signal's sampling rate.
  * Incorporates robust error handling:
  * Uses a try-catch mechanism to prevent process termination from transient errors.
  * Continues analysis when no peaks or onsets are detected, ensuring the process is not halted for subsequent epochs.
  * Provides feedback for undetected peaks or onsets to aid in debugging.
*	**Dependencies**: Requires the [PPG_Beats toolbox](https://ppg-beats.readthedocs.io/en/latest/).
*	**References**: Charlton PH et al., Detecting beats in the photoplethysmogram: benchmarking open-source algorithms, Physiological Measurement, 2022.

### [removeEpochswRailing.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/removeEpochswRailing.m)
* **Purpose**: Identifies and removes epochs with railing artifacts in PPG signal data. Railing is identified by the presence of peaks that are too close together, which are not physiologically plausible.
* **Inputs**:
  *	`data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  *	`detected_peaks` - Cell array containing detected peaks for each epoch
  *	`fs` - Sampling rate of the PPG signal.
* **Outputs**:
  *	`cleaned_data` - Data matrix excluding problematic epochs.
  *	`valid_epochs`- Logical array indicating whether each epoch is valid.
  *	`removed_epochs` - Indices of epochs removed due to railing.
* **Process**: 
  *	Examines the spacing between peaks within each PPG signal epoch to detect railing artifacts.
  *	Identifies problematic epochs as those with three or more peaks spaced fewer than a set minimum of data points apart (20).
  *	The threshold is based on the physiological unlikelihood of such rapid successive heartbeats as per the signal's sampling rate.
  *	Iteratively evaluates each epoch, utilizing a logical vector to maintain the status of epoch validity.
  *	Outputs a dataset cleansed of epochs with railing, ensuring only physiologically plausible data is retained for analysis.
  *	Provides an index of removed epochs to document any data exclusions and maintain transparency in data processing.

### [extractPPGSignalFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGSignalFeatures.m)
* **Purpose**: Extracts a variety of PPG signal geometric features crucial for detailed physiological analysis. The function computes features related to systolic and diastolic phases of the PPG signal, including times, peaks, areas, and derived ratios.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch
  * `detected_onsets` - Cell array containing detected onsets for each epoch.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `features_table` - A table containing the calculated features for each epoch, with columns for each feature including averages, standard deviations, and specific geometric calculations relevant to cardiovascular analysis.
* **Process**: 
  * Calculates systolic and diastolic durations by measuring the time intervals between detected peaks and onsets.
  * Determines peak amplitudes to identify the highest points of blood volume during the cardiac cycle.
  *	Integrates areas under the PPG curve using trapezoidal rule to estimate blood volume changes.
  *	Evaluates waveform asymmetries by comparing areas before and after systolic peaks.
  *	Computes regularity ratios to assess the consistency of PPG signal patterns.
  *	Compiles a comprehensive feature set, including averages and standard deviations, for sleep phase analysis.
* **Dependencies**: 
  * Functions for peak and onset detection must be run prior to this analysis to provide `detected_peaks` and `detected_onsets`.
  * MATLAB's Signal Processing Toolbox for functions like `trapz` used in integrating areas under the curve.

### [detectABEpeaks.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/detectABEpeaks.m)
*	**Purpose**: Automatically detects the a, b, and e points in the PPG waveform for each epoch. These points correspond to key physiological features in the blood volume pulse waveform: a_peaks (systolic upstroke), b_peaks (systolic peak), and e_peaks (early diastolic point).
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch
  * `detected_onsets` - Cell array containing detected onsets for each epoch.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  *	`a_peaks_epochs` - Indices of detected a points for each epoch, corresponding to the beginning of the systolic phase.
  *	`b_peaks_epochs` - Indices of detected b points for each epoch, typically the highest point of the systolic phase.
  *	`e_peaks_epochs` - Indices of detected e points for each epoch, marking the start of the diastolic rebound.
* **Process**:
  * Calculates the first and second derivatives of the PPG signal.
  * **a Point Detection**: Identifies the onset of systolic upstroke by finding the first significant peak in the second derivative post-pulse onset.
  * **b Point Detection**: Detects the systolic peak by locating the first significant negative peak after the a point in the second derivative.
  * **e Point Detection**: Determines the onset of diastolic deceleration by spotting the first significant positive peak following the b point in the second derivative.
  * **Iteration and Application**: Runs through each epoch, applying the above criteria within intervals demarcated by detected peaks and onsets.
  * **Peak Selection**: Utilizes MATLAB's findpeaks function to pinpoint the most prominent peaks corresponding to physiological markers.
  * **Filtering and Validation**: Ensures physiological plausibility by filtering out inconsistent a, b, and e point indices, such as e points with amplitudes higher than a points.
* **Dependencies**: 
  * This function depends on the accurate detection of peaks and onsets provided by preliminary processing steps.
  * MATLAB's Signal Processing Toolbox for differential and peak detection functions.

### [extractAPGFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractAPGFeatures.m)
* **Purpose**: Extracts key features from the APG (Accelerated Plethysmogram) waveform derived from PPG (Photoplethysmogram) data. The function focuses on deriving meaningful metrics from the relationships between the a, b, and e points in the waveform, which are critical for evaluating cardiovascular health and autonomic nervous system function.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `a_peaks_epochs` - Cell array of indices for a peaks (indicative of the onset of systolic upstroke).
  * `b_peaks_epochs` - Cell array of indices for b peaks (the systolic peak).
  * `e_peaks_epochs` - Cell array of indices for e peaks (early diastolic phase).
* **Outputs**:
  * `features_table` - A table containing aggregated features for each epoch, such as mean and standard deviation of the differences and ratios derived from the second derivatives at a, b, and e points.
* **Process**:
  * Iteratively processes each epoch of PPG data to extract meaningful APG features.
  * Computes first and second derivatives of the PPG signal for dynamic analysis.
  * Utilizes a_peaks, b_peaks, and e_peaks from prior detection to inform feature calculation.
  * Filters non-NaN values to maintain data consistency across calculations.
  * Determines differences and ratios between the a, b, and e points using second derivative values.
  * Calculates mean and standard deviation for difference and ratio features to capture signal characteristics.
  * Aggregates features for each epoch into a comprehensive table with descriptive variable names.
* **Dependencies**:
  * Proper execution of functions that provide `a_peaks_epochs`, `b_peaks_epochs`, and `e_peaks_epochs` as they are crucial for accurate feature extraction.
  * MATLAB's Signal Processing Toolbox for functions like `diff`, used in calculating derivatives.

### [extractPPGTDFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGTDFeatures.m)
* **Purpose**: Provides a detailed analysis of time-domain features from PPG data. The function computes a variety of metrics that provide insights into the waveform's properties such as variability, central tendency, dispersion, and shape, which are indicative of underlying cardiovascular dynamics.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch.
  * `detected_onsets` - Cell array containing detected onsets for each epoch.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `features_table` - MATLAB table with one row per epoch and columns for each calculated feature, including statistical summaries and variability metrics.
* **Process**:
  * Iterates through each epoch to calculate a wide range of time-domain features.
  * Computes min and max values within the PPG signal to understand signal amplitude.
  * Applies Median Absolute Deviation (MAD) and average curve length calculations for signal variability.
  * Determines trimmed means for central tendency with varying levels of outlier influence.
  * Calculates standard deviation, variance, and energy for signal dispersion and power.
  * Uses percentiles to gauge signal distribution at different intervals.
  * Employs the root mean square of successive differences (RMSSD) and standard deviation of successive differences (SDSD) to measure heart rate variability.
  * Applies kurtosis and skewness calculations to understand the distribution shape of the PPG signal.
  * Computes interquartile range (IQR) for variability without outliers' influence.
  * Integrates complex signal analysis techniques like Poincaré plots and singular value decomposition for advanced variability and structural insights.
  * Utilizes Hjorth parameters for signal complexity and fractal dimension analysis (when required).
  * Outputs a features table with calculated metrics for each epoch.
* **Dependencies**:
  * Accurate detection of systolic peaks and onsets prior to using this function.
  * MATLAB`s base functionality for numerical operations and the Statistics Toolbox for advanced statistical calculations.

### [extractPPGFDFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGFDFeatures.m)
* **Purpose**: Provides a detailed analysis of frequency-domain features from PPG data. 
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `mergedTable` - MATLAB table combining all frequency-domain features calculated across various defined and literature-based frequency bands.
* **Process**:
  * Adopts spectral analysis techniques based on studies like Wu et al. (2020), Olsen et al. (2023), Ucar et al. (2018), and Bozkurt et al.
  * Segments the frequency spectrum into defined bands to capture various aspects of HRV and cardiovascular dynamics.
  Uses Power Spectral Density (PSD) analysis to calculate power within very low frequency (VLF), low frequency (LF), and high frequency (HF) bands.
  * Employs Welch's method and Fast Fourier Transform (FFT) for robust spectral estimation.
  * Integrates power within each band and calculates ratios to assess autonomic balance and signal power distribution.
  * Outputs the table combining all frequency-domain features.
* **Dependencies**:
  * MATLAB's Signal Processing Toolbox for spectral analysis functions.
  * Data must be preprocessed to remove noise and correct for artifacts to ensure the accuracy of frequency-domain measurements.

### [extractPPGWTFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGFDFeatures.m)
* **Purpose**: Automates the extraction of wavelet transform features from preprocessed PPG data, employing a symlet wavelet to analyze the signal at multiple scales. This approach is useful in identifying intrinsic patterns and anomalies in PPG data that are often indicative of physiological states and cardiovascular health.
* **Inputs**:
   * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
   * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
   * `featuresTable` - MATLAB table containing wavelet-derived features including energy, mean, standard deviation, and variance at various decomposition levels, along with approximation features.
* **Process**:
   * Utilizes the 'sym6' symlet wavelet for its balance of smoothness and symmetry, ideal for PPG signal analysis.
   * Conducts multilevel wavelet decomposition to analyze PPG signals across different frequency scales.
   * Extracts detail coefficients at higher frequency levels to capture transient signal characteristics.
   * Analyzes approximation coefficients at each level to represent the signal`s underlying trend.
   * Calculates statistical features including energy, mean, standard deviation, and variance from wavelet coefficients.
   * Ensures that both frequency content and signal variability are captured, providing a comprehensive understanding of the physiological implications.

### [extractPPGIMFFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGFDFeatures.m)
* **Purpose**: Extracts a detailed set of features from the first intrinsic mode function (IMF) of PPG data. The features include instantaneous attributes (amplitude, frequency, phase) and statistical metrics, providing a thorough analysis of the signal's physiological information content.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - A MATLAB table containing various computed features for each epoch.
* **Process**:
  * Employs empirical mode decomposition (EMD) to decompose the PPG signal into multiple IMFs, focusing on the first for feature extraction.
  * Applies the Hilbert transform to the first IMF to derive instantaneous amplitude, frequency, and phase, alongside other derived statistical features.
* **Dependencies**:
  * MATLAB's Signal Processing Toolbox for EMD and Hilbert transform functionalities.

### [extractPPGEntropyFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGFDFeatures.m)
* **Purpose**: Analyzes the complexity and regularity of PPG data across epochs using various entropy measures. This function helps in understanding the physiological implications hidden in PPG signals, which are crucial for diagnosing and monitoring cardiovascular health.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - A MATLAB table with rows corresponding to epochs of PPG data. Each row contains entropy measures for the epoch, offering insights into the signal`s complexity and physiological dynamics.
* **Process**:
  * Computes Approximate Entropy, Sample Entropy, Fuzzy Entropy, and Permutation Entropy using predefined parameters. These measures assess the predictability and disorder in PPG signal fluctuations, providing insights into heart rate variability and other physiological dynamics.
  * Utilizes parallel computing to enhance computational efficiency, particularly beneficial when processing large datasets.
* **Dependencies**:
  * MATLAB's Predictive Maintenance Toolbox for `approximateEntropy`.
  * Custom MATLAB functions `SampleEn`, `PerEn`, and `FuzzyEn` from MATLAB Central File Exchange.
* **References**:
  * Martínez-Cagigal, Víctor (2018). Sample Entropy. Mathworks. [Access here](https://ch.mathworks.com/matlabcentral/fileexchange/69381-sample-entropy)
  * Ouyang, Gaoxiang (2024). Permutation Entropy. MATLAB Central File Exchange. [Access here](https://www.mathworks.com/matlabcentral/fileexchange/37289-permutation-entropy)
  * Baghdadi, Golnaz (2024). Fuzzy Entropy. MATLAB Central File Exchange. [Access here](https://www.mathworks.com/matlabcentral/fileexchange/98064-func_fe_fuzzen)
 
### [extractPPGRRandDET.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGRRandDET.m)
* **Purpose**: To compute recurrence-based metrics from Peak-to-Peak Interval (PPI) data derived from Photoplethysmography (PPG) signals. This analysis helps in understanding the underlying physiological states and their predictability through Recurrence Rate (RR) and Determinism (DET).
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - A table containing RR and DET measures for each epoch, aiding further analysis like trend identification or anomaly detection in physiological signals.
* **Process**:
  * **Recurrence Rate (RR)**: Measures the proportion of points in a recurrence plot where the signal revisits a state, reflecting the overall frequency of recurrent states within the signal.
  * **Determinism (DET**): Analyzes the predictability and regularity of the time series by identifying the proportion of recurrent points that form diagonal lines in the recurrence plot, which indicates deterministic structures in the signal dynamics.
* **Dependencies**:
  * [`calculateRRandDet.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/calculateRRandDet.m): A custom function that computes the Recurrence Plot (RP) along with RR and DET metrics based on predefined thresholds and minimum line lengths. Details are available in the custom function file.

### [extractPPGLcHfdKfdFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPGLcHfdKfdFeatures.m)
* **Purpose**: This function extracts key dynamical and fractal metrics from Photoplethysmogram (PPG) signals to analyze physiological signals' complexity and chaotic behavior. Metrics extracted include the Lyapunov exponent, Higuchi fractal dimension, and Katz fractal dimension.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - Table containing the calculated features for each epoch, enabling further analysis of signal characteristics.
* **Process**:
  * **Lyapunov Exponent (LC)**: Measures the rate of divergence of closely related trajectories in the signal, providing insight into the chaotic nature of the physiological system.
  * **Higuchi Fractal Dimension (HFD)**: Estimates the fractal dimension of the signal using a time-domain approach, reflecting the complexity.
  * **Katz Fractal Dimension (KFD)**: Another measure of fractal dimension that accounts for both the signal's amplitude and length.
* **Dependencies**:
  * lyapunovExponent: Utilizes MATLAB's Predictive Maintenance Toolbox to estimate the rate of divergence among signal trajectories.
  * Higuchi_FD and Katz_FD: Custom functions available from MATLAB Central File Exchange to calculate respective fractal dimensions.
* **References**:
  * Jesús Monge-Álvarez (2024). Higuchi and Katz fractal dimension measures. Available online: MATLAB Central File Exchange.

### [extractPPITDFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPITDFeatures.m)
* **Purpose**: Extracts a comprehensive set of features from PPG peak-to-peak intervals, focusing on heart rate variability (HRV) metrics, statistical summaries, and advanced analysis like geometric and non-linear features. These features are critical for studies involving cardiovascular health, stress analysis, and other medical applications.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch, used to compute peak-to-peak intervals.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - MATLAB table containing extracted features, with one row per epoch and columns labeled according to each feature.
* **Process**:
  * Utilizes time intervals between consecutive PPG peaks to compute traditional HRV metrics (e.g., RMSSD, SDNN) and advanced features such as Teager energy and non-linear dynamics.
  * Employs statistical methods to provide a detailed description of interval variability and dynamics.
* **Dependencies**:
  * MATLAB Signal Processing Toolbox for comprehensive statistical and signal processing functions.
  * `TINN` and `Triangular_Index` are computed using the `triangularInterp` function, which estimates the base width and regularity of the NN interval histogram. This measurement is crucial for assessing the autonomic nervous system's regulation of heart intervals.

### [triangularInterp.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/triangularInterp.m)
* **Purpose**: Calculates the Triangular Interpolation of NN Interval Histogram (TINN) and triangular index, important metrics in heart rate variability (HRV) studies. TINN measures the variability and regularity of cardiac rhythms by assessing the width of the densest part of the NN interval histogram.
* **Inputs**:
  * `PPI`: Array of peak-to-peak intervals.
  * `bin_width`: Bin width for histogram calculation; a default is used if not specified.
* **Outputs**:
  * `tinn`: Indicates the base width of the densest part of the NN interval histogram, a measure of HRV.
  * `triangular_index`: Compares the total count of intervals to the histogram mode, indicating rhythm regularity.
* **Process**:
  * Computes the histogram of peak-to-peak intervals (PPI) using the specified bin width to represent HRV distribution.
  * Identifies the histogram bin with the maximum count, representing the mode of heart rate intervals.
  * Initiates an optimization process to find the triangular base (TINN) that best fits the histogram by minimizing the difference between the actual histogram and an idealized triangular shape.
  * Iteratively searches for the optimal starting point (N) and endpoint (M) of the triangular base before and after the mode bin, respectively.
  * Calculates TINN as the distance between the optimized starting and ending points of the histogram's triangular base, providing an HRV measure.
  * Determines the triangular index as the ratio of the total number of intervals to the mode's height, offering insight into heart rate regularity.

### [extractPPIEntropyFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPIEntropyFeatures.m)
* **Purpose**: To calculate multiple entropy metrics from PPI of PPG data, offering insights into the complexity and predictability of heart rate variations.
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch, used to compute peak-to-peak intervals.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - Table containing various entropy metrics per epoch.
* **Process**:
  * Computes Approximate Entropy, Sample Entropy, Fuzzy Entropy, and Permutation Entropy to assess signal regularity and complexity.
  * Parameters such as embedding dimension and tolerance are tailored based on typical physiological data ranges and variability.
* **Dependencies**:
  * MATLAB's Predictive Maintenance Toolbox for `approximateEntropy`.
  * Custom MATLAB functions `SampleEn`, `PerEn`, and `FuzzyEn` available on MATLAB File Exchange:
    * `SampleEn` by Víctor Martínez-Cagigal: [Sample Entropy](https://ch.mathworks.com/matlabcentral/fileexchange/69381-sample-entropy)
    * `PerEn` by Gaoxiang Ouyang: [Permutation Entropy](https://www.mathworks.com/matlabcentral/fileexchange/37289-permutation-entropy)
    * `FuzzyEn` by Golnaz Baghdadi: [Fuzzy Entropy](https://www.mathworks.com/matlabcentral/fileexchange/98064-func_fe_fuzzen)
* **Additional Notes**:
  * Proper parameter tuning (e.g., embedding dimensions, tolerance) is critical for accurate entropy estimation and may need adjustment based on specific dataset characteristics.

### [extractPPIvgFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPIEntropyFeatures.m)
* **Purpose**: Analyzes Peak-to-Peak Intervals (PPI) derived from photoplethysmogram (PPG) signals through visibility graph analysis. 
* **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `detected_peaks` - Cell array containing detected peaks for each epoch, used to compute peak-to-peak intervals.
  * `fs` - Sampling rate of the PPG signal.
* **Outputs**:
  * `featuresTable` - a table containing graph-based metrics for each epoch, offering a structured way to analyze and interpret the complexity of PPI data across different conditions or time frames.
* **Process**:
  * **Visibility Graph Construction**: Converts PPI sequences into visibility graphs using the `fast_NVG` and `NVG_alg` functions. These graphs illustrate the natural visibility between points in the time series, encapsulating the dynamic structure and potential predictors of physiological states.
  * **Graph Feature Extraction**: Computes various metrics from the visibility graphs such as node degrees, clustering coefficients, and path lengths using the `graphProperties` function. These metrics provide a quantitative assessment of the graph's topology and efficiency.
**Dependencies**:
  * `fast_NVG` and `NVG_alg`: Custom MATLAB functions by Giovanni Iacobello for constructing and processing visibility graphs. These functions are pivotal for transforming time series data into a graph format that reflects the natural visibility among data points.
  * `graphProperties`: A MATLAB function that computes characteristic path length, global efficiency, and clustering coefficients among other properties from a given graph's adjacency matrix, developed by Nathan D. Cahill.
* **References**:
  * Giovanni Iacobello (2024). Fast natural visibility graph (NVG) for MATLAB, MATLAB Central File Exchange. Retrieved April 16, 2024. [Access here](https://www.mathworks.com/matlabcentral/fileexchange/70432-fast-natural-visibility-graph-nvg-for-matlab)
   * Nathan D. Cahill, "Graph properties function," available on GitHub under NetworkTopologyvsFlowVulnerability repository, accessed April 12, 2024. [Access here](https://github.com/Roberock/NetworkTopologyvsFlowVulnerbaility/blob/master/graphProperties.m)

### [extractPPIdfaFeatures.m](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/extractPPIdfaFeatures.m)
* **Purpose**: This function aims to extract various fractal and correlation analysis metrics from Peak-to-Peak Interval (PPI) data, critical for understanding the underlying physiological dynamics reflected in PPG signals.
* * **Inputs**:
  * `data` - Matrix of PPG signal data, with each column representing an epoch (first row contains labels).
  * `fs` - Sampling rate of the PPG signal.
  * `detected_peaks` - Cell array containing detected peaks for each epoch, used to compute peak-to-peak intervals.
* **Outputs**:
  * `featuresTable` - A table containing the calculated features for each epoch, which includes measures such as the Higuchi Fractal Dimension, various DFA indices, and more. This table facilitates further statistical analysis or machine learning applications.
* **Process**:
  * **Fractal Dimensions**: Calculates the Higuchi Fractal Dimension (HFD) to quantify the fractal properties of PPI data, indicating complexity and variability.
  * **Detrended Fluctuation Analysis (DFA)**: Computes the overall DFA exponent, short-term, and long-term scaling exponents to evaluate intrinsic correlation properties within the PPI data.
  * **Progressive and Windowed DFA**: Analyzes segments and windows of PPI data to determine local DFA values, providing insights into how correlations evolve over time or across different sections of the data.
  * **DMA Analysis**: Implements Detrended Moving Average analysis to provide another perspective on the fractal nature of the time series by examining average fluctuations at various scales.
* **Dependencies**:
  * Higuchi_FD.m: Custom function for calculating the fractal dimension of a time series.
  * [`dfaOverall.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/dfaOverall.m), [`dfaShortLong.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/dfaShortLong.m), [`dfaProgressive.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/dfaProgressive.m), [`dfaWindowed.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/dfaeWindowed.m), [`dmaAvg.m`](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/dmaAvg.m): A suite of custom functions for comprehensive DFA analysis adapted to various contexts and requirements of the data. The details for each function are available in respective code files.
* **References**:
  * Jesús Monge-Álvarez (2024). Higuchi and Katz fractal dimension measures,MATLAB Central File Exchange. Retrieved April 12, 2024.[Access here](https://www.mathworks.com/matlabcentral/fileexchange/50290-higuchi-and-katz-fractal-dimension-measures)

## Feature significance
### [feature_significance.py](https://github.com/kmarkoveth/PPG/blob/main/feature_extraction_and_significance/feature_significance.py)
* **Purpose**: This script processes PPG signal data extracted into feature sets to evaluate statistical significance across different sleep stage classifications. It automates the assessment of feature relevance in distinguishing between wake, NREM, and REM sleep stages using various statistical tests.
* **Inputs**:
  * Directory including .csv files with pre-extracted features with filenames indicative of the subject ID and data type.
* **Outputs**:
  * CSV files for each classification stage with features deemed significant and the full dataframe with all features showing significant and non-significant features for each classification.
* **Process**:
  * **Data Aggregation**: The script aggregates feature data from multiple CSV files, each representing a different participant or session, ensuring that all files meet a predefined structure before merging.
  * **Feature Adjustment**: Labels within the dataset are adjusted to facilitate binary, ternary, and more granular sleep stage classifications.
  * **Statistical Testing**: Implements normality tests and applies appropriate statistical tests (t-tests, Mann-Whitney U, ANOVA, or Kruskal-Wallis) based on the distribution characteristics of the data to determine feature significance across different stages.
  * **Post-hoc Analysis**: For features found to be significant, post-hoc tests discern which specific groups differ from each other.
  * **Output**: Generates two primary outputs for each classification level—processed datasets ready for model training and summaries of significant features.


