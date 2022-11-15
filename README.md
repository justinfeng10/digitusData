In this repository, you can compute the features for the baseline test as well as use the features as input to a Random Forest classifier.

## Raw IQ Files
Link: [folder](https://drive.google.com/drive/folders/1Ytof2DbcjHc__AgMm8bek-hAZzmmBmGZ?usp=sharing)

There are 5 rounds of data for the baseline test, labeled "day1", "day2", "morning", "noon", and "afternoon". Each round consists of data for six devices: 3 Arduino Unos and 3 STM 32's. We obtain data at two bands: 288MHz and 304MHz. 

## feature_extraction
This folder contains the feature extraction code that computes features given a folder of IQ files. The top level script is "fullFeatureExtraction.m", which takes in the filepath to a folder of IQ samples (one of "day1", "day2", etc...) as input and returns a .csv file of features.

## classifier
This folder contains the feature based classifier code as well as the computed feature .csv files for the baseline test. By running the cells in this notebook, we return the test accuracy and metrics for the baseline test.

## References
[1] Cyclic Spectral Analysis Toolbox: https://www.mathworks.com/matlabcentral/fileexchange/48909-cyclic-spectral-analysis/
