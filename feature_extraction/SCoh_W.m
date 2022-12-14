function Coh = SCoh_W(y,x,alpha,nfft,Noverlap,Window,opt,P)     
% NOTE: this function is from the Cyclic Spectral Analysis Toolbox: https://www.mathworks.com/matlabcentral/fileexchange/48909-cyclic-spectral-analysis/)
% Coh = SCoh_W(y,x,alpha,nfft,Noverlap,Window,opt,P)
% Welch's estimate of the Cyclic Spectral Coherence of signals y and x 
% at cyclic frequency alpha (normalized by sampling frequency):  
% opt = 'sym' : symmetric version E{Y(f+alpha/2)X*(f-alpha/2)}/sqrt(E|Y(f+alpha/2)|²E|X*(f-alpha/2)|²)
% opt = 'asym': asymmetric version E{Y(f)X*(f-alpha)}/sqrt(E|Y(f)|²E|X*(f-alpha)|²)
% (f and alpha are normalized by the sampling frequency and constrained to take values between 0 and 1)
% x and y are divided into K overlapping blocks (Noverlap taps), each of which is
% detrended, windowed and zero-padded to length nfft. Input arguments nfft, Noverlap, and Window
% are as in function 'PSD' or 'PWELCH' of Matlab. Denoting by Nwind the window length, it is recommended to use 
% nfft = 2*NWind and Noverlap = 2/3*Nwind with a hanning window or Noverlap = 1/2*Nwind with a half-sine window.
% Note: use analytic signal to avoid correlation between + and - frequencies
%
% SCoh_W calls function 'CPS_W'.
%
% -------
% Outputs
% -------
% Coh is a structure organized as follows:
%                   Coh.C = Cyclic Spectral Coherence
%                   Coh.Syx = Cross Cyclic Spectral Density
%                   Coh.Sy and Coh.Sx = Cyclic Spectral Densities of signals y and x
%                   Coh.f = vector of frequencies
%                   Coh.K = number of blocks
%                   Coh.Var_Reduc = Variance Reduction factor
%                   Coh = CPS_W(y,x,...,P) where P is a scalar between 0 and 1, 
%                   also returns Coh.thres the P*100% significance level
%                   for testing against H0: |Coh.S|^2 = 0
%                   (requires function 'chi2inv' of the statistical toolbox of Matlab)
% 
% --------------------------
% Reference: J. Antoni, "Cyclic Spectral Analysis in Practice", Mechanical Systems and Signal Processing, Volume 21, Issue 2, February 2007, Pages 597-630.
% --------------------------
% Author: J. Antoni
% Last Revision: 12-2014
% --------------------------

if length(Window) == 1
    Window = hanning(Window);
end
Window = Window(:);
n = length(x);
nwind = length(Window);

% check inputs
if (alpha>1)||(alpha<0),error('alpha must be in [0,1] !!'),end
if nwind <= Noverlap,error('Window length must be > Noverlap');end
if nfft < nwind,error('Window length must be <= nfft');end
if (nargin>7) && (P>=1 || P<=0),error('P must be in ]0,1[ !!'),end

y = y(:);
x = x(:);

t = (0:n-1)';
if strcmp(opt,'sym') == 1
    y = y.*exp(-1i*pi*alpha*t);
    x = x.*exp(1i*pi*alpha*t);
else
    x = x.*exp(2i*pi*alpha*t);
end

Syx = CPS_W(y,x,0,nfft,Noverlap,Window,opt);    
Sy = CPS_W(y,y,0,nfft,Noverlap,Window,opt);     
Sx = CPS_W(x,x,0,nfft,Noverlap,Window,opt);     
Coh.K = Sx.K;   
Coh.f = Sx.f;   

Coh.Syx = Syx.S;
Coh.Sy = Sy.S;
Coh.Sx = Sx.S;
Coh.C = Syx.S./sqrt(Sy.S.*Sx.S);

% variance reduction factor
Window = Window(:)/norm(Window);
Delta = nwind - Noverlap;
R2w = xcorr(Window);
k = nwind+Delta:Delta:min(2*nwind-1,nwind+Delta*(Coh.K-1));
if length(k) >1
    Coh.Var_Reduc = R2w(nwind)^2/Coh.K + 2/Coh.K*(1-(1:length(k))/Coh.K)*(R2w(k).^2);
else
    Coh.Var_Reduc = R2w(nwind)^2/Coh.K;
end

% threshold on square magnitude at P significance level under H0
if nargin > 7
    Coh.thres = chi2inv(1-P,2)*Coh.Var_Reduc/2;
end

% set up output parameters
if nargout == 0
    figure,newplot;
    subplot(211),plot(Coh.f(1:nfft/2+1),abs(Coh.C(1:nfft/2+1)).^2), grid on
    if nargin > 7,
        hold on,plot(Coh.f(1:nfft/2+1),Coh.thres,':r'),
        title(['Spectral Coherence (squared magnitude) and threshold at ',num2str(100*P),'% level of significance'])
    else
        title('Spectral Coherence (squared magnitude)')
    end
    subplot(212),plot(Coh.f(1:nfft/2+1),angle(Coh.C(1:nfft/2+1))), grid on
    xlabel('[Hz]'),title('Phase')
end
