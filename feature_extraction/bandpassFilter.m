function [filteredSamples] = bandpassFilter(samples, clock_freq, center_freq, sampling_rate)
%bandPassFilter given IQ samples and a clockFreq, filters signal
%   We compute:
%   filteredSamples: the set of IQ that has been filtered to preserve clock

    % Convert clockFreq to baseband
    basebandClockFreq =  center_freq - clock_freq;

    % Compute lower frequency and upper frequency bound
    lowFreqBound = basebandClockFreq - 5000;
    highFreqBound = basebandClockFreq + 5000;

    % Make sure lower and upper frequency in bounds
    if lowFreqBound < 0
        lowFreqBound = 0;
    end
    if highFreqBound > (sampling_rate / 2)
        highFreqBound = sampling_rate / 2;
    end

    % Filter the data
    %filteredSamples = bandpass(samples, [lowFreqBound highFreqBound], sampling_rate);

    % IIR Bandpass Filter
    Wn = [lowFreqBound, highFreqBound] / (sampling_rate / 2);
    [B, A] = butter(3, Wn);
    filteredSamples = filter(B, A, samples);
end