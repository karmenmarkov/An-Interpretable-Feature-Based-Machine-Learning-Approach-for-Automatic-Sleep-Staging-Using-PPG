"""
This script combines PPG signal data with their corresponding labels into a unified CSV format suitable for
subsequent analysis. It aligns the start times of the PPG data and label data, trims the PPG data to match the labels
if necessary, and constructs a matrix representing 30-second epochs of PPG data for each sleep stage label. It handles
any misalignments and reports files that could not be processed.

Assumptions:
- PPG data is saved as '_ppg.csv'.
- Label data is saved as '_labels.csv'.
- The sample rate of PPG data is 128 Hz.
- Start times in both PPG and label data are properly formatted for comparison.

"""


import pandas as pd
import datetime
import numpy as np
import os

ppg_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/inverted_ppg_data"
labels_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/labels_new"
combined_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/processed_data"

# Initialize a list to keep track of any files that fail to process
failed_files = []

# Iterate over each file in the PPG data folder
for ppg_file_name in os.listdir(ppg_folder_path):
    print(ppg_file_name) # Print the current file being processed for visibility
    if not ppg_file_name.endswith('_ppg.csv'):
        continue

    # Construct file paths for the PPG data, corresponding labels, and the output combined file
    name = ppg_file_name[:-8] # Extract the base name of the file without the '_ppg.csv' part
    ppg_file_path = os.path.join(ppg_folder_path, ppg_file_name)
    labels_file_path = os.path.join(labels_folder_path, name + '_labels.csv')
    combined_file_path = os.path.join(combined_folder_path, name + '.csv')
    
    try: 
        # Load the label data, assuming the labels are in the second row (header=1)
        labels = pd.read_csv(labels_file_path, header=1)
        number_of_labels = len(labels) # Count the total number of labels

        # Load the PPG data, with actual data starting from the fifth row (header=4)
        data = pd.read_csv(ppg_file_path, header=4)

        # Extract start times
        label_start_time = pd.to_datetime(labels.iloc[0, 0])
        data_start_time = pd.to_datetime(pd.read_csv(ppg_file_path, nrows=1, header=2).iloc[0, 0])

        # Calculate the time difference in seconds between the label start and PPG data start
        difference = int((label_start_time - data_start_time).total_seconds())

        # Determine how to adjust the PPG data based on the time difference
        sample_rate = 128  # Define the sample rate of the PPG data
        if difference >= 0: # If the labels start at or after the PPG data, trim the PPG data to start at the first label
            start_index = int(difference * sample_rate)
            data_trimmed = data.iloc[start_index:].reset_index(drop=True)
        else: # If the PPG data starts after the labels, note the misalignment and skip this file
            print("Warning: PPG data starts after the first label. Please check data alignment.")
            failed_files.append(ppg_file_name)
            continue  # Skip further processing for this file

        # Calculate how many labels can be supported by the trimmed PPG data
        max_supported_labels = len(data) // (30 * sample_rate)
        # Check if the available PPG data can support the existing number of labels
        if max_supported_labels >= number_of_labels:
            print("PPG data is sufficient for the number of labels.")
        else: # If not, adjust the number of labels to match the available PPG data
            print(f"PPG data can only support {max_supported_labels} labels out of {number_of_labels}. Adjusting the number of labels to match the PPG data.")
            labels = labels.iloc[:max_supported_labels]
            number_of_labels = max_supported_labels

        # Initialize a matrix to hold the adjusted labels and corresponding PPG data for each 30-second epoch
        stages = np.zeros((1 + 30 * sample_rate, number_of_labels))
        for i in range(number_of_labels):
            stages[0, i] = int(labels.iloc[i]['Event']) # Assign the label for each epoch to the first row of the matrix
            # Copy the corresponding PPG data for each epoch into the matrix
            start_index = i * 30 * sample_rate
            end_index = start_index + 30 * sample_rate
            stages[1:, i] = data.iloc[start_index:end_index, 0].values

        # Save the combined labels and PPG data to a CSV file for further analysis
        pd.DataFrame(stages).to_csv(combined_file_path, index=False, header=None)

    # Catch any exceptions during processing and add the file name to the list of failed files
    except Exception as e:
        print(f"Failed to process {ppg_file_name}: {e}")
        failed_files.append(ppg_file_name)
    
# Print out the failed files
if failed_files:
    print("Files that failed to process:")
    for failed_file in failed_files:
        print(failed_file)
