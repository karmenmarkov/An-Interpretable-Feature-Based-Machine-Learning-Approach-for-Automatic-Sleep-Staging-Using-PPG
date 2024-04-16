# Preprocessing Steps
The preprocessing phase lays the groundwork for all subsequent analysis by transforming raw data into a refined form ready for in-depth examination. Below is a step-by-step breakdown of each script used in the preprocessing workflow, detailing their purposes, inputs, outputs, and the processes they entail. Each script is a critical piece in preparing the dataset for robust and accurate sleep stage classification.

## Steps
### [restructure_labels.py](https://github.com/kmarkoveth/PPG/blob/main/preprocessing/restructure_labels.py)
* **Purpose**: Transforms sleep stage labels from raw `.txt` files into structured ’.csv’ format suitable for analysis. 
* **Inputs**: Directory with `.txt` files of timestamped sleep stage events.
* **Outputs**: Directory with `.csv` files containing numeric-coded sleep stage data and categorizations (binary sleep/wake, 3 stages, 4 stages, and 5 stages).
* **Process**: 
  * Identifies entries marked by "Sleep Stage".
  * Standardizes timestamp formats.
  * Ensures continuous 30-second epochs.
  * Converts descriptions to numeric codes and categorizes stages.

### [restructure_ppg_data.py](https://github.com/kmarkoveth/PPG/blob/main/preprocessing/restructure_ppg_data.py)
* **Purpose**: Extracts and saves PPG signals from `.edf` files in `.csv` format.
* **Inputs**: Directory with `.edf` files containing PPG data.
* **Outputs**: Directory with `.csv` files representing PPG signals and header information.
* **Process**: 
  *	Iterates over `.edf` files.
  *	Reads PLETH signal and sampling frequency.
  *	Creates headers with sampling frequency and start datetime.
  *	Writes signal and headers into `.csv` files.
*	**Failure Handling**: Logs unprocessable files missing PLETH signals or encountering read errors.

### [invert_ppg.py](https://github.com/kmarkoveth/PPG/blob/main/preprocessing/invert_ppg.py)
* **Purpose**: Corrects previously inverted PPG signal data for analysis.
* **Inputs**: Directory with `.csv` files of PPG data excluding specified file names.
* **Outputs**: Directory with inverted PPG data in `.csv` format.
* **Process**:
  * Excludes certain file names from inversion.
  * Inverts PPG signal values while preserving headers.
  * Saves inverted signals into new `.csv` files.
* **Notes**:
  * Adjust `header_rows` if the number of header rows differs between files.
  * Review skipped file names and add or remove conditions as needed.
  * The script outputs to the console the path to each inverted file after processing.

### [join_data.py](https://github.com/kmarkoveth/PPG/blob/main/preprocessing/join_data.py)
* **Purpose**: Prepares a dataset by merging PPG signal data with corresponding sleep stage labels.
* **Inputs**: Directory with `.csv` files of PPG data and sleep stage labels.
* **Outputs**: Directory with labeled PPG epochs in `.csv` files named after the original PPG files.
* **Process**:
  * Aligns start times of PPG data and labels.
  * Trims or extends data for 30-second labeled epochs.
  * Outputs combined data into specified directory.
* **Notes**: Assumes consistent sampling rate and comparable start times.

### [filtering_and_preprocessing.py](https://github.com/kmarkoveth/PPG/blob/main/preprocessing/filtering_and_preprocessing.py)
* **Purpose**: Preprocesses raw PPG signal data for sleep stage analysis using various normalization methods.
* **Inputs**: Directory with labeled PPG data in `.csv` files.
* **Outputs**: Directory with processed data segregated by normalization method into `.csv` files with PPG epochs and sleep stage labels.
* **Process**:
  *	Applies 4th-order Chebyshev Type I bandpass filtering (0.5 Hz to 80 Hz, passband ripple 0.2 dB) to isolate the frequency range of interest within the PPG signal.
  * Implements a moving average filter to smooth the signal, with a default window size of 10 (customizable).
  * Normalizes the filtered data using the selected method (none, z-score, or Min-Max scaling) to prepare for further analysis.
  * Ensures each epoch of PPG data remains properly aligned with its corresponding sleep stage label.
*	**Customization**: Users may need to adjust the `fs`, `epoch_duration`, and `window_size` parameters based on their specific dataset and research requirements.

