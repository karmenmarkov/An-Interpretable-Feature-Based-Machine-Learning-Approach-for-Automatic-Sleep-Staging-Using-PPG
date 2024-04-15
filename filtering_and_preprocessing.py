"""
This script processes PPG signal data from CSV files in three different normalization variations. It applies a Chebyshev 
Type I bandpass filter to isolate the physiological range of interest, followed by a moving average filter to smooth the 
signal. The processed signal is then normalized using one of three methods: no normalization, z-score standardization, 
or Min-Max scaling. Each preprocessed signal epoch is concatenated with its corresponding sleep stage label for further 
analysis.

The script is set up to process multiple files within a directory and will output the preprocessed data into separate CSV files.

Parameters:
- fs: The sampling frequency of the PPG data (default is 128 Hz).
- epoch_duration: Duration of each epoch in seconds (default is 30 seconds).
- window_size: Window size for the moving average filter (default is 10 samples).

Normalization methods:
- V1: No normalization.
- V2: Z-score normalization.
- V3: Min-Max scaling.

The processed data will be saved in directories corresponding to each normalization method.
"""


import pandas as pd
import numpy as np
import os
from scipy.signal import cheby1, filtfilt
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import StandardScaler
import os



# V1: No normalization of PPG data
# Apply bandpass filtering and moving average filtering to the raw PPG signal data.
# The filtered signal is then saved without any normalization.

# Constants
fs = 128  # Sampling rate
epoch_duration = 30  # Duration of each epoch in seconds
window_size = 10  # Window size for moving average filter

# Define the functions for preprocessing

# Function to apply a moving average filter
def moving_average_filter(data, window_size=10):
    return np.convolve(data, np.ones(window_size) / window_size, mode='same')

# Define preprocessing function
def preprocess_epoch(ppg_epoch, fs=128, window_size=10):
    # Step 1: Apply Chebyshev Type I filter
    nyq = 0.5 * fs
    low = 0.5 / nyq
    high = 8 / nyq
    b, a = cheby1(4, 0.2, [low, high], btype='band')
    filtered_data = filtfilt(b, a, ppg_epoch)

    # Step 2: Apply moving average filter
    ma_filtered_data = moving_average_filter(filtered_data, window_size)
    
    return ma_filtered_data

# Paths to folders
data_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/processed_data"
cleaned_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/clean_data_nonstandardized"


# Process each file in the data folder
for ppg_file_name in os.listdir(data_folder_path):
    if ppg_file_name.endswith('.csv'):
        print(f"Processing {ppg_file_name}...")
        ppg_file_path = os.path.join(data_folder_path, ppg_file_name)
        combined_file_path = os.path.join(cleaned_folder_path, ppg_file_name)
        
        # Read the CSV file
        df = pd.read_csv(ppg_file_path, header=None)
        
        # Extract labels from the first row and initialize the data_all array
        labels = df.iloc[0, :].astype(int)
        data_all = np.zeros((fs * epoch_duration + 1, len(labels))) 
        data_all[0, :] = labels.values #first row of data_all will be the labels
        
        # Process each epoch
        for i in range(len(labels)):
            epoch_data = df.iloc[1:, i].values # Extract the epoch data for the ith label, skip the first row (labels)
            processed_epoch_data = preprocess_epoch(epoch_data, fs, window_size) # Preprocess the epoch data
            data_all[1:, i] = processed_epoch_data # Assign the processed data back to data_all, skipping the first row (labels)
        
        # Convert processed data back to DataFrame and save
        processed_df = pd.DataFrame(data_all)

        # Save the processed data to a new CSV file
        processed_df.to_csv(combined_file_path, index=False, header=False)
        print(f"Finished processing {ppg_file_name} and saved to {combined_file_path}.")


# V2: Z-score normalization of PPG data
# Apply bandpass filtering and moving average filtering to the raw PPG signal data, and then normalized the signal using z-score normalization.
# The filtered and normalized signal is then saved.

# Define preprocessing function
def preprocess_epoch(ppg_epoch, fs=128, window_size=10):
    # Step 1: Apply Chebyshev Type I filter
    nyq = 0.5 * fs
    low = 0.5 / nyq
    high = 8 / nyq
    b, a = cheby1(4, 0.2, [low, high], btype='band')
    filtered_data = filtfilt(b, a, ppg_epoch)

    # Step 2: Apply moving average filter
    ma_filtered_data = moving_average_filter(filtered_data, window_size)

    # Step 3: Standardize Data
    scaler = StandardScaler()
    standardized_data = scaler.fit_transform(ma_filtered_data.reshape(-1, 1)).flatten()
    
    return standardized_data

# Paths to folders
data_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/processed_data"
cleaned_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/clean_data"

# Process each file in the data folder
for ppg_file_name in os.listdir(data_folder_path):
    if ppg_file_name.endswith('.csv'):
        print(f"Processing {ppg_file_name}...")
        ppg_file_path = os.path.join(data_folder_path, ppg_file_name)
        combined_file_path = os.path.join(cleaned_folder_path, ppg_file_name)
        
        # Read the CSV file
        df = pd.read_csv(ppg_file_path, header=None)
        
        # Extract labels from the first row and initialize the data_all array
        labels = df.iloc[0, :].astype(int)
        data_all = np.zeros((fs * epoch_duration + 1, len(labels))) 
        data_all[0, :] = labels.values #first row of data_all will be the labels
        
        # Process each epoch
        for i in range(len(labels)):
            epoch_data = df.iloc[1:, i].values # Extract the epoch data for the ith label, skip the first row (labels)
            processed_epoch_data = preprocess_epoch(epoch_data, fs, window_size) # Preprocess the epoch data
            data_all[1:, i] = processed_epoch_data # Assign the processed data back to data_all, skipping the first row (labels)
        
        # Convert processed data back to DataFrame and save
        processed_df = pd.DataFrame(data_all)

        # Save the processed data to a new CSV file
        processed_df.to_csv(combined_file_path, index=False, header=False)
        print(f"Finished processing {ppg_file_name} and saved to {combined_file_path}.")

# V3: MinMax normalization of PPG data after filtering and applying moving average filter

# V3: Min-Max normalization of PPG data
# Apply bandpass filtering and moving average filtering to the raw PPG signal data, and then normalized the signal using min-max normalization.
# The filtered and normalized signal is then saved.

from sklearn.preprocessing import MinMaxScaler

# Define preprocessing function
def preprocess_epoch(ppg_epoch, fs=128, window_size=10):
    # Step 1: Apply Chebyshev Type I filter
    nyq = 0.5 * fs
    low = 0.5 / nyq
    high = 8 / nyq
    b, a = cheby1(4, 0.2, [low, high], btype='band')
    filtered_data = filtfilt(b, a, ppg_epoch)

    # Step 2: Apply moving average filter
    ma_filtered_data = moving_average_filter(filtered_data, window_size)

     # Step 3: Normalize Data
    scaler = MinMaxScaler(feature_range=(0, 1))
    normalized_data = scaler.fit_transform(ma_filtered_data.reshape(-1, 1)).flatten()
    
    return normalized_data

# Paths to folders
data_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/processed_data"
cleaned_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/clean_data_normalized"


# Process each file in the data folder
for ppg_file_name in os.listdir(data_folder_path):
    if ppg_file_name.endswith('.csv'):
        print(f"Processing {ppg_file_name}...")
        ppg_file_path = os.path.join(data_folder_path, ppg_file_name)
        combined_file_path = os.path.join(cleaned_folder_path, ppg_file_name)
        
        # Read the CSV file
        df = pd.read_csv(ppg_file_path, header=None)
        
        # Extract labels from the first row and initialize the data_all array
        labels = df.iloc[0, :].astype(int)
        data_all = np.zeros((fs * epoch_duration + 1, len(labels))) 
        data_all[0, :] = labels.values #first row of data_all will be the labels
        
        # Process each epoch
        for i in range(len(labels)):
            epoch_data = df.iloc[1:, i].values # Extract the epoch data for the ith label, skip the first row (labels)
            processed_epoch_data = preprocess_epoch(epoch_data, fs, window_size) # Preprocess the epoch data
            data_all[1:, i] = processed_epoch_data # Assign the processed data back to data_all, skipping the first row (labels)
        
        # Convert processed data back to DataFrame and save
        processed_df = pd.DataFrame(data_all)

        # Save the processed data to a new CSV file
        processed_df.to_csv(combined_file_path, index=False, header=False)
        print(f"Finished processing {ppg_file_name} and saved to {combined_file_path}.")

