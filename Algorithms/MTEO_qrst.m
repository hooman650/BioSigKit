function [R,Q,S,T,P_w] = MTEO_qrst(ecg,fs,gr)
%% ======== Delineates ECG based on MTEO Algorithm ============== %%
% Employs Multilevel Teager Energy Operator to delineate ECG. To see how
% MTEO is computed please see my paper and cite it if you are interested
% in using this code.
%%%%%
% Ref : H. Sedghamiz and D. Santonocito,’’Unsupervised Detection and 
% Classification of Motor Unit Action Potentials in Intramuscular 
% Electromyography Signals’’, The 5th IEEE International Conference 
% on E-Health and Bioengineering - EHB 2015, At Iasi-Romania. 
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

%% Initilization

ecg = ecg (:);                    % make sure its a vector
N = length(ecg);                  % Data length
L = round(2*fs);                  % to set the initial threshold
M = zeros(3,1);                   % Buffer to store real-time K_TEO
MTEO = zeros(1,N);                % Buffer to store rea-time M_TEO
BS = 0;                           % Running estimate of baseline
C = 0;                            % counter
state = 0;                        % state machine
blank_p = round(0.200*fs);        % blank period
NV = 0;                           % noise estimate
SV = 0;                           % R peak level estimate
P_old = 0;                        % Stores the old peak value
P_old_i = 0;                      % Index of the old R index
R = zeros(length(ecg),2);              % Stores the index and amplitude of R
C_R = 0;                          % R peak counter
RR = 0;                           % mean RR interval
SB = round(0.360*fs);             % search-back limit
index = 0;                        % holds the current R index
NV_old = 0;                       % takes the largest encountered noise ind
NV_old_i = 0;                     % index of oldest noise peak
S_R = round(0.06*fs);             % boundry locate R in Lowpass sig
R1 = zeros(length(ecg),2);             % stores the R peak info on lowpassed sig
Q = zeros(length(ecg),2);              % stores the Q peak info on lowpassed sig
S = zeros(length(ecg),2);              % stores the S peak info on lowpassed sig
T = zeros(length(ecg),2);              % stores the T peak info on lowpassed sig
P_w = zeros(length(ecg),2);            % stores the P peak info on lowpassed sig
refract = round(0.012*fs);        % refractory period
min_d = round(0.02*fs);           % min distance to the peak
m_c = 1;                          % counter to compute mean of the signal
TH = zeros(1,N);
THS = zeros(1,N);
THN = zeros(1,N);
BS_E = zeros(1,N);
counter_m = 1;                    %counts the number of times mean computed
%% Noise cancelation(Filtering)
Wn = 15.*2/fs;                    % cutt off based on fs , 20 Hz
O = 2;                            
[a,b] = butter(O,Wn,'low');       % Low pass filter
ecg1 = filtfilt(a,b,ecg);

%%%% Low Pass for T and P wave (H(Z) = (1-(z^-19))^2/(1-(z^-1))^2
%=> b = zeros(1,41); b(1) = 1; b(end) = 1; b(21) = -2;
% a = [1 -2 1];
% h = filter(b,a,[1 zeros(1,40)]);
% ecg_t = conv(ecg1,h);
%%%%
Wn = 5.*2/fs;                     % cutt off based on fs , 20 Hz
[a,b] = butter(O,Wn,'high');      % Low pass filter
ecg = filtfilt(a,b,ecg1);

%% ==== Estimate the initial threshold from the first two seconds ==== %%
 for i = 4 : L - 3
   %%%-------- Compute K-TEO && MTEO in Real-time ------------- %%% 
    M(1) = ecg(i)^2 - (ecg(i-1)*ecg(i+1));
    M(2) = ecg(i)^2 - (ecg(i-2)*ecg(i+2));
    M(3) = ecg(i)^2 - (ecg(i-3)*ecg(i+3));
    MTEO(i) = max(M); 
   % --------------------- Update Baseline estimate ---------------- %
    if (C >= blank_p) 
       BS = 0.5*(BS + mean(ecg1(i-C:i)));
       C = 0;
    end
    C = C + 1;
end

TH0 = 0.5*(std(MTEO(1:L))*sqrt(2*log(L)));
TH1 = TH0;
TH_t = 0;
TH_p = 0;
C = 0; % Counter for blankperiod
%% Begin the real time processing
 for i = 4 : N - 3
    %------------ Compute K-TEO && MTEO in Real-time ---------------- % 
    M(1) = ecg(i)^2 - (ecg(i-1)*ecg(i+1));
    M(2) = ecg(i)^2 - (ecg(i-2)*ecg(i+2));
    M(3) = ecg(i)^2 - (ecg(i-3)*ecg(i+3));
    MTEO(i) = max(M);
    %------------------ Estimate the baseline in real time ---------------%
    if  m_c >= blank_p
        BS = 0.5*(BS + mean(ecg1(i-m_c:i)));
        m_c = 1;
        BS_E(i) = BS;
        counter_m = counter_m + 1;
        if counter_m >= 2
           BS_E(i-blank_p+2:i-1) = interp1([i-blank_p+1,i],...
               [BS_E(i-blank_p+1),BS_E(i)],(i-blank_p+2:i-1),'linear');  
        end
    end
    m_c = m_c + 1;
    % -------------------- Initialize the state-machine-----------------%
    if  i >= 6

    %--------------------- State 0 = R peak detection ------------------%    
      if ~state  
        if ((MTEO(i-2) < MTEO(i-1)) && (MTEO(i-1) > MTEO(i)))          
            if (MTEO(i-1) >= TH1) && (MTEO(i-1) > P_old)                                  
               if P_old                            % Add P_old to noise est
                NV = 0.125*P_old + 0.875*NV;       % noise estimate      
                TH1 = NV + 0.3*(SV-NV);
               end
               
               C = 1;
               P = MTEO(i-1);
               P_old = P;
               index = i-1;
            else
               NV = 0.125*MTEO(i-1) + 0.875*NV;    % noise estimate
               
               if SV
               TH1 = NV + 0.3*(SV-NV);
               end
               if NV_old < MTEO(i-1)
                   NV_old = MTEO(i-1);
                   NV_old_i = i-1;
               end              
            end        
        end
        
        if C >= blank_p          
           TF = P_old_i - index;                   % is it a new QRS peak?
           if TF
              C_R = C_R + 1; 
              R(C_R,1) = index;
              R(C_R,2) = P;
              C = 0;
              P_old_i = index;
              P_old = 0;
              NV_old = 0;
               if C_R == 1
               SV = 0.875*P;   
               else
               SV = 0.125*P + 0.875*SV;
               end
               
              TH1 = NV + 0.3*(SV-NV);
              if C_R == 2
                 D =  index - R(C_R-1,1); 
                 RR = 0.875*D;
                 state = 1;                       % Initiates State 1
              elseif C_R > 2
                 D =  index - R(C_R-1,1); 
                 RR = 0.125*D + 0.875*RR;
                 state = 1;                       % Initiates State 1
              end
              
           elseif ~TF && RR                       % initiates search_back
               if C >= round(1.5*RR)
                  SBN = index + SB;         
                  TH2 = 0.5*TH1; 
                  if (NV_old >= TH2) && (NV_old_i >= SBN)
                      index = NV_old_i;
                      C_R = C_R + 1; 
                      R(C_R,1) = index;
                      R(C_R,2) = NV_old;
                      C = (i-1) - index;          % tune C and index
                      P_old_i = index;
                      P_old = 0;
                      NV_old = 0;
                      SV = 0.25*NV_old + 0.75*SV;
                      TH1 = NV + 0.3*(SV-NV);
                      D = R(C_R-1,1) - index; 
                      RR = 0.125*D + 0.875*RR;
                      state = 1;                  % Initiates State 1
                  end
               end
           end
        end
        C = C + 1;
      %-------------------------- Locates R wave ----------------------%
      elseif state == 1                           
        init_p = R(C_R-1,1);
                                                  % boundery check
        if  ((init_p - S_R) > 0) && ((init_p + S_R) < (N-3))
        r = locate_r(ecg1(init_p - S_R:init_p + S_R)- BS);
        r = (init_p - S_R) + r - 1;
        
        elseif ((init_p - S_R) <= 0)
        temp_sg = ecg1(1:init_p+S_R)-BS;
        [~,tmp] = findpeaks(abs(temp_sg));
        
            if ~isempty(tmp)
            [~,r] = min(abs(tmp-init_p)); 
            else
            [~,r] = max(abs(temp_sg));     
            end
        
        r = tmp(r);
        elseif (init_p + S_R) > (N-3)
        [~,tmp] = findpeaks(abs(ecg1(init_p - S_R:end)-BS));
            
            if ~isempty(tmp)
             [~,r] = min(abs(tmp-S_R));
            else
             [~,r] = max(abs(temp_sg));    
            end
             r = tmp(r);
             r = (init_p - S_R) + r - 1;    
        end
        
        R1(C_R-1,1) = r;
        R1(C_R-1,2) = ecg1(R1(C_R-1,1));
        state = 2;
      %------------------------ Locate Q wave -------------------------% 
      elseif state == 2                           
                                                  % Boundery check
        if ((init_p  - blank_p) > 0) 
        q = locate_q(ecg1(init_p - blank_p:R1(C_R-1,1) - min_d)-BS);
        q(2) = (init_p - blank_p) + q(2) - 1;
        elseif (init_p - blank_p) <= 0 
        q = locate_q(ecg1(1:R1(C_R-1,1)- min_d)-BS);  
        end
        
        Q(C_R-1,1) = q(2);
        Q(C_R-1,2) = ecg1(q(2));
        state= 3;
      % ------------------------ Locate S wave -------------------- % 
      elseif state == 3                           
        s = locate_s(ecg1(R1(C_R-1,1) + min_d:R1(C_R-1,1) + blank_p)-BS);
        s(2) = (R1(C_R-1,1)+min_d) + s(2) - 1;
        S(C_R-1,1) = s(2);
        S(C_R-1,2) = ecg1(s(2));
        state = 4;
      % ------------------------ Locate T wave --------------------- %
      elseif state == 4                           
        temp_segment = ecg1(s(2) + min_d:s(2) + round(0.5*RR))- BS; 
        t = locate_t(temp_segment,TH_t);
        if ~isnan(t)
            t(2) = s(2) + min_d +  t(2) - 1;
            TH_t = 0.125*abs(t(1)) + 0.60*TH_t;
        end
        T(C_R-1,1) = t(2);
        if ~isnan(t(2))
        T(C_R-1,2) = ecg1(t(2));
        else
        T(C_R-1,2) = t(1);    
        end
        
         if C_R > 2
           if  (isnan(T(C_R-1,2))) && (isnan(T(C_R-2,2)))
               TH_t = 0;
           end
         end
        
        state = 5;
      %--------------------------- Locate P Wave ----------------------% 
      elseif state == 5                           
         p_win = round(0.6*RR);
         if  (q(2) - p_win > 0)
             temp_segment = ecg1(q(2) - p_win:q(2))- BS; 
             offset = p_win;
         else
             temp_segment = ecg1(1:q(2))- BS; 
             offset = 0;
         end
        p = locate_p(temp_segment,TH_p,refract);
        
        if ~isnan(p)
            if offset
            p(2) = p(2) + (q(2) - offset) - 1;
            end
            TH_p = 0.125*abs(p(1)) + 0.6*TH_p;           
            P_w(C_R-1,2) = ecg1(p(2)); 
        else
            P_w(C_R-1,2) = p(1); 
        end
        
        if C_R > 2
           if  (isnan(P_w(C_R-1,2))) && (isnan(P_w(C_R-2,2)))
               TH_p = 0;
           end
        end
        
        P_w(C_R-1,1) = p(2);
        state = 0;
      end  
        
        
        
        
    end

    TH(i) = TH1;
    THS(i) = SV;
    THN(i) = NV; 
 end
 
 
 
 R = R(1:C_R,:);
 R1 = R1(1:C_R-1,:);
 Q = Q(1:C_R-1,:);
 S = S(1:C_R-1,:);
 T = T(1:C_R-1,:);
 P_w = P_w(1:C_R-1,:);
 P_w = P_w(~any(isnan(P_w),2),:);                    % Remove NaNs  
 T = T(~any(isnan(T),2),:);                          % Remove NaNs  
 if gr
    figure,plot(ecg1);
    hold on,scatter(R1(:,1),R1(:,2),'r');
    hold on,scatter(Q(:,1),Q(:,2),'g');
    hold on,scatter(S(:,1),S(:,2),'k');
    hold on,scatter(T(:,1),T(:,2),'m');
    hold on,scatter(P_w(:,1),P_w(:,2),'MarkerEdgeColor',[.7 .5 0]);
 end
end


%% Locates R Peak on the Raw Signal
function r = locate_r(sig)
%% Inputs
% Sig : Sequence
%% Output
% r : Peak index
[~,tmp] = findpeaks(sig);
[~,tmp1] = findpeaks(-sig);
mid_point = round(length(sig)*0.5);

 if ~isempty(tmp)
 [~,D] = min(abs(tmp-mid_point));
 tmp = tmp(D);
 end
 
 if ~isempty(tmp1)
 [~,D] = min(abs(tmp-mid_point));
 tmp1 = tmp1(D);
 end
 
 A = [tmp;tmp1];
 
 
 if ~isempty(A)
  [~,B] = min(abs(A-mid_point));
  A = A(B);
  r = A;
 else
  [~,r] = max(abs(sig)); 
 end


  
end
%% ================== P Wave Detection =================== %%
function p = locate_p(sig,TH_p,refract)
%% Inputs
% Sig : Sequence
% TH1 : minimum peak height
%% Output
% P(1) : Peak amplitude
% P(2) : Peak index

if ~TH_p
    TH_p = mean(sig);
end
sig = sig - mean(sig);  
 p = NaN(2,1);
[amps,locs] = findpeaks(abs(sig));


if ~isempty(locs)
        
     TF = (amps >= TH_p);
     TF1 = abs(locs - length(sig)) > refract;
     TF = and(TF,TF1);
     locs = locs(TF);
     amps = amps(TF);
 
     if ~isempty(amps)
       raw_amps = sig(locs);
      if length(raw_amps)>1 
       for i = 1: length(raw_amps) - 1
          if (raw_amps(i)<0) && (raw_amps(i+1)>0) 
             locs(i)=[];
             amps(i)=[];
             break;
          end
       end
      end
         
         
        [~,tmp] = max(amps);
        locs = locs(tmp);
        p(2) = locs;
        p(1) = sig(p(2));    
     end
end
  
end
%% ================= Q Wave Identification ================= %%
%% Locates a global maximum in a sequence
function q = locate_q(sig)
%% Inputs
% Sig : Sequence
% TH1 : minimum peak height
%% Output
% P(1) : Peak amplitude
% P(2) : Peak index


 q = [];
 [~,locs] = findpeaks(sig);
 [~,locs1] = findpeaks(-sig);
 
 if ~isempty(locs)
 locs = locs(end);
 end
 if ~isempty(locs1)
 locs1 = locs1(end);
 end
  A = [locs;locs1];
  
  if ~isempty(A)
  q(2) = max(A);
  else
 
    [~,q(2)] = max(diff(sig,2));
     if q(2) > 7
     q(2) = q(2) - 7;
     else
     q(2) = 1;   
     end
  end 
 q(1) = sig(q(2));
  
end

%% ================== S Wave Delineation ================ %%
%% Locates a global maximum in a sequence
function s = locate_s(sig)
%% Inputs
% Sig : Sequence
% TH1 : minimum peak height
%% Output
% P(1) : Peak amplitude
% P(2) : Peak index

 s = [];
 [~,locs] = findpeaks(sig);
 [~,locs1] = findpeaks(-sig);
 
 if ~isempty(locs)
 locs = locs(1);
 end
 if ~isempty(locs1)
 locs1 = locs1(1);
 end
  A = [locs;locs1];
  
 if ~isempty(A)
  s(2) = min(A);
  s(1) = sig(s(2));
 else
  
  [~,locs]=findpeaks(diff(sig));
  if isempty(locs)
     [~,locs] = max(diff(sig,2)); 
  else
     locs = locs(1);
  end
  s(2) = locs;
  s(1) = sig(s(2));
 end
  
end
%% ================ T Wave Block ========================== %%
function t = locate_t(sig,TH_t)
%% Inputs
% Sig : Sequence
% TH1 : minimum peak height
%% Output
% t(1) : Peak amplitude
% t(2) : Peak index
 t = NaN(2,1);
 sig = sig - mean(sig);                       % check if there are more than two peaks
 if ~TH_t
     TH_t = mean(sig);
 end
 
 [count,count_i]=findpeaks(abs(sig));
 
if ~isempty(count)
 TF = (count >= TH_t);
 count = count(TF);
 count_i = count_i(TF);
  if ~isempty(count)
     raw_amps = sig(count_i);
     
     if length(count_i) > 1
        for i = 1: length(count_i) - 1
         if (raw_amps(i)>0) && (raw_amps(i+1)<0) 
             count = 0;
             break;
         end
       
        end
     end
     if max(count) >= 2*min(count)
         count = 0;                               % make the length 1
     end
     
  end
end
 
 d_sig = diff(sig);
 [~,init_index] = max(abs(d_sig));  
 template = sig(init_index:end);
 
 if length(template) > 5
    [amps,locs] = findpeaks(abs(sig(init_index:end))); 
 else
     amps = [];
     locs = [];
 end
 

 
 
 
 if ~isempty(locs) && (length(count) > 1)
  TF = (amps >= TH_t);
  locs = locs(TF);
  amps = amps(TF);
  [~,tmp] = max(amps);
  locs = locs(tmp);
    if ~isempty(locs)
        t(2) = locs + init_index;
        t(1) = sig(t(2)); 
    else                                      % lower than TH1 might be P
                                              % look for second steep slope 
      [amps,locs] = findpeaks(abs(d_sig(1:init_index)));    
        if ~isempty(locs)
           [~,tmp] = max(amps);
           tmp_i = locs(tmp);
           [amps,locs] = findpeaks(abs(sig(tmp_i:end)));
           if~isempty(locs)
             TF = (amps >= TH_t);
             locs = locs(TF);
             amps = amps(TF); 
             if ~isempty(amps)
             [~,tmp] = max(amps);
             locs = locs(tmp);
             t(2) = locs + tmp_i;
             t(1) = sig(t(2));  
             end
           end
        end
    end

 else
     
 [amps,locs] = findpeaks(abs(sig));
 TF = (amps >= TH_t);
 locs = locs(TF);
 amps = amps(TF);
     if ~isempty(amps)
        [~,tmp] = max(amps);
        locs = locs(tmp);
        t(2) = locs;
        t(1) = sig(t(2));    
     end
 end
 
end


