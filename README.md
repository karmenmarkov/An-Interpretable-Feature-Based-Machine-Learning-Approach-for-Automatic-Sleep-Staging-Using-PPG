# An Interpretable Feature-Based Machine Learning Approach for Automatic Sleep Staging Using PPG


## Project Overview
This project aims to develop an interpretable, feature-based classifier for automatic sleep staging using Photoplethysmography (PPG) data. Unlike prevalent neural network approaches that offer high accuracy but limited interpretability, this project focuses on using traditional machine learning models that provide clear insights into the features influencing sleep stage classification. This approach enhances the clinical applicability of PPG-based sleep analysis in wearable technologies, making it a valuable tool for both research and practical applications in sleep medicine.

## Dataset
We utilize the CAP Sleep Database available on PhysioNet (https://physionet.org/content/capslpdb/1.0.0/), which includes data from 84 participants with various pathologies affecting sleep. The dataset provides a rich source for extracting PPG signals and corresponding sleep stages, facilitating comprehensive analyses and model training.

## Participant Demographics

| Category                    | Female          | Male            | Total           |
|-----------------------------|-----------------|-----------------|-----------------|
| **Participants**            | 33              | 51              | 84              |
| **Age**                     | 41.4 ± 16.8 (16-76) | 48.7 ± 21.1 (14-82) | 45.8 ± 19.7 (14-82) |
| **Pathology Distribution**  |                 |                 |                 |
| No Pathology                |                 |                 | 4               |
| Insomnia                    |                 |                 | 7               |
| Narcolepsy                  |                 |                 | 4               |
| Nocturnal Frontal Lobe Epilepsy |             |                 | 39              |
| Periodic Leg Movement       |                 |                 | 9               |
| REM Behavior Disorder       |                 |                 | 18              |
| Sleep Disordered Breathing  |                 |                 | 3               |


## Epoch Distribution
**Total Epochs**: 85,542
* Wake: *n* = 16,128 (19%)
* N1: *n* = 3,676 (4%)
* N2: *n* = 30,843 (36%)
* N3: *n* = 20,428 (24%)
* REM: *n* = 14,467 (17%)

<img width="1307" alt="image" src="https://github.com/kmarkoveth/PPG/assets/103241042/c9a86e83-f879-4b54-8e6d-d8fc14bbd9c2">


## Repository Structure
This repository is organized into three main sections, each with a dedicated README file that provides detailed instructions and explanations:
* **Preprocessing**: Scripts for data cleaning, signal inversion, and synchronization of PPG signals with sleep stage labels. [Read more](https://github.com/kmarkoveth/PPG/tree/main/preprocessing)
* **Feature Extraction and Significance**: Techniques for deriving significant features from the PPG data and evaluating their relevance to sleep stages. [Read more](https://github.com/kmarkoveth/PPG/tree/main/feature_extraction_and_significance)
* **Model Training**: Application of machine learning models to classify sleep stages based on extracted features. Read more

![Blank diagram](https://github.com/kmarkoveth/PPG/assets/103241042/793f5de5-cc5e-40a0-bd72-e19716ae60f7)


## Goals and Objectives
Extract and analyze features from PPG data that significantly impact sleep stage classifications.
Develop interpretable machine learning models that can effectively differentiate between various sleep stages.
Enhance clinical applicability of sleep stage detection using non-invasive PPG signals, contributing to improved diagnostics and patient monitoring in sleep medicine.

## Dependencies
* MATLAB (R2021a or later recommended)
  * Additional toolboxes and custom functions are listed in specific READMEs linked above.
* Python 3.8+
  * pandas==1.3.3
  * numpy==1.21.2
  * scipy==1.7.1
  * statsmodels==0.12.2
  * scikit-posthocs==0.6.7
  * seaborn==0.11.2
  * matplotlib==3.4.3
  * scikit-learn==0.24.2
  * imbalanced-learn==0.8.0
  * pyedflib==0.1.36

## Usage
To use this repository:
* Clone the repo: git clone https://github.com/kmarkoveth/PPG.git
* Navigate to each section and follow the setup instructions detailed in the respective README files.

## Acknowledgements
This project was supervised by Dr. Mohamed Elgendi, whose expertise and guidance were instrumental in the research and development of the methodologies used. We thank all contributors and participants of the CAP Sleep Database.

## Contact Info

If you have any questions about the code, please contact Karmen at kkarmenmarkov@gmail.com and Dr. Elgendi at moe.elgendi@gmail.com via email
