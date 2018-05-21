function final = NLMS_ecg(ACC,ECG,order,gr)
%% =========== ECG Artifact Removal with NLMS and ACC signals ======= %%

% ---------------------- Remove offsets -------------------------- %
ECG = ECG - mean(ECG);

for i = 1: 3 
    ACC(:,i) = ACC(:,i) - mean(ACC(:,i));
end

% --------------------- Initialize ------------------------------- %
M = order;
N = length(ECG);
ref = ones(4,N);
temp = zeros(1,N);
w = zeros(3,M);
w1 = zeros(4,1);
S = zeros(3,N);
y = zeros(3,N);
final = zeros(1,N);
mu = 0.3;                          % Range (0.25-0.75)
er = 0.0001; 
leak = 0.1;                        % make it zero for a normal LMS
%% ===================== Adaptive Filtering ======================= %
for j = 1 : 2
 for i =  M  : N
  for k = 1 : 3
   y(k,i) = w(k,:)*ACC(i - M + 1: i,k);
   S(k,i) = ECG(i) -   y(k,i);
   w(k,:) = ((1-mu*leak)*w(k,:))' +...
       (mu*S(k,i)/(ACC(i - M + 1: i,k)'*...
       ACC(i - M + 1: i,k) + er))*ACC(i - M + 1: i,k);
  end
  ref(2:4,i) = y(:,i);             % ref includes a high pass too
  temp(i) = ref(:,i)'*w1;
  final(i) = ECG(i) -  temp(i);
  w1 = (1-mu*leak)*w1 +...
       (mu*final(i)/(ref(:,i)'*...
       ref(:,i) + er))*ref(:,i);
 end
end

% ------------------------- Plot results? ------------------- %
if gr
   ax(1) = subplot(211);plot(ECG);title('Raw ECG');
   ax(2) = subplot(212);plot(final);title('Cleaned ECG');
   linkaxes(ax,'x');
end

end 