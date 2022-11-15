function [split_samples] = splitSamples(samples,divisor)
    % Splits samples into multiple sets

    % samples: input dataset in IQ form
    % divisor: number of sets to divide into

    split_samples = cell(divisor,1);
    samples_per = floor(length(samples) / divisor);
    for i = 1:divisor
        split_samples{i} = samples((samples_per * (i-1)+1):samples_per*i);
    end
end