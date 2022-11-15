function [relStr, freqDiff] = calc_RelativeStr_and_freqDiff(str1, str2, freq1, freq2)
    % relStr: the strength ratio between band1 and band2
    % freqDiff: the difference in frequency between band1 peak and band2
    % peak
    relStr = str1 / str2 * 100;
    freqDiff = freq1 - freq2;
end