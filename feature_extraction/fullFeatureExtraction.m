% Extract all features from all samples in a directory

input_directory = '[path to iq_files]/iq_files/';
plot = false;
divisor = 8;

files = dir(strcat(input_directory, '**/*.iq'));
filenames = {files.name};
folders = {files.folder};

% Parse input directory for pairs of files

warning('off', 'MATLAB:table:RowsAddedExistingVars');

headers = {'File1', 'File2', 'Folder', 'freq_MHz', ...
    'relStr_dB', 'strDiff_dB', 'relDist_Hz', 'width_Hz', 'autoCorrelation_lag-2', 'alpha', ...
    'freq_MHz_2', 'relStr_dB_2', 'strDiff_dB_2', 'relDist_Hz_2', 'width_Hz_2', 'autoCorrelation_lag-2_2', 'alpha_2'}; %...
varTypes =  {'string', 'string', 'string', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
dataFeatures = table('Size', [0 length(varTypes)], 'VariableTypes',varTypes, 'VariableNames',headers);
for i = 1:1:size(filenames, 2)
    % Find all filenames that start with '288-1MHz'
    k = strfind(filenames{i}, '288-1MHz');
    if ~isempty(k)
        start = filenames{i}(1:k(1)-1);

        % Find a filename that has the same start (ie a_288-1MHz.iq and
        % a_<anything else>) --> make a pair and store into dataFeatures for
        % processing
        if i+1 ~= size(filenames, 2)+1
            k2 = strfind(filenames{i+1}, start);
            if ~isempty(k2) && all(folders{i} == folders{i+1})
                fprintf('\tPair found: %s\t%s\n', filenames{i}, filenames{i+1});
                oldsize = size(dataFeatures);
                newsize = oldsize(1) + divisor;
                dataFeatures.File1(oldsize+1:newsize) = filenames(i);
                dataFeatures.File2(oldsize+1:newsize) = filenames(i+1);
                dataFeatures.Folder(oldsize+1:newsize) = folders(i);
            end
        end
    end
end

warning('on', 'MATLAB:table:RowsAddedExistingVars');

clearvars files filenames folders i k k2 newsize oldsize start

% Manual clock freq
clock_freq_array = zeros(6, 2);

% Frequencies of clocks in spectrum, of devices in baseline test
% Arduino 1
clock_freq_array(1, 1) = 288.01352e6;
clock_freq_array(1, 2) = 304.01428e6;
% Arduino 2
clock_freq_array(2, 1) = 288.01722e6;
clock_freq_array(2, 2) = 304.01815e6;
% Arduino 3
clock_freq_array(3, 1) = 288.01380e6;
clock_freq_array(3, 2) = 304.01456e6;
% STM 1
clock_freq_array(4, 1) = 287.99587e6;
clock_freq_array(4, 2) = 303.99565e6;
% STM 2
clock_freq_array(5, 1) = 287.99878e6;
clock_freq_array(5, 2) = 303.99869e6;
% STM 3
clock_freq_array(6, 1) = 287.99593e6;
clock_freq_array(6, 2) = 303.99570e6;

% Run analysis on all files
for i = 1:1:size(dataFeatures, 1)/divisor
    % Features in 288 MHz band
    features_1 = extractFeatures(strcat(dataFeatures{((i-1)*divisor+1), 3}, ...
        '/', dataFeatures{((i-1)*divisor+1),1}), divisor, 500e3, 288.1e6, ...
        clock_freq_array(floor((i-1)/4)+1, 1), plot);

    % Features in 304 MHz band
    features_2 = extractFeatures(strcat(dataFeatures{((i-1)*divisor+1), 3}, ...
        '/', dataFeatures{((i-1)*divisor+1),2}), divisor, 500e3, 304.1e6, ...
        clock_freq_array(floor((i-1)/4)+1, 2), plot);

    dataFeatures.freq_MHz(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 1);
    dataFeatures.freq_MHz_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 1);
    
    dataFeatures.relStr_dB(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 2);
    dataFeatures.relStr_dB_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 2);
    
    dataFeatures.strDiff_dB(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 3);
    dataFeatures.strDiff_dB_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 3);

    dataFeatures.relDist_Hz(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 4);
    dataFeatures.relDist_Hz_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 4);

    dataFeatures.width_Hz(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 5);
    dataFeatures.width_Hz_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 5);

    dataFeatures.("autoCorrelation_lag-2")(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 6);
    dataFeatures.("autoCorrelation_lag-2_2")(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 6);

    dataFeatures.alpha(((i-1)*divisor+1):(i*divisor)) = features_1(:, 1, 7);
    dataFeatures.alpha_2(((i-1)*divisor+1):(i*divisor)) = features_2(:, 1, 7);

end
clearvars i

% Calculate the features that are dependent on multiple harmonics
relStr_freqDiff = rowfun(@calc_RelativeStr_and_freqDiff, dataFeatures, ...
    'InputVariables', {'relStr_dB', 'relStr_dB_2', 'freq_MHz', 'freq_MHz_2'}, ...
    'SeparateInputs',true, 'NumOutputs',2);

dataFeatures.strDiff_dB_2 = relStr_freqDiff.Var1;
dataFeatures.relDist_Hz_2 = relStr_freqDiff.Var2;


% Store data to csv file
writetable(dataFeatures, 'fullFeatureExtraction.csv');