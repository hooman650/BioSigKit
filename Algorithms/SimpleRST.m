function [R_i,R_amp,S_i,S_amp,T_i,T_amp,Q_i,Q_amp,buffer_plot] = SimpleRST(ecg,fs,gr)
%% function [R_i,R_amp,S_i,S_amp,T_i,T_amp]=peakdetect(ecg,fs,view)
%% =================== Online Adaptive QRS detector ==================== %%
%% ========================== Description ============================= %%
% QRS detection
% Detects Q , R and S waves,T Waves
% Uses the state-machine logic to determine different peaks in an ECG
% signal. It has the ability to confront noise by canceling out the noise
% by high pass filtering and baseline wander by low pass. Besides, check
% out criterion to stop detection of spikes.
% The code is written in a way for future online implementation.
%% Inputs
% ecg : raw ecg vector
% fs : sampling frequency
% view : display results? (0: no, 1: Yes)

%% Outputs
% indexes and amplitudes of R_i, R_amp, etc
% heart_rate computed heart rate
% buffer_plot : processed signal
%% ============== Licensce ========================================== %%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% Author :
% Hooman Sedghamiz, Feb, 2018
% MSc. Biomedical Engineering, Linkoping University
% Email : Hooman.sedghamiz@gmail.com
%% Updates :
%  Feb, 2018 : Clean up and fixes.
%% ============== Now Part of BioSigKit ======================== %%
if nargin < 3
    gr = 1;                                                                % on show Sig
    if nargin <2
       fs = 250;                                                           % default Sampling frequency
       if nargin < 1
           error('You need to provide a signal!');
       end
    end 
end

%% ========================= initialize ============================ %%
R_i = zeros(1,length(ecg));                                                % save index of R wave
R_amp = zeros(1,length(ecg));                                              % save amp of R wave
S_i = zeros(1,length(ecg));                                                % save index of S wave
S_amp = zeros(1,length(ecg));                                              % save amp of S wave
T_i = zeros(1,length(ecg));                                                % save index of T wave
T_amp = zeros(1,length(ecg));                                              % save amp of T wave
Q_i = zeros(1,length(ecg));                                                % vectors to store Q wave
Q_amp = zeros(1,length(ecg));                                              % Vectors to store Q wave
S_amp1 = zeros(1,length(ecg));                                             % Buffer to set the adaptive T wave onset
thres_p =zeros(1,length(ecg));                                             % For plotting adaptive threshold
S_amp1_i = zeros(1,length(ecg));                                           % To save indices of S thres
buffer_plot = zeros(1,length(ecg));
thres2_p = zeros(1,length(ecg));                                           % T wave threshold indices
window = round(0.04*fs);                                                   % averaging window size
buffer_long= zeros(1,window);                                              % buffer for online processing
state = 0 ;                                                                % determines the state of the machine in the algorithm
c = 0;                                                                     % counter to determine that the state-machine doesnt get stock in T wave detection wave
T_on = 0;                                                                  % counter showing for how many samples the signal stayed above T wave threshold
T_on1=0;                                                                   % counter to make sure its the real onset of T wave
S_on = 0;                                                                  % counter to make sure its the real onset of S wave
sleep = 0;                                                                 % counter that avoids the detection of several R waves in a short time
buffer_base=zeros(1,2*fs);                                                 % buffer to determine online adaptive mean of the signal
dum = 0;                                                                   % counter for detecting the exact R wave
weight = 1.8;                                                              % initial value of the weigth
co = 0;                                                                    % T wave counter to come out of state after a certain time
thres_p_i = zeros(1,length(ecg));                                          % To save indices of main thres
thres2_p_i = zeros(1,length(ecg));                                         %to save indices of T threshold
%% ========================= preprocess ================================ %%
ecg = ecg (:);                                                             % make sure its a vector
ecg_raw =ecg;                                                              % take the raw signal for plotting later
%% ==================== Noise cancelation(Filtering) =================== %% 
f1=0.5;                                                                    % cuttoff low frequency to get rid of baseline wander
f2=45;                                                                     % cuttoff frequency to discard high frequency noise
Wn=[f1 f2]*2/fs;                                                           % cutt off based on fs
N = 3;                                                                     % order of 3 less processing
[a,b] = butter(N,Wn);                                                      % bandpass filtering
ecg = filtfilt(a,b,ecg);

%% ==============  define two buffers ================= %%

buffer_mean=mean(abs(ecg(1:2*fs)-mean(ecg(1:2*fs))));                      % adaptive threshold DC corrected (baseline removed)
buffer_T = mean(ecg(1:2*fs));                                              % second adaptive threshold to be used for T wave detection
%% ================== Counters ============================ %%
B_Lcounter = 0;
B_counter = 0;
SP_counter = 0;
thres_p_C = 0;
R_C = 0;
S_C = 0;
T_C = 0;
Q_C = 0;
thres2_p_C = 0;
%% =start online inference (Assuming the signal is being acquired online) %%
for i = 1 : length(ecg)
 B_Lcounter = B_Lcounter + 1;  
 buffer_long(B_Lcounter) = ecg(i);                                         % save the upcoming new samples
 if B_Lcounter > window
    B_Lcounter = 0; 
 end

 B_counter = B_counter + 1;
 buffer_base(B_counter) = ecg(i);                                          % save the baseline samples

%% ============================= Renew Mean ======================= %%
 if B_counter >= 2*fs
    buffer_mean = mean(abs(buffer_base - mean(buffer_base)));
    buffer_T = mean(buffer_base);
    B_counter = 0;
 end

%% ========= Smooth  15 samples and add the new upcoming samples ======== %%
  if i >= window                                                  % take a window with length 15 samples for averaging
      mean_online = mean(buffer_long);                       % take the mean
      SP_counter = SP_counter + 1;
      buffer_plot(SP_counter) = mean_online;                               % save the processed signal
      
      
    %% ==============  Enter state 1(putative R wave) ================ %%
    if state == 0  
     if SP_counter >= 3                                                                         % added to handle bugg for now
      if (mean_online > buffer_mean*weight) && (buffer_plot(i-1-window) > buffer_plot(i-window))    % 2.4*buffer_mean   
          state = 1;                                                                            % entered R peak detection mode
          currentmax = buffer_plot(i-1-window);
          ind = i-1-window;
          thres_p_C = thres_p_C + 1;
          thres_p(thres_p_C) = buffer_mean*weight;
          thres_p_i(thres_p_C) = ind;
      else     
          state = 0;
      end
     end
    end
    
%% ============= Locate R by finding highest Peak =================== %%
      if state == 1                                                        % look for the highest peak
            if  currentmax > buffer_plot(i-window)
                dum = dum + 1;
                if dum > 4 
                   R_C = R_C + 1;
                   R_i(R_C) = ind;                                          % save index
                   R_amp(R_C) = buffer_plot(ind);                          % save index
                %-------------- Locate Q wave --------------------%
                  [Q_tamp,Q_ti] = min(buffer_plot(ind-round(0.040*fs):(ind)));
                  Q_ti = ind-round(0.040*fs) + Q_ti -1;
                  Q_C = Q_C + 1;
                  Q_i(Q_C) = Q_ti;
                  Q_amp(Q_C) = Q_tamp;                           
                  if R_C > 8
                     weight = 0.30*mean(R_amp(R_C-7:R_C));                  % calculate the 35% of the last 8 R waves
                     weight = weight/buffer_mean;
                  end
                  state = 2;                                                % enter S detection mode state 2
                  dum = 0;
                end
            else
                dum = 0;
                state = 0;
            end 
            
      end
      
  %% === check if Sig drops below the threshold to look for S wave === %%
      if state == 2 
        if  mean_online <= buffer_mean                                     % check the threshold
             state = 3;                                                    % enter S detection           
        end
      end
      
  %% ============ Enter S wave detection state3 (S detection) =========== %%
         if state == 3
            co = co + 1;    
          if co < round(0.200*fs)
            if buffer_plot(i-window-1) <= buffer_plot(i-window)            % see when the slope changes
             S_on = S_on + 1;                                              % set a counter to see if its a real change or just noise
             if S_on >= round(0.0120*fs)
                S_C = S_C + 1;
                S_i(S_C) = i-window-4;                                     % save index of S wave
                S_amp(S_C) = buffer_plot(i-window-4);                      % save index
                S_amp1(S_C) = buffer_plot(i-window-4);                     % ecg(i-4)
                S_amp1_i(S_C) = ind;                                       % index of S_amp1_i
                state = 4;                                                 % enter T detection mode
                S_on = 0;
                co = 0;
             end
            end
          else
                state = 4;
                co = 0;
          end
          end
      
       %% ======= enter state 4 possible T wave detection ============ %%
       if state == 4    
         if mean_online < buffer_mean                                      % See if the signal drops below mean 
           state = 6;                                                      % Confirm
         end
       end
       %% ======= Enter state 6 which is T wave possible detection ======%%
       if state ==6   
         c = c + 1;                                                        % set a counter to exit the state if no T wave detected after 0.3 second
         if c <= 0.7*fs  
             %------------------------------------------------------------%
             % set a double threshold based on the last detected S wave and
             % baseline of the signal and look for T wave in between these
             % two threshold
             %------------------------------------------------------------%
             thres2 = ((abs(abs(buffer_T)-abs(S_amp1(S_C))))*3/4 + S_amp1(S_C)); 
             thres2_p_C = thres2_p_C + 1;
             thres2_p(thres2_p_C) = thres2;
             thres2_p_i(thres2_p_C) = ind;
             if mean_online > thres2
              T_on = T_on +1;                                              % make sure it stays on for at least 3 samples
              if T_on >= round(0.0120*fs)
               if buffer_plot(i-window-1)>= buffer_plot(i-window)
                   T_on1 = T_on1+1;                                        % make sure its a real slope change
                  if T_on1 > round(0.0320*fs) 
                   T_C = T_C + 1;
                   T_i(T_C) = i-window-11;                                 % save index of T wave
                   T_amp(T_C) = buffer_plot(i-window-11);                  % save index
                   state = 5;                                              % enter sleep mode
                   T_on = 0;
                   T_on1 = 0;
                  end                      
               end
              end
             end         
         else
             state= 5;                                                     % enter Sleep mode
         end
         
       end  
  %% ==== Sleep To avoid multiple detections ================== %%
       if state==5
           sleep =sleep+c+1;
           c = 0;
           if sleep/fs >= 0.400
               state = 0;
               sleep = 0;
           end  
       end     
  end
  
end
%% ============== Adjust Length of Signals ===================== %%
R_i = R_i(1:R_C);
S_i = S_i(1:S_C);
S_amp1 = S_amp1(1:S_C);
S_amp1_i = S_amp1_i(1:S_C);
T_i = T_i(1:T_C);
Q_i = Q_i(1:Q_C);
thres_p_i = thres_p_i(1:thres_p_C);
thres_p = thres_p(1:thres_p_C);
buffer_plot = buffer_plot(1:SP_counter);
thres2_p = thres2_p(1:thres2_p_C);
thres2_p_i = thres2_p_i(1:thres2_p_C);
%% conditions
%heart_rate=R_C/(time_scale/60); % calculate heart rate
%msgbox(strcat('Heart-rate is = ',mat2str(heart_rate)));


%% plottings 
if gr
   view = length(ecg)/fs;
   time = 1/fs:1/fs:view;
   R = find(R_i <= view*fs);                                                  % determine the length for plotting vectors
   S = find(S_i <= view*fs);                                                  % determine the length for plotting vectors
   T = find(T_i <= view*fs);                                                  % determine the length for plotting vectors
   Q = find(Q_i <= view*fs);                                                  % determine the length for plotting vectors
   L1 = find(thres_p_i <= view*fs);
   L2 = find(S_amp1_i <= view*fs);
   L3 = find(thres2_p_i <= view*fs);
   if view*fs > length(buffer_plot)
      ax(1) = subplot(211);plot(time(1:length(buffer_plot)),buffer_plot(1:end));   
   else
      ax(1) = subplot(211);plot(time,buffer_plot(1:(view*fs)));
   end
   axis tight;
   hold on,scatter(R_i(1:R(end))./fs,R_amp(1:R(end)),'r');
   hold on,scatter(S_i(1:S(end))./fs,S_amp(1:S(end)),'g');
   hold on,scatter(T_i(1:T(end))./fs,T_amp(1:T(end)),'k');
   hold on,scatter(Q_i(1:Q(end))./fs,Q_amp(1:Q(end)),'m');
   hold on,plot(thres_p_i(1:L1(end))./fs,thres_p(1:L1(end)),'LineStyle','-.','color','r',...
    'LineWidth',2.5);
   hold on,plot(S_amp1_i(1:L2(end))./fs,S_amp1(1:L2(end)),'LineStyle','--','color','c',...
    'LineWidth',2.5);
   hold on,plot(thres2_p_i(1:L3(end))./fs,thres2_p(1:L3(end)),'-k','LineWidth',2);
   legend('Raw ECG Signal','R wave','S wave','T wave','R adaptive thres','Latest S wave','T wave adaptive threshold threshold','Location','NorthOutside','Orientation','horizontal'); 
   xlabel('Time(sec)'),ylabel('V');
   axis tight; 
   title('Zoom in to see both signal details overlaied');
   title('Filtered, smoothed and processed signal');
   ax(2) =subplot(212);
   plot(time,ecg_raw(1:(round(view*fs))));
   title('Raw ECG')
   xlabel('Time(sec)'),ylabel('V');
   legend(); 
   linkaxes(ax,'x');
   zoom on;
   axis tight;
end