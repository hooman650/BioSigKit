function [R,V] = PhaseSpaceQRS(X,Fs,Period,gr)
%% ==== Phase Space Reconstruction for QRS detection ====== %%
%% Inputs
% X : Input ECG signal (vector)
% Fs : Sampling rate
% gr : Plot or not
%% Outputs:
% R : Index and Amplitude of the R Peaks
% Resp : Reconstructed respiratory signal from the area under the Phase
% Space 

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
%% ========= Inputs ========== %%
if nargin < 4
   gr = 0;
   if nargin < 3
      Period = 0.020;
   end
end

%% ====== Phase Space Reconstruction Based QRS detection =========
R = zeros(1000000,2);   
sleep = 0;
sleep_counter = 1;
updat = 0;
X = X - mean(X); % remove the offset
%% ========= Low pass Filter ================== %%
Wn = 15*2/Fs;                        % cutt off based on fs , 20 Hz
N = 3;                               % order of 3 less processing
[a,b] = butter(N, Wn,'low');         % bandpass filtering
X_f = filtfilt(a, b, X);

%% ================== Phase Space Reconstruction ================== %%
Y = phasespace(X_f,2,round(Period*Fs));  % Based on the paper
if gr
figure;plot(Y(:,1),Y(:,2));title('Phase Space Reconstruction');
v = axis;
hold on,line(0,v(3):0.1:v(4),'color','r','LineWidth',4)
hold on,line(v(1):0.1:v(2),0,'color','r','LineWidth',4)
end

%% Modified Spatial Velocity(MSV)
S(:,2) = diff(Y(:,1));
S(:,1) = diff(Y(:,2));

% ------------- Compute Determinant -------------%
V = zeros(1,size(S,1));
for i = 2 : size(S,1)    
    Temp = [S(i-1:i,1),S(i-1:i,2)];
    V(i-1) = det(Temp);    
end

% -------------- Initialize the rest of Param -------------- %
LLV = length(V) - 1;
RLV = length(V) - 1;
LLV_qrs = zeros(1,5);
RLV_qrs = zeros(1,5);
counter_RLV = 1;
thres_region = zeros(1,3);
counter_thr = 1;
% --------------- Init Thresholds ------------------------ %
Thres1 = 0.5*(std(V)*sqrt(2*log(length(V))));
Thres2 = Thres1*0.5;

% --------------- Read Sample by Sample ------------------- %
c = 1;
for i = 2 : size(S,1)
    % ----------- Compute Phase-Space LLV and RLV ----------- %
     if i >= 4
        LLV(i-1) = V(i - 2) + V(i - 3);
        RLV(i-1) = V(i - 2) + V(i - 1); 
        %% --------------------- Look for R Peak --------------------- %%
        if i >= 6                
                if updat == 0 && sleep == 0                    
                    if LLV(i-1) >= Thres1 &&  RLV(i-1) >= Thres1 
                        R(c,1) = i-1;
                        R(c,2) = V(i-1);
                        c = c + 1;
                        updat = 1;
                    elseif LLV(i-1) >= Thres2 || RLV(i-1) >= Thres2                        
                        R(c,1) = i-1;
                        R(c,2) = V(i-1);
                        c = c + 1;
                        updat = 1;      
                    else
                        updat = 0;
                    end                   
                end
    %% --------------------------- Search Back ------------------------ %%
             if c - 1 >= 2 && sleep == 0
                RR_l = mean(diff(R(1:c-1,1)));
                if abs(R(c-1,1) - (i-1)) > round(1.50*RR_l)
                    start_search = R(c-1,1) + round(0.200*Fs) - 1;
                    [LLV_ta,LLV_ti] = max(LLV(start_search:i-1));
                    LLV_ti = start_search + LLV_ti - 1;
                    RLV_ta = max(RLV(start_search:i-1));
                    % ---------- Reduce Threshold -------------%
                    if LLV_ta >= Thres1*0.8 &&  RLV_ta >= Thres1*0.8 
                        R(c,1) = LLV_ti - 1;
                        R(c,2) = V(LLV_ti - 1);
                        c = c + 1;
                        updat = 1;
                    elseif LLV_ta >= Thres2*0.5 || RLV_ta >= Thres2*0.5                         
                        R(c,1) = LLV_ti - 1;
                        R(c,2) = V(LLV_ti - 1);
                        c = c + 1;
                        updat = 1;      
                    else
                        updat = 0;
                    end                
                end    
             end   
     %% ============= Update thresholds ======================= %%                   
             if updat == 1 && sleep == 0     
                 
                         LLV_qrs(counter_RLV) = LLV(i-1);
                         RLV_qrs(counter_RLV) = RLV(i-1);
                         
                         thres_min = min(min(LLV_qrs(1:counter_RLV)),...
                             min(RLV_qrs(1:counter_RLV)));
                         thres_max = max(max(LLV_qrs(1:counter_RLV)),...
                             max(RLV_qrs(1:counter_RLV)));
                         
                         if counter_RLV > 5 
                             counter_RLV = 1; 
                         else
                             counter_RLV = counter_RLV + 1;
                         end          
                         thres_r = (thres_min + thres_max)/2;
                         thres_region(counter_thr) = thres_r;
                         if counter_thr >= 3                           
                             Thres1 = mean(thres_region(1:2));
                             Thres2 = mean(thres_region(1:end));
                             counter_thr = 1;
                             sleep = 1;
                         else
                             Thres1 = mean(thres_region(1:counter_thr)); 
                             Thres2 = Thres1;
                             counter_thr = counter_thr + 1;
                             sleep = 1;
                         end                          
                          updat = 0;                     
             end                 
             %%  -------------- Goes To Sleep --------------- %%
                 if sleep 
                       sleep_counter = sleep_counter + 1;                      
                         if sleep_counter >= round(0.200*Fs)
                             sleep = 0;
                             sleep_counter = 1;
                         end
                 end                           
        end
     end
end

%% ============== Fix lengths ====================%%
R = R(1:c-1,:);
%% =============================== Plots ============================= %%
if gr
  figure;
  ax(1) = subplot(211);plot(V,'LineWidth',1.5);
  title('Constructed From MSV-PS');axis tight;
  hold on,scatter(R(:,1),R(:,2),'r');
  ax(2) = subplot(212);plot(X_f,'LineWidth',1.5);
  title('Original Signal');axis tight;
  linkaxes(ax,'x');
end

end