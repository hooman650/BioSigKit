function alarm = envelop_hilbert(y,Smooth_window,threshold_style,DURATION,gr)
%% function alarm = envelop_hilbert(y,Smooth_window,threshold_style,DURATION,gr)
%% ======================= Inputs ================================ %%
% y = Raw input signal to be analyzed
% Smooth_window :this is the window length used for smoothing your signal
% in terms of number of samples
% threshold_style : set it 1 to have an adaptive threshold OR set it 0
% to manually select the threshold from a plot
% DURATION : Number of the samples that the signal should stay in terms of
% number of samples
% gr = make it 1 if you want a plot and 0 when you dont want a plot

%===========================================
% Tuning parameters for the best results;
%===========================================
% 1. DURATION is correlated to your sampling frequency, you can use a multiple
% of your sampling frequency e.g. round(0.050*SamplingFrequency)
% 2. Smooth_window is correlated to your sampling frequency, you can use a multiple
% of your sampling frequency e.g. round(0.0500*SamplingFrequency), this is
% the window length used for smoothing your signal

%% ======================= Outputs ================================== %%
% alarm : vector resembeling the active parts of the signal
%% ======================= Method =================================== %%
% Calculates the analytical signal with the help of hilbert transfrom,
% takes the envelope and smoothes the signal. Finally , with the help of an
% adaptive threshold detects the activity of the signal where at least a
% minimum number of samples with the length of 
% (DURATION) Samples should stay above the threshold). The threshold is a
% computation of signal noise and activity level which is updated online.

%% Example and Demo
% To run demo mode simply execute the following line without any input;
% Example 1 :
% alarm = envelop_hilbert()
% The script generates one artificial signal and analysis that
% v = repmat([.1*ones(200,1);ones(100,1)],[10 1]); % generate true variance profile
% y = sqrt(v).*randn(size(v));

% Example 2 : For real world signals with a certain Sampling frequency
% called (Fs) (In this example a smoothing window with length 200 msec,)
% alarm = envelop_hilbert(signal,round(0.050*Fs),1,round(0.020*Fs),1)

%% Author : Hooman Sedghamiz 
% hoose792@student.liu.se
% Copy right April 2013
% Edited March 2014

%%

%--------------------------- input handling ---------------------------%
if nargin < 5
    gr = 1;
    if nargin < 4
        DURATION = 20;                                                     % default
        if nargin < 3
           threshold_style = 1;                                            % default 1 , means it is done automatic
           if nargin < 2
             Smooth_window = 20;                                           % default for smoothing length
             if  nargin < 1
               v = repmat([.1*ones(200,1);ones(100,1)],[10 1]);            % generate true variance profile
               y = sqrt(v).*randn(size(v));
             end
             
           end
        end
    end
end

%% ======= calculate the analytical signal and get the envelope ====== %%
test=y(:);
analytic = hilbert(test);
env = abs(analytic);

%% =========== take the moving average of analytical signal =========== %%
env = conv(env,ones(1,Smooth_window)/Smooth_window);                       % smooth
env = env(:) - mean(env);                                                  % get rid of offset
env = env/max(env);                                                        % normalize


%% ====================== threshold the signal =============== %%
if threshold_style == 0
   hg=figure;plot(env);title('Select a threshold on the graph')
   [~,THR_SIG] =ginput(1);
   close(hg);
end
% ------------------------- Threshold Style ---------------------- %
if threshold_style
   THR_SIG = 4*mean(env);
end

nois = mean(env)*(1/3);                                 % noise level
threshold = mean(env);                                  % signal level

% ------------------- Initialize Buffers -------------------------%
thres_buf  = zeros(1,length(env)-DURATION);
nois_buf = zeros(1,length(env)-DURATION);
THR_buf = zeros(1,length(env));
h=1;
alarm =zeros(1,length(env));

for i = 1:length(env)-DURATION
  %------ update threshold 10% of the maximum peaks found ------------%
  if env(i:i+DURATION) > THR_SIG 
      alarm(i) = max(env);
      threshold = 0.1*mean(env(i:i+DURATION)); 
      h=h+1;
  else
      % ----------- update noise --------------%
      if mean(env(i:i+DURATION)) < THR_SIG
          nois = mean(env(i:i+DURATION)); 
      else
          if ~isempty(nois_buf)
              nois = mean(nois_buf);
          end
      end
  end 
  
  thres_buf(i) = threshold;
  nois_buf(i) = nois;
  % ------------------------- update threshold -------------------------- %
  if h > 1
     THR_SIG = nois + 0.50*(abs(threshold - nois));            
  end
  THR_buf(i) = THR_SIG;
end 

if gr
     figure,ax(1)=subplot(211);
     plot(test),hold on,plot(alarm.*max(test),'r','LineWidth',2.5),
     hold on,plot(THR_buf,'--g','LineWidth',2.5);
     title('Raw Signal and detected Onsets of activity');
     legend('Raw Signal','Detected Activity in Signal',...
         'Adaptive Treshold',...
    'orientation','horizontal');
     grid on;axis tight;
     ax(2)=subplot(212);plot(env);
     hold on,plot(THR_buf,'--g','LineWidth',2.5),
     hold on,plot(thres_buf,'--r','LineWidth',2),
     hold on,plot(nois_buf,'--k','LineWidth',2),
     title('Smoothed Envelope of the signal(Hilbert Transform)');
     legend('Smoothed Envelope of the signal(Hilbert Transform)',...
         'Adaptive Treshold',...
    'Activity level','Noise Level','orientation','horizontal');
     linkaxes(ax,'x');
     zoom on;
     axis tight;
     grid on;
end