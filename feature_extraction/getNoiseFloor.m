function [noise_floor, top_count] = getNoiseFloor(logdata)
    % noise_floor: estimated level of noise floor in dB
    % top_count: number of datapoints in top histogram bin (A very low
    % number here indicates low confidence)

    % Calculate the histogram bin counts of the data
    [n, edges] = histcounts(logdata(:,2));

    % Find the bin with the largest count
    [top_count, top_index] = max(n);

    % Obtain the center frequency for that bin
    noise_floor = edges(top_index+1) + 0.5 * (edges(top_index + 2) - edges(top_index + 1));
end