function [estimate_frequency,complexity] = simpleHjorth(test,Fs)
%% ============================= Inputs =================== %%
% test : is the input vector signal
% Fs : is the sampling freqeuncy used to derive the frequency from Radians
% to Hz.

%% ============================= Outputs ============================ %%
% estimate_freqeuncy : The estimated central freqeuncy
% complexity : Bandwidth of the signal

%% ================================ Method ============================ %%
% Hjorth et al first used the derivatives of the signal power to estimate
% the central frequency and bandwidth of EEG signals in real time to avoid
% using FFT which was imposible at that time to use in real time. For
% further information google Hjorth Parameters.
% If no input given a demo is shown by constructing a sine wave.
%% Author: Hooman sedghamiz   hooman.sedghamiz@gmail.com
% Version 1   August 2014.
%% ======================= Input handling =========================== %%
% -------------- Generate Sin wave with central frequency of 20 Hz ----- %
if nargin < 2
 Fs = 1000;
 % ------------- Generates Artificial Signal -------------- %%%
  if nargin < 1
     %------- Sampling frequency --------- %
      t = (0:2000-1)*1/Fs; 
     % ---- central frequency of your test signal-------- %
      Fc = 4;                                                              
      test = sin(2*pi*Fc*t);
     % ---------- uncomment to add noise --------------%
      %test = 100*test + randn(1,length(test));                            
  end
  
end

%--------------------- estimate frequency ----------------------------- %
dxV = diff(test);                                        % first derivative 
ddxV = diff(dxV);                                        % second derivative

%-------------------- moments of the signal ----------------------------- %
mx2 = mean(test.^2);                                     % variance or activity of the signal
mdx2 = mean(dxV.^2);                                     % second moment
mddx2 = 2*pi*mean(ddxV.^2);                              % fourth moment
mob = mdx2 / mx2;                                        % (second moment to zero moment) ratio

%------------- convert angular frequency (Radians) to Hertz(Hz)-----------%
radtoF = 0.1591549; 
estimate_frequency =  sqrt(mob)*radtoF*Fs;
complexity = (mddx2 / mdx2 - mob)*radtoF*Fs;
%-------------------------------------------------------------------------%
end