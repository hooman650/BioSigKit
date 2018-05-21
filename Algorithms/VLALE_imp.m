function [output,e] = VLALE_imp(imp,fs,delay,mu,niter,w)
%%% Adaptive Variable Leaky ALE
%% Inputs:
% imp : ref sig
% delay : delay in samples , also corresponds to the filter order 
% (default 4 sec)
% mu : convergance factor, default 0.1
% niter : number of iteration, default 2
%% Outputs :
% output : output signal
% e : error signal

%% Author :
% Hooman Sedghamiz
% July 2015
%% Update :
% Hooman Sedghamiz
% September 2015


if nargin < 6
  w = zeros(delay,1);
  if nargin <5
   niter = 2; 
   if nargin < 4 
       mu = 0.01;
       if nargin < 3
           delay = round(4*fs);
       end   
   end
  end
end

disp('Computing Please Wait...');
imp = imp(:);
M = delay;
N = length(imp);
output = zeros(1,N);

e = zeros(1,N);
gamma = 0.01; %0.0001
gamma_m = gamma;
m = 1;
MM = 200;
L_u = 1;
L_d = 3;
alpha = 4;

for l = 1 : niter
 for i = M: N-1
  d = imp(i:-1:i-M+1);
  output(i) = w'*d;
  e(i) = imp(i) - output(i);
  den = d'*d;
  e1 = e(i)*(1 - 2*mu*den) ;
  e2 = imp(i) - (1 - 2*mu*gamma)*output(i) - 2*mu*e(i)*den;  
  
  if abs(e2) < abs(e1)
      m = min(m + L_u,MM);
  else
      m = max(m - L_d,0);
  end
  
  if gamma_m < gamma
     gamma_m = gamma; 
  end
  gamma =  gamma_m*((m/MM)^alpha);
  w = (1 - 2*mu*gamma)*w + 2*mu*e(i)*d;

 end
end
disp('Done!');