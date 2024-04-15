"""
This script inverts PPG signal data from CSV files. It maintains the header information intact and saves the inverted signal 
into new CSV files. It skips specific files based on filename patterns and is configured to work with PPG data that was 
previously inverted during processing.

Usage: Run the script in a Python environment where the necessary libraries are installed. Set the 'directory_path' 
to the folder containing the original PPG CSV files and 'inverted_directory_path' to the destination folder for the inverted files.
"""

# Invert the originally intervted .edf files and check if the inverting worked
import pandas as pd
import os

# Function to read the numeric data skipping the headers
def read_signal_data(file_path, header_rows):
    return pd.read_csv(file_path, skiprows=header_rows, header=None)

# Function to read the headers
def read_headers(file_path, header_rows):
    return pd.read_csv(file_path, nrows=header_rows, header=None)

# Function to invert the signal and save to a new CSV, keeping headers intact
def invert_signal_and_save(input_file_path, output_file_path, header_rows):
    # Read the headers
    headers = read_headers(input_file_path, header_rows)
    
    # Read the signal data
    signal_data = read_signal_data(input_file_path, header_rows)
    
    # Invert the signal data
    inverted_signal_data = -signal_data
    
    # Combine headers and inverted data into a single dataframe for consistency and easier handling.
    # # Headers remain at the top, followed by the inverted signal data.
    full_data = pd.concat([headers, inverted_signal_data])
    
    # Save the full data to a new CSV file
    full_data.to_csv(output_file_path, index=False, header=False)

# Directory containing the PPG files
directory_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/ppg_data/"
inverted_directory_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/inverted_ppg_data/"

# Number of rows to skip for the header
header_rows = 4

# Loop through all files in the directory
for filename in os.listdir(directory_path):
    # The files 'sdb4', 'nfle6', and 'nfle20' are already correctly oriented and do not require inversion.
    # They are skipped to avoid unnecessary processing.
    if 'sdb4' in filename or 'nfle6' in filename or 'nfle20' in filename: #already correct
        continue  # Skip this iteration and move to the next file

    # Check if the file is a CSV file
    if filename.endswith("_ppg.csv"):
        original_file_path = os.path.join(directory_path, filename)
        new_file_path = os.path.join(inverted_directory_path, filename) 

        # Invert signal and save to new CSV
        invert_signal_and_save(original_file_path, new_file_path, header_rows)

        print(f'Processed and inverted signal saved to: {new_file_path}')

# The following sections plot and compare the original and inverted signals to ensure that the inversion process
# has been successful. Visual checks complement the programmatic comparison.
import matplotlib.pyplot as plt
original_file_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/ppg_data/sdb4_ppg.csv"
new_file_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/inverted_ppg_data/sdb4_ppg.csv"

# Number of rows to skip for the header
header_rows = 4

# Plot the original signal data
original_signal_data = read_signal_data(original_file_path, header_rows)
plt.figure()
plt.plot(original_signal_data)
plt.title('Original Signal')
plt.show()

# Plot the inverted signal data
inverted_signal_data = read_signal_data(new_file_path, header_rows)
plt.figure()
plt.plot(inverted_signal_data)
plt.title('Inverted Signal')
plt.show()

# Compare the first 20 rows of the original and inverted signal data
print("First 20 rows of the original signal data:")
print(original_signal_data.head(20))

print("\nFirst 20 rows of the inverted signal data:")
print(inverted_signal_data.head(20))

# Verify that the inversion is correct by comparing the original signal data (multiplied by -1) to the inverted signal data.
# If they match, it confirms the inversion process was successful, ignoring the header rows.
if original_signal_data.equals(-inverted_signal_data):
    print('The original and inverted data are equal (ignoring the headers).')
else:
    print('The original and inverted data are not equal.')
