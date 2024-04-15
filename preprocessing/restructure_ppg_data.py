"""
This script processes PPG data stored in EDF files. For each file, it extracts the PLETH signal,
generates a corresponding timestamp, and saves the data into a CSV file with header information
including sampling frequency and start datetime.

Input: Directory containing EDF files with PPG data.
Output: Directory with CSV files, each containing the PLETH signal from an EDF file.
Behavior: The script logs files that could not be processed due to missing PLETH signals or read errors.
"""

import pyedflib
import numpy as np
import pandas as pd 
import os

# Define the input and output folder paths
input_folder = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/ppg_data_unchanged"
output_folder = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/ppg_data_try2"

# Keep track of files that couldn't be processed
failed_files = []

# Loop through each file in the input folder
for file_name in os.listdir(input_folder):
    try:
        if file_name.endswith('.edf'):
            # Construct the input and output file paths
            input_path = os.path.join(input_folder, file_name)
            output_path = os.path.join(output_folder, os.path.splitext(file_name)[0] + '_ppg.csv')
            
            # Open the .edf file
            with pyedflib.EdfReader(input_path) as f:
                start_datetime = f.getStartdatetime()

                # Get the PLETH signal and sampling frequency (first convert all labels to upper case)
                upper = [element.upper() for element in f.getSignalLabels()]
                if "PLETH" in upper:
                    index = upper.index("PLETH")
                    signal = f.readSignal(index)
                    freq = f.getSampleFrequency(index)
                    
                    # Create a pandas dataframe from the PLETH signal and add header information
                    signal_pd = pd.DataFrame(signal)
                    header = ['sampling freq (Hz):\n'+ str(freq)+'\n'+ 'start_datetime\n'+ str(start_datetime)+'\n']
                    header_str = ','.join(header)
                    
                    # Write the dataframe to a CSV file with header
                    with open(output_path, 'w') as csv_file:
                        csv_file.write(header_str)
                        signal_pd.to_csv(csv_file, index=None, lineterminator='\n')
                else:
                    print(f"No PLETH signal found in file: {file_name}")
                    failed_files.append(file_name)

    except Exception as e:
        print(f"Failed to process {file_name}: {e}")
        failed_files.append(file_name)

# Print out the failed files
print("Files that failed to process:")
for failed_file in failed_files:
    print(failed_file)
