function [features] = extractFeatures(file, divisor, sampling_rate, center_freq, clock_freq, enable_plot)
    fprintf('\n\nFeature Extraction: %s\n', file);

    raw_samples = parseIQFile(file);
    split_samples = splitSamples(raw_samples, divisor);
    features = zeros(divisor, 1, 7);

    for i = 1:divisor

        % FFT Size to use
        fft_size = pow2(15);

        samples = split_samples{i};
        
        bucket_width = sampling_rate / fft_size;
        fprintf('FFT Size: %d\tBucket Width: %.3f Hz\t Est. Time: %.2f s\n', fft_size, bucket_width, length(samples) / sampling_rate);
        % Window size for averaging
        window_size = fft_size * 2;
        
        % Process data from IQ's into periodogram
        [data, logdata] = calculatePeriodogram(samples, sampling_rate, center_freq, fft_size, window_size);
        
        % sorted: Frequency and magnitude pairs in decreasing order of magnitude
        % sorted_index: Gain indices of data, in decreasing order of magnitude
        [sorted, sorted_index] = sortrows(logdata, 2, 'descend');
        
        % Get information about the noise floor
        floor_avg = mean(logdata(:,2));
        noise_floor = getNoiseFloor(logdata);
        fprintf('Noise Floor: %.2f dB\n', noise_floor);

        % Determine index of peak given:
        [peaks_found, peaks_found_idx] = findGivenPeak(clock_freq, logdata, 20, noise_floor);
    
        % Array to store filtered IQ samples
        filteredArray = zeros(1, length(samples));
        for j = 1:5000:(length(samples) - 5000)
            % Bandpass filter
            [filteredSamples] = bandpassFilter(samples(j:(j+5000)), peaks_found(1, 1), center_freq, sampling_rate);
            filteredArray(1, j:(j+5000)) = filteredSamples;
        end
        clearvars j
    
        % Compute auto correlation
        [acf, lags] = findAutoCorrelation(filteredArray);

        % Compute cyclostationary features
        [alpha, alpha_mean] = cyclostationarity(samples);
        
        % Compute widths of each clock present in spectrum
        [widths, width_points] = findClockWidths(peaks_found_idx, floor_avg, logdata);
        

        % Plot data if desired
        if enable_plot
            hold off;
            figure;
            plot(data(:, 1), logdata(:, 2));
            
            % Change limits to zoom into highest peak
            %xlim([(width_points(1,1) - 5*widths(1)) (width_points(2,1) + 5*widths(1))]);
            
            % Change title to filename
            warning('off', 'MATLAB:handle_graphics:exceptions:SceneNode');
            title(strcat('Feature Extraction: ', file));
            warning('on', 'MATLAB:handle_graphics:exceptions:SceneNode');
            
            % Overlay points to show calculated peak width and height
            hold on;
            plot(width_points(:, 1), (width_points(:, 2)), '.r');
            plot(data(peaks_found_idx, 1), logdata(peaks_found_idx, 2), '.g');
            plot(xlim, [noise_floor, noise_floor], ':m');
            hold off;
           
            % Code below: plot code that supports multiple peaks
    %         plot(width_points(:, 1), (width_points(:, 2)), '.r');
    %         plot(data(peaks_found_idx, 1), data(peaks_found_idx, 2), '.g');
    %         plot(xlim, [floor_avg, floor_avg], ':m');
    %         hold off;
        end
        
        % Store calculated features into output array
        % output: frequency, strength, relative strength, freq diff, width,
        % autocorrelation (2 lag), alpha
        features(i, :, 1:4) = peaks_found(1:length(peaks_found_idx), :);
        features(i, :, 5) = widths;
        features(i, :, 6) = acf(1,3);
        features(i, :, 7) = alpha;
    end

end