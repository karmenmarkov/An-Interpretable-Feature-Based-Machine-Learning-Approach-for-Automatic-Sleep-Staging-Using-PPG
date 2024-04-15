# Overview:
# This script processes raw sleep stage label files, performs data cleaning and formatting, and then outputs the processed data to CSV files. The steps include reading text files, filtering necessary data, standardizing time formats, ensuring continuous 30-second intervals, and mapping sleep stage labels to numeric codes.

# Purpose:
# To preprocess raw sleep stage label files by extracting necessary information, standardizing the time format, ensuring a label is present for every 30-second interval, and converting string labels to a numeric system suitable for further analysis.

# Inputs:
# Raw text files with sleep stage labels, located in a specified folder. Each file must follow a known format that includes time stamps and event labels.

# Outputs:
# CSV files with cleaned and standardized sleep stage data. Each file contains timestamps and corresponding sleep stage labels converted to numeric codes, along with additional columns for different sleep stage categorizations (binary sleep/wake, 3 stages, 4 stages, and 5 stages).

# Methodology:
# The script reads each text file and extracts lines after "Sleep Stage" is found. It then cleans and formats the data according to the column structure. Time stamps are standardized to datetime objects, and data is checked for continuous 30-second intervals. Missing labels are inferred where possible, and final labels are converted to numeric codes. Several categorizations of sleep stages are added before saving the processed data as CSV files.

# Dependencies:
# - os: For interacting with the file system.
# - csv: For writing output files in CSV format.
# - pprint: For clean data output (if used).
# - pandas: For dataframe manipulation and datetime handling.
# - datetime: For time calculations, especially around midnight.

# Additional Notes:
# - The script assumes the recording may span midnight and adjusts time calculations accordingly.
# - The script infers missing labels if the surrounding intervals have consistent labels.
# - The output includes a header with the length of the recording.
# - The file names for the outputs are based on the input file names with '_labels' appended.


import os
import csv
import pprint
import pandas as pd
from datetime import datetime, timedelta

folder_path = '/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/labels_unchanged' # Replace with the path to your folder
output_folder_path = "/Users/karmenmarkov/Library/CloudStorage/GoogleDrive-kkarmenmarkov@gmail.com/My Drive/masters_ppg/labels_new" # Replace with the path to your output folder

for filename in os.listdir(folder_path):
    if filename.endswith('.txt'):
        # Read in the contents of the file
        print(filename)
        labels_table = []
        # Read raw label data from text files and load them into a structured dataframe.
        with open(os.path.join(folder_path, filename), 'r') as file:
            found_sleep_stage = False
            for line in file:
                if "Sleep Stage" in line:
                    found_sleep_stage = True
                if found_sleep_stage:
                    labels_table.append(line.strip().split('\t'))
        
        # Check number of columns
        col_num=len(labels_table[0])
        if col_num==5:
            df = pd.DataFrame(labels_table, columns=['Sleep Stage', 'Time [hh:mm:ss]', 'Event', 'Duration[s]', 'Location'])

        if col_num==6:
            df = pd.DataFrame(labels_table, columns=['Sleep Stage','Position', 'Time [hh:mm:ss]', 'Event', 'Duration[s]', 'Location'])
            df=df[['Sleep Stage', 'Time [hh:mm:ss]', 'Event', 'Duration[s]', 'Location']]

        df=df.tail(-1)

        # Clean up the dataframe to remove unnecessary labels and standardize time stamps.
        # Remove all unnecessary labels
        df = df[df["Event"].str.contains("SLEEP-S0|SLEEP-S1|SLEEP-S2|SLEEP-S3|SLEEP-S4|SLEEP-S5|SLEEP-REM") == True]

        # Replace periods with colons in the "Time [hh:mm:ss]" column
        df["Time [hh:mm:ss]"] = df["Time [hh:mm:ss]"].str.replace('.', ':')

        # Convert the "Time [hh:mm:ss]" column to datetime objects
        df["Time [hh:mm:ss]"] = pd.to_datetime(df["Time [hh:mm:ss]"], format='%H:%M:%S')

        # Get the starting time from the first row and end time from last row
        start_time = df["Time [hh:mm:ss]"].iloc[0]
        end_time = df["Time [hh:mm:ss]"].iloc[-1]

        # Check if the end time is earlier than the start time, indicating the recording spans over midnight
        if end_time.time() < start_time.time():
            end_time += timedelta(days=1) # The recording spans over midnight; add one day to the end time
        else:
            pass # The recording does not span over midnight, starts after midnight; no need to add one day to the end time

        # Create a new DataFrame that includes all time steps
        interval = timedelta(seconds=30)
        all_times = pd.date_range(start=start_time, end=end_time, freq=interval)
        all_times_df = pd.DataFrame({'Time [hh:mm:ss]': all_times})

        # This part is necessary to convert back the before added one day, to match the originial type of data
        new_date = '1900-01-01'
        all_times_df['Time [hh:mm:ss]'] = all_times_df['Time [hh:mm:ss]'].apply(lambda x: x.replace(year=int(new_date[:4]), month=int(new_date[5:7]), day=int(new_date[8:])))

        # Merge the new DataFrame with the original DataFrame
        merged_df = pd.merge(all_times_df, df, on='Time [hh:mm:ss]', how='left')

        # Fill in missing values with -1
        merged_df = merged_df.fillna({'Sleep Stage': -1, 'Event': -1, 'Duration[s]': -1, 'Location': -1})
        df=merged_df

        # Replace missing values where surrounding values are from the same sleep stage
        # Convert the 'Event' column to integers
        df['Event'] = df['Event'].replace({'SLEEP-S0': '0', 'SLEEP-S1': '1', 'SLEEP-S2': '2', 'SLEEP-S3': '3', 'SLEEP-S4': '4', 'SLEEP-REM': '5'}).astype(float)
    
        # Infer missing labels by comparing to preceding and following sleep stages.
        # Define the window size for checking surrounding values (30 seconds intervals before and after)
        window_size = 3  # This means we check 1 row before and 1 row after the current row

        # Iterate through the df  while avoiding the first and last few rows to prevent index out of bounds error
        for i in range(window_size, len(df) - window_size):
            # If the current row is a missing value
            if df.loc[i, 'Event'] == -1:
                # Check if the 2 intervals before and after are from the same sleep stage and not missing
                prev_values = df.loc[i-window_size:i-1, 'Event']
                next_values = df.loc[i+1:i+window_size, 'Event']
                
                # Check if all previous and next values are the same and not missing
                if all(prev_values == prev_values.iloc[0]) and all(next_values == next_values.iloc[0]) and prev_values.iloc[0] == next_values.iloc[0] and prev_values.iloc[0] != -1:
                    # Fill the missing value with the common sleep stage
                    df.loc[i, 'Event'] = prev_values.iloc[0]
        
        # Convert the 'Event' column back to string representations
        df['Event'] = df['Event'].apply(lambda x: 'SLEEP-S0' if x == 0.0 else
                                       'SLEEP-S1' if x == 1.0 else
                                       'SLEEP-S2' if x == 2.0 else
                                       'SLEEP-S3' if x == 3.0 else
                                       'SLEEP-S4' if x == 4.0 else
                                       'SLEEP-REM' if x == 5.0 else
                                       '-1')

        # Check that each 30-second interval has a corresponding label, and print a message if any intervals are missing.
        # Check if the time difference from the previous row is 30 seconds
        for i in range(1, len(merged_df)):
            prev_time = merged_df.iloc[i-1]["Time [hh:mm:ss]"]
            curr_time = merged_df.iloc[i]["Time [hh:mm:ss]"]
            time_diff = (curr_time - prev_time).total_seconds()
            
            if time_diff != 30:
                None
                #print("Time difference is not 30 seconds at row", i+1)
                
        # If the loop completes without printing anything, then there is a time value for every 30 seconds
        #print("Time values are present for every 30 seconds")

        # Check again if all labels are now there:

        # Get the starting time from the first row
        start_time = df.iloc[0]["Time [hh:mm:ss]"]

        # Loop through each row and check if the time difference from the previous row is 30 seconds
        for i in range(1, len(df)):
            prev_time = df.iloc[i-1]["Time [hh:mm:ss]"]
            curr_time = df.iloc[i]["Time [hh:mm:ss]"]
            time_diff = (curr_time - prev_time).total_seconds()
            
            if time_diff != 30:
                None
                #print("Time difference is not 30 seconds at row", i+1)
                #print(df.iloc[i]["Time [hh:mm:ss]"], time_diff)
                
        # If the loop completes without printing anything, then there is a time value for every 30 seconds
        #print("Time values are present for every 30 seconds")

        # Replace the string event labels with numbers:
        # Only use the time and the event column:
        df=df[["Time [hh:mm:ss]", "Event"]]
        # -1=no label, 0=wake, 1=S1, 2=S2, 3=S3, 4=S4, 5= REM
        df=df.replace('SLEEP-S0',0)
        df=df.replace('SLEEP-S1',1)
        df=df.replace('SLEEP-S2',2)
        df=df.replace('SLEEP-S3',3)
        df=df.replace('SLEEP-S4',4)
        df=df.replace('SLEEP-REM',5)

        # Get the count for -1.0 or default to 0 if not found
        missing_values_count = df['Event'].value_counts().get('-1', 0)

        # Print count for missing values (-1.0)
        print('Number of inserted values', missing_values_count, 'Recording length', len(df) / 2 / 60)
        
        # Only use the hh:mm:ss
        df['Time [hh:mm:ss]'] = df['Time [hh:mm:ss]'].dt.strftime('%H:%M:%S')

        # sleep_wake column (0 = wake; 1 = sleep)
        df['sleep_wake'] = df.loc[:, 'Event']
        df['sleep_wake']=df['sleep_wake'].replace(2,1)
        df['sleep_wake']=df['sleep_wake'].replace(3,1)
        df['sleep_wake']=df['sleep_wake'].replace(4,1)
        df['sleep_wake']=df['sleep_wake'].replace(5,1)

        # 3_stages column (0 = wake; 1 = NREM; 2 = REM)
        df['3_stages'] = df.loc[:, 'Event']
        df['3_stages']=df['3_stages'].replace(2,1)
        df['3_stages']=df['3_stages'].replace(3,1)
        df['3_stages']=df['3_stages'].replace(4,1)
        df['3_stages']=df['3_stages'].replace(5,2)

        # 4_stages column (0 = wake; 1 = Light; 2 = Deep; 3 = REM)
        df['4_stages'] = df.loc[:, 'Event']
        df['4_stages']=df['4_stages'].replace(2,1)
        df['4_stages']=df['4_stages'].replace(3,2)
        df['4_stages']=df['4_stages'].replace(4,2)
        df['4_stages']=df['4_stages'].replace(5,3)

        # 5_stages column (0 = wake; 1 = N1; 2 = N2; 3 = N3; 4 = REM)
        df['5_stages'] = df.loc[:, 'Event']
        df['5_stages']=df['5_stages'].replace(4,3)
        df['5_stages']=df['5_stages'].replace(5,4)

        # Add information to the first line
        header = ['length of the recording:', str(len(df)/2/60), 'hours']
        header_str = ','.join(header) + '\n'

        # Write the manipulated data to a new file with the same name and '_labels' added
        output_filename = os.path.splitext(filename)[0] + '_labels.csv'
        with open(os.path.join(output_folder_path, output_filename), 'w') as f:
            f.write(header_str)
            df.to_csv(f, index=False, lineterminator='\n')
