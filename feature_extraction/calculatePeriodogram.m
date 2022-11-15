function [data, logdata] = calculatePeriodogram(samples, sampling_rate, center_freq, fft_size, window_size)
    % data: raw output of periodogram function
    % logdata: 10*log10(data) -- puts y axis into relative dB
    
    % How many windows fit in length of samples
    num_samples_avgd = floor(length(samples) / window_size);
    fprintf('Number of sets averaged: %d\n', num_samples_avgd);
    
    % Calculate periodograms for each window
    values = zeros(fft_size, num_samples_avgd);
    for c = 0:num_samples_avgd-1
        one_sample = samples((1+window_size*c):((c+1)*window_size));
        values(:, c+1) = periodogram(one_sample, blackmanharris(length(one_sample)), fft_size, sampling_rate, "centered", 'psd');
    end
    
    % Compute average over all the windows
    averaged = mean(values, 2);

    % Store into output arrays
    freqs = linspace(center_freq - sampling_rate/2, center_freq + sampling_rate/2, fft_size)';
    data = [freqs, averaged];
    logdata = [freqs, 10*log10(averaged)];

    % Output plots for debugging
%     plot(freqs, 10*log10(values(:,1)));
%     figure;
%    plot(freqs, averaged);
%     plot(freqs, 10*log10(values(:, 1)));
%     figure;
%     plot(freqs, 10*log10(values(:, 2)));
end