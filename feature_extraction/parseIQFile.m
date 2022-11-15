function [samples] = parseIQFile(filename)
    % Open the file
    [f, msg]= fopen(filename, 'rb');
    
    % Stop if there is an error
    if f<1
        error([msg ' File: ' filename]), end
    
    % Obtain raw samples (I and Q together, in IQIQ format)
    rawSamples = fread(f, 'float');
    fclose(f);
    
    % Separate I and Q into separate structures
    realSamples = rawSamples(1:2:length(rawSamples));
    imagSamples = rawSamples(2:2:length(rawSamples));
    fprintf('Number of samples: %d samples\n', length(realSamples));
    
    % Create complex numbers by combining real and imag
    samples = realSamples + 1i*imagSamples;
end