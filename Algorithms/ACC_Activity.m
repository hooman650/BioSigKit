function [output,state,EE,F,SMA] = ACC_Activity(X,Fs)
%% = Estimate Activity from ACC and adaptively adjust bandpass Filter = %%
%% ============================== Method ============================== %%
% Uses the Signal Magnitude Area (SMA) Or Energy Expenditure to estimate
% the Current activity level of the subject, tunes the filter parameters
% based on that and filter X, Y and Z channels. It first removes the
% gravitational components with a high pass filter.
%% ============================== Inputs ============================== %%
% X : Matrix 3*n where each row, represents a single Channel of the
% acceleration
% Fs : Sampling freqeuncy
%% =========================== Outputs ========================= %%
% output = matrix of [3*n] , where n is the length of each X, Y and Z
% channel.
% state = is an integer. 0 means no or very low activity, 1 means median
% activtiy and 2 means high activity (e.g. Jogging)
% EE : Energy Expenditure over a minute
% F : the paramteres used for filtering.

%% ========================= Input Handling =========================== %%

if nargin < 2
   error('Please Enter Both X and Fs. Fs is the sampling rate!');
end

[m,n] = size(X);

if m ~= 3 
   error('Matrix X should have 3 rows, each row is one Acceleration channel'); 
end
%% ==== Eliminate static gravitation by high pass filtering =====%% 

output = zeros(m,n);
F=[1 12];
Wn=F*2/Fs; 
N = 3; 
[a,b] = butter(N,Wn); 
if max(m,n) >= 60*Fs
   Y = zeros(m,60*Fs);
else
   Y = zeros(m,length(X(1,:)));
end
for i = 1 : m
    if max(m,n) >= 60*Fs
        Y(i,:) = filtfilt( a,b, X(i,1:60*Fs));
        less = 0;
    else
        Y(i,:) = filtfilt( a,b, X(i,:));
        less = 1;
    end
end
%% ========== Compute SMA && Compute Energy Expenditure ============== %%
% ------------------------------- SMA --------------------------------- %
  SMA = (sum(abs(Y(:,1))) + sum(abs(Y(:,2))) +  sum(abs(Y(:,3))))...
         /n;


%% ============================== EE ================================ %%
delta_A = sqrt(diff(Y(1,:)).^2 + diff(Y(2,:)).^2 + diff(Y(3,:)).^2);
EE = sum(delta_A);

if less   
 T = length(X(1,:))/Fs;
 EE = EE/T;
 EE = EE*60;
end

%% Determine States over a minute
if EE >= 15
        if EE >= 45
               state = 2; %Jogging or high activity
               F = [0.3 0.7];
        else
               state = 1; %mild activity ex. walking 
               F = [0.2 0.6]; 
        end
    else
        state = 0; %Static
        F = [0.2 0.4];
end



%% =========== adaptively filter the signal based on its state ==== %%
 Wn=F*2/Fs; 
 N = 3;
 [a,b] = butter(N,Wn); 
for i = 1 : m
 output(i,:) = filtfilt(a,b,X(i,:));
end

end