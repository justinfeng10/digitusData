function [widths, width_points] = findClockWidths(peaks_found_idx, floor_avg, data)
    % Widths: holds up to 3 widths. If not 3 clocks, puts in zero
    widths = zeros(1, length(peaks_found_idx));
    width_points = zeros(length(peaks_found_idx) * 2, 2);
    % Which clock we are on
    count = 1;
    % Iterate through peaks found and find widths
    for current_peak_idx = peaks_found_idx
        % FIRST, find left and right bounds of clock using floor average as
        % threshold
        % Linear search to the left to find left bound
        left_freq = 0;
        left_idx = 0;
        for i = current_peak_idx:-1:1
            if data(i,2) < data(current_peak_idx, 2) * 0.05%floor_avg
                left_freq = data(i, :);
                left_idx = i;
                break;
            end
        end
        
        % Linear search to the right to find right bound
        right_freq = 0;
         right_idx = 0;
        for i = current_peak_idx:1:length(data)-1
            if data(i,2) < data(current_peak_idx, 2) * 0.05
                right_freq = data(i, :);
                right_idx = i;
                break;
            end
        end
        
        avg_window_size = 200;

        % Compute average on left sided window
        % If index out of bounds, use floor_avg instead
        if left_idx - avg_window_size >= 1
            averagedLeft = mean(data((left_idx - avg_window_size):left_idx, 2));
        else
            averagedLeft = floor_avg;
        end
        
        % Compute average on left sided window
        % If index out of bounds, use floor_avg instead
        if right_idx + avg_window_size <= length(data(:,  2))
            averagedRight = mean(data(right_idx:(right_idx + avg_window_size), 2));
        else
            averagedRight = floor_avg;
        end
    
        % Linear search to the left to find left bound
        left_freq_new = 0;
        for i = left_idx:-1:1
            if data(i,2) < averagedLeft
                left_freq_new = data(i, :);
                break;
            end
        end
        
        % Linear search to the right to find right bound
        right_freq_new = 0;
        for i = right_idx:1:length(data)
            if data(i,2) < averagedRight
                right_freq_new = data(i, :);
                break;
            end
        end

        
        
        % Compute width
        width = right_freq_new(:, 1) - left_freq_new(:, 1);
        % Store width
        widths(1,count) = width;
        
        width_points(2 * (count - 1) + 1, :) = left_freq_new(:);
        width_points(2 * count, :) = right_freq_new(:);

        count = count + 1;

        fprintf("Width of peak at %.6f MHz: %.2f Hz\n", data(current_peak_idx, 1) / 1000000, width);
    end

end