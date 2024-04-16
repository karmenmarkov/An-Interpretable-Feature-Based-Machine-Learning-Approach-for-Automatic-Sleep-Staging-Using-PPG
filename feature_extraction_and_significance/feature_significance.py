"""
Feature Analysis and Significance Testing for Sleep Stage Classification

This script loads, processes, and analyzes PPG signal features to identify statistically significant differences across various sleep stage classifications. It handles multiple stages of sleep by applying statistical tests to determine the features' significance in distinguishing between stages such as Wake, NREM, and REM.

Key operations:
1. Loads feature data from CSV files.
2. Adjusts stage labels for binary, ternary, and other classification schemes.
3. Checks for statistical normality.
4. Applies t-tests or non-parametric tests depending on data normality.
5. Outputs results including significant features for further analysis.

Usage:
- Ensure that the 'directory_path' variable points to the directory containing feature CSV files.
- Adjust the stage labeling according to the specifics of your dataset and analysis needs.
"""


import pandas as pd
import numpy as np
from scipy.stats import shapiro, ttest_ind, mannwhitneyu
from scipy.stats import shapiro, f_oneway, kruskal
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from scikit_posthocs import posthoc_dunn
import statsmodels.api as sm
from statsmodels.formula.api import ols
import os


# Import the features
# Specify the directory containing your CSV files
directory_path = 'path/to/your/extracted_features/'

# Function to extract subjectID
def extract_subject_id(file_name):
    """
    Extract the subject ID from the filename, handling different naming conventions.
    """
    # Define a list of possible suffixes in filenames
    suffixes = ["_features.csv", "_lc_features.csv", "_RRandDET_features.csv"]
    
    # Try to remove each suffix from the filename
    for suffix in suffixes:
        if suffix in file_name:
            # Remove the suffix and any additional underscore-separated parts
            stripped_name = file_name.replace(suffix, "")
            # Handle additional naming parts like '_lc' or '_RRandDET'
            # This assumes the subject ID does not contain underscores
            subject_id_parts = stripped_name.split('_')
            return subject_id_parts[0]  # Assuming the first part is always the subject ID
    
    # Default case if none of the known suffixes are found
    # This also handles cases without additional parts like '_lc' or '_RRandDET'
    return file_name.split('.')[0]


# Initialize an empty DataFrame to hold merged data
df_features = pd.DataFrame()

# Loop through each file in the specified directory
for file_name in os.listdir(directory_path):
    # Construct the full file path
    file_path = os.path.join(directory_path, file_name)
    
    # Check if the file is a CSV file
    if file_path.endswith('.csv'):
        # Read the CSV file into a DataFrame
        temp_df = pd.read_csv(file_path)
        
        # Extract subject ID from the filename
        subject_id = extract_subject_id(file_name)
        
        # Check if the DataFrame has the expected number of columns (333 in this case)
        if temp_df.shape[1] == 333:
            # Add a column for SubjectID at the beginning of the DataFrame
            temp_df.insert(0, 'SubjectID', subject_id)
            
            # Append the data from this file to the merged DataFrame
            df_features = pd.concat([df_features, temp_df], ignore_index=True)
        else:
            print(f"File {file_name} does not have the expected number of columns and was skipped.")

print(f"The merged DataFrame has {df_features.shape[0]} rows and {df_features.shape[1]} columns.")


# Adjust sleep stage labels to fit different classification schemes
# These blocks clarify how labels are modified to fit binary, ternary, etc., models
# 2_stages column (0 = wake; 1 = sleep)
df_features['2_stages'] = df_features.loc[:, 'Label']
df_features['2_stages']=df_features['2_stages'].replace(2,1)
df_features['2_stages']=df_features['2_stages'].replace(3,1)
df_features['2_stages']=df_features['2_stages'].replace(4,1)
df_features['2_stages']=df_features['2_stages'].replace(5,1)

# 3_stages column (0 = wake; 1 = NREM; 2 = REM)
df_features['3_stages'] = df_features.loc[:, 'Label']
df_features['3_stages']=df_features['3_stages'].replace(2,1)
df_features['3_stages']=df_features['3_stages'].replace(3,1)
df_features['3_stages']=df_features['3_stages'].replace(4,1)
df_features['3_stages']=df_features['3_stages'].replace(5,2)

# 4_stages column (0 = wake; 1 = Light; 2 = Deep; 3 = REM)
df_features['4_stages'] = df_features.loc[:, 'Label']
df_features['4_stages']=df_features['4_stages'].replace(2,1)
df_features['4_stages']=df_features['4_stages'].replace(3,2)
df_features['4_stages']=df_features['4_stages'].replace(4,2)
df_features['4_stages']=df_features['4_stages'].replace(5,3)

# 5_stages column (0 = wake; 1 = N1; 2 = N2; 3 = N3; 4 = REM)
df_features['5_stages'] = df_features.loc[:, 'Label']
df_features['5_stages']=df_features['5_stages'].replace(4,3)
df_features['5_stages']=df_features['5_stages'].replace(5,4)

# Remove rows with label -1
df_features = df_features[df_features['Label'] != -1]

# Drop labels column
df_features = df_features.drop(columns=['Label'])


# 2 Stages

# After loading data, perform Exploratory Data Analysis (EDA)

# Get the feature columns excluding the 'subjectID' column
feature_columns = df_features.columns[1:333]  # Assuming subjectID is the first column

# Check for normality within each class
normality_results = {}
for feature in feature_columns[:333]:
    for class_label, class_data in df_features.groupby('2_stages'):
        data = class_data[feature].dropna()
        if data.nunique() > 1:  # Check if there's more than one unique value
            stat, p_value = shapiro(data)
            normality_results[(feature, class_label)] = p_value
        else:
            normality_results[(feature, class_label)] = np.nan  # Use NaN to indicate no variability

# Perform t-test or Mann-Whitney U test based on normality
# Initialize a list to store the results
significant_features_results = []

# Corrected alpha for Bonferroni correction
alpha = 0.05 / len(feature_columns[:333]) 

for feature in feature_columns[:333]:
    group1 = df_features[df_features['2_stages'] == 0][feature]
    group2 = df_features[df_features['2_stages'] == 1][feature]

    # Check normality first to decide which statistical test to apply
    if all(np.isnan(normality_results[(feature, class_label)]) for class_label in [0, 1]):
        # If there's no variability in both classes, significance testing is not meaningful
        p_value = np.nan # Skip testing if no variability
        sleep_larger = "Not Applicable"
        is_significant = "No"
    else:
        if all(normality_results[(feature, class_label)] < alpha for class_label in [0, 1]):
            # If normally distributed in both classes, use t-test
            stat, p_value = ttest_ind(group1, group2, nan_policy='omit')
        else:
            # If not normally distributed in one or both classes, use Mann-Whitney U test
            stat, p_value = mannwhitneyu(group1, group2)

        # Determine if sleep is smaller or larger than wake
        sleep_larger = "Yes" if group2.mean() > group1.mean() else "No"
    
        # Determine significance with corrected alpha
        is_significant = "Yes" if p_value < alpha else "No"

    # Append results
    significant_features_results.append({
        'Feature': feature,
        'p-value': p_value,
        'Significant': is_significant,
        'Sleep Larger Than Wake': sleep_larger
    })

# Save the results of significant features and their corresponding data to new CSV files
# This makes it easy to use the processed data for model training
results_df_2stages = pd.DataFrame(significant_features_results) # Convert results to DataFrame
significant_features = results_df_2stages[results_df_2stages['Significant'] == 'Yes']['Feature'] # Select significant features
final_df_2_stages = df_features[['2_stages'] + significant_features.tolist()] # Select features from the original df
final_df_2_stages.reset_index(drop=True, inplace=True) # Reset index
final_df_2_stages.to_csv('final_df_2_stages_nonstand.csv', index=False) # Save the final df for model training
results_df_2stages.to_csv('significance_2_stages_nonstand.csv', index=False) # Save the significant features table

# 3, 4 and 5 stages

# Define the function to get significant features for the specified level of classification
def analyze_stages(df_features, stage_column, output_prefix):
    """
    Analyze different stages for statistical significance.

    Args:
    df_features (DataFrame): DataFrame containing the data to analyze.
    stage_column (str): Column name for the stages in `df_features`.
    output_prefix (str): Prefix for output file names.

    Returns:
    None
    """
    # Initialize a DataFrame to store ANOVA results with all features
    results_df = pd.DataFrame(index=df_features.columns[1:333])
    results_df['p-value'] = np.nan
    results_df['Significant'] = 'No'  # Initialize all as 'No'
    results_df['Normality'] = 'Not Checked'  # Track normality checks

    # Perform normality check and ANOVA or Kruskal-Wallis test for each feature
    for feature in df_features.columns[1:333]:
        groups = [df_features[df_features[stage_column] == stage][feature].dropna() for stage in np.unique(df_features[stage_column])]
        
        # Check normality for each group in the feature
        normal = all(shapiro(group)[1] > 0.05 for group in groups if len(group) > 3)
        results_df.at[feature, 'Normality'] = 'Yes' if normal else 'No'
        
        # Choose test based on normality
        if normal:
            f_stat, p_value = f_oneway(*groups)
        else:
            f_stat, p_value = kruskal(*groups)
        
        results_df.at[feature, 'p-value'] = p_value

    # Proceed with appropriate post-hoc tests where the initial test showed significance
    for feature in results_df.index:
        if results_df.loc[feature, 'p-value'] < 0.05:
            data_for_posthoc = df_features[[feature, stage_column]].dropna()
            if results_df.loc[feature, 'Normality'] == 'Yes':
                tukey = pairwise_tukeyhsd(endog=data_for_posthoc[feature], groups=data_for_posthoc[stage_column], alpha=0.05)
                results_df.at[feature, 'Significant'] = 'Yes' if any(tukey.reject) else 'No'
            else:
                p_vals = posthoc_dunn(data_for_posthoc, group_col=stage_column, val_col=feature, p_adjust='bonferroni')
                results_df.at[feature, 'Significant'] = 'Yes' if (p_vals < 0.05).any().any() else 'No'

    # Reset the index to turn the index into a column
    results_df.reset_index(inplace=True)
    results_df.rename(columns={'index': 'Feature'}, inplace=True)

    # Select only the significant features
    significant_features = results_df[results_df['Significant'] == 'Yes']['Feature']

    # Select these features from the original dataframe
    final_df = df_features[[stage_column] + significant_features.tolist()]
    final_df.reset_index(drop=True, inplace=True)

    # Save the final df for model training and significant features table
    final_df.to_csv(f'{output_prefix}_final_df.csv', index=False)
    results_df.to_csv(f'{output_prefix}_significance.csv', index=False)

# Execute statistical tests and output results for different staging systems
analyze_stages(df_features, '3_stages', '3_stages_nonstand')
analyze_stages(df_features, '4_stages', '4_stages_nonstand')
analyze_stages(df_features, '5_stages', '5_stages_nonstand')
