# Overview
This repository contains the training of models for sleep stage classification. The primary stages of this project include correlation analysis, feature selection, hyperparameter tuning, model training with cross-validation, and feature importance analysis. Below is a detailed description of each step involved in the process.


# 2-stage classification

## Correlation Analysis
We start by performing a correlation analysis on the dataset to identify and remove highly correlated features. The steps include:

* Loading the dataset.
* Imputing missing values using the mean strategy.
* Calculating the correlation matrix.
* Plotting a heatmap of the correlation matrix.
* Identifying and removing features with a correlation greater than 0.95.

## Preparing X, y, and Groups
The dataset is prepared for model training and evaluation:

* Extract Features: Drop the label column (2_stages) to isolate the features.
* Load Subjects: Read the subject information from a separate file and merge it with the feature data.
* Assign X, y, and Groups:
  * X: Feature matrix.
  * y: Labels (sleep stages).
  * groups: Subject IDs for group-based cross-validation.

## Balancing the Dataset
The class distribution in the dataset is imbalanced, with a significant difference between the number of wake and sleep instances. This imbalance is addressed during model training and evaluation using various techniques for balancing the classes. Different balanced datasets are created using the following methods:

* No balancing:
 * Dataset: [df_2_stages_None.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_2_stages_None.ipynb)
 * Method: The dataset is used as-is without any balancing.
* ADASYN:
  * Dataset: [df_2_stages_ADASYN.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_2_stages_ADASYN.ipynb)
  * Method: Adaptive Synthetic Sampling (ADASYN) is used to generate synthetic samples for the minority class. This technique adaptively generates more synthetic data for minority class instances that are harder to learn, thus improving the classifier's performance on imbalanced datasets.
* Random Under-Sampling (RUS):
  * Dataset: [df_2_stages_RUS.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_2_stages_RUS.ipynb)
  * Method: Random Under-Sampling (RUS) is used with default settings. This technique randomly removes instances from the majority class to balance the class distribution, which can help improve the performance of the classifier by reducing the bias towards the majority class.
* SMOTE:
  * Dataset: [df_2_stages_SMOTE.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_2_stages_SMOTE.ipynb)
  * Method: Synthetic Minority Over-sampling Technique (SMOTE) is used with default settings. SMOTE generates synthetic samples by interpolating between existing minority class instances, helping to balance the class distribution and improve the classifier's performance on the minority class.

Each of these techniques is applied to create balanced datasets, which are then used for model training and evaluation to ensure that the classifier performs well across both classes. In the [df_2_stages_None.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_2_stages_None.ipynb) the classes remain imbalanced and the imbalanced dataset is used for further steps.

## Feature Selection
A Random Forest classifier is used for feature selection:
* Initialize and Fit: Fit a RandomForestClassifier to the feature matrix X and labels y.
* Select Features: Identify important features based on the feature importances derived from the Random Forest model.
* Update Feature Matrix: Select the top features and update X accordingly.

## Hyperparameter Tuning
Hyperparameter tuning is performed in two stages:
* Randomized Search:
  * Use 50% of the data for quick exploration.
  * Define a parameter distribution and perform a RandomizedSearchCV with GroupKFold cross-validation.
  * Identify the best hyperparameters.
* Grid Search:
  * Use the results from the randomized search to define a parameter grid.
  * Perform a GridSearchCV on the entire dataset using GroupKFold cross-validation.
  * Determine the best hyperparameters for the final model.

## Model Training
Models are trained and evaluated using different cross-validation strategies:

* 5-fold Cross-Validation
  * Train and Evaluate: Train the model using GroupKFold with 5 splits.
  * Metrics: Calculate and collect metrics such as accuracy, sensitivity, specificity, precision, F1 score, and MCC for each fold.
  * Confusion Matrix: Generate a confusion matrix for the overall performance.
* 10-fold Cross-Validation
  * Similar to 5-fold CV, but using 10 splits.
* 20-fold Cross-Validation
  * Similar to 5-fold CV, but using 20 splits.

## Overall Feature Importance Analysis
Feature importance is calculated for each cross-validation strategy and averaged to determine the overall importance of features. This involves:

* Collect Feature Importances: Extract feature importances from each cross-validation strategy.
* Average Importances: Calculate the mean importance across different cross-validation methods.
* Visualization: Plot the top 20 most important features based on their averaged importance.
* Feature Distribution: Plot histograms and boxplots for the top-performing features to visualize their distribution across different classes (wake and sleep).


# Multistage classification

## Correlation Analysis
Same as for 2-stage classification.

## Preparing X, y, and Groups
Same as for 2-stage classification.

## Balancing the Dataset
The class distribution in the dataset is imbalanced. Different techniques are used to balance the classes:

* No Balancing:
 * Dataset: [df_3_stages_None.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_3_stages_None.ipynb), [df_4_stages_None.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_4_stages_None.ipynb), [df_5_stages_None.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_5_stages_None.ipynb)
 * Method: The dataset is used as-is without any balancing.
* Random Under-Sampling (RUS):
 * Dataset: [df_3_stages_RUS.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_3_stages_RUS.ipynb), [df_4_stages_RUS.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_4_stages_RUS.ipynb), [df_5_stages_RUS.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_5_stages_RUS.ipynb)
 * Method: Random Under-Sampling (RUS) is used with default settings. This technique randomly removes instances from the majority class to balance the class distribution.
* SMOTE:
 * Dataset: [df_3_stages_SMOTE.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_3_stages_SMOTE.ipynb), [df_4_stages_SMOTE.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_4_stages_SMOTE.ipynb), [df_5_stages_SMOTE.ipynb](https://github.com/kmarkoveth/PPG/blob/main/model_training/df_5_stages_SMOTE.ipynb)
 * Method: Synthetic Minority Over-sampling Technique (SMOTE) is used with default settings. SMOTE generates synthetic samples by interpolating between existing minority class instances.

## Feature Selection
Same as for 2-stage classification.

## Hyperparameter Tuning
Same as for 2-stage classification.

## Model Training
Same as for 2-stage classification.

## Overall Feature Importance Analysis
Feature importance is calculated for each cross-validation strategy using a one-vs-all approach and averaged to determine the overall importance of features. This involves:

* **One-vs-All Model for Feature Importances:** Using OneVsRestClassifier with a Random Forest classifier, train a separate model for each stage where that stage is treated as the positive class and all other stages are treated as the negative class. For each model, extract the feature importances specific to that stage.
* **Collect Feature Importances:** Extract feature importances from each cross-validation strategy using OneVsRestClassifier.
* **Average Importances:** Calculate the mean importance across different cross-validation methods.
* **Visualization:** Plot the top 5 features for each stage based on their averaged importance.
* **Feature Distribution:** Plot histograms and boxplots for the top-performing features to visualize their distribution across different classes.

