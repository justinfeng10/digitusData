function [peaks_found, peaks_found_idx] = findGivenPeak(clock_freq, data, search_range, noise_floor)
    % Get bin closest to given frequency
    [ peak, given_peak_idx ] = min( abs( data(:, 1)-clock_freq ));

    fprintf("clock freq: %f\n", clock_freq);
    fprintf("given peak idx: %f\n", given_peak_idx);
        
    % Search given range for highest value
    [ peak, peak_idx] = max( data( (given_peak_idx - search_range):(given_peak_idx + search_range), 2) );
    
    % Fix indexing
    peak_idx = peak_idx - search_range + given_peak_idx - 1;

    % Put in correct output format
    peaks_found = [data(peak_idx, 1), data(peak_idx, 2) - noise_floor, 0, 0];
    peaks_found_idx = [peak_idx];
    
end