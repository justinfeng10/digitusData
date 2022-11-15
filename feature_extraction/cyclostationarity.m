function [alpha, alphaMean] = cyclostationarity(data)
% NOTE: this function is modified from the Cyclic Spectral Analysis Toolbox: https://www.mathworks.com/matlabcentral/fileexchange/48909-cyclic-spectral-analysis/)
%cyclostationarity: computes the alpha, or alpha mean with max coherence
%   Detailed explanation goes here
    % Illustrates usage of 'SCoh_W' on a synthetic signal
    % ---------------------------------------------------
    % This example illustrates the detection of a cyclostationary signal deeply
    % buried in stationary noise; its theoretical spectral content is in band 
    % [.15 .25] and its cyclic frequency is alpha = .00125.
    % 
    % --------------------------
    % Author: J. Antoni
    % Last Revision: 12-2014
    % --------------------------
    
    x = data(1:100000);
    L = length(x);		% signal length
    Nw = 256;			% window length
    Nv = fix(2/3*Nw);	% block overlap
    nfft = 2*Nw;		% FFT length
    da = 1/L;           % cyclic frequency resolution
    a1 = 51;            % first cyclic freq. bin to scan (i.e. cyclic freq. a1*da)
    a2 = 200;           % last cyclic freq. bin to scan (i.e. cyclic freq. a2*da)
    
    % Loop over cyclic frequencies
    C = zeros(nfft,a2-a1+1);
    S = zeros(nfft,a2-a1+1);
    Q = ~strcmp(which('chi2inv'),'')==1; % check if function 'chi2inv' is available
    % New variables
    counter = 1;
    currMax = 0;
    currAlpha = 0;
    currIndex = 0;
    intermediateMax = 0;
    intermediateIndex = 0;
    intermediateMean = 0;
    currMean = 0;
    currAlphaMean = 0;
    for k = a1:a2;
        if Q == 1
            Coh = SCoh_W(x,x,k/L,nfft,Nv,Nw,'sym',.01);
        else
            Coh = SCoh_W(x,x,k/L,nfft,Nv,Nw,'sym');
        end
        %New code: find max coherence and its corresponding bin
        [intermediateMax, intermediateIndex] = max(abs(Coh.Syx).^2);
        intermediateMean = mean(abs(Coh.Syx).^2);
        if intermediateMax > currMax
            currMax = intermediateMax;
            currAlpha = counter;
            currIndex = intermediateIndex;
        end
        if intermediateMean > currMean
            currMean = intermediateMean;
            currAlphaMean = counter;
        end
        counter = counter + 1;
        %End new code
	    C(:,k-a1+1) = Coh.C;
	    S(:,k-a1+1) = Coh.Syx;
	    %waitbar((k-a1+1)/(a2-a1+1))
    end

    % Save and return results
    alpha = currAlpha;
    alphaMean = currAlphaMean;
end
