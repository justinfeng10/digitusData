function [acf, lags] = findAutoCorrelation(filteredArray)
%findAutoCorrelation computes the auto correlation for a set of samples
%   Auto Correlation computes similarity of the samples with itself, but
%   lagged
%   We return 2 values:
%   acf: the autocorrelation function values
%   lags: the amount of lag tested (starting at 0, increasing to 20 sample offset)
    [acfVal, lagsVal] = autocorr(filteredArray);
    acf = acfVal;
    lags = lagsVal;
end