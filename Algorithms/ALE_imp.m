function [output,e] = ALE_imp(imp,fs,delay,mu,niter)
%%% Adaptive Noise Canceler with NLMS algorithm
%% Inputs:
% imp : impedance sig
% delay : delay in samples , also corresponds to the filter order 
% (default 4 sec)
% mu : convergance factor, default 0.01
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


if nargin < 5
   niter = 2; 
   if nargin < 4 
       mu = 0.01;
       if nargin < 3
           delay = round(4*fs);
       end   
   end
end

disp('Computing Please Wait...');
imp = imp(:);
M = delay;
N = length(imp);
output = zeros(1,N);
w = zeros(delay,1);
e = zeros(1,N);
gamma = 0.0001;

for l = 1 : niter
 for i = M: N-1
  d = imp(i:-1:i-M+1);
  output(i) = w'*d;
  e(i) = imp(i+1) - output(i);
  den = (gamma +d'*d);
  w = w + (mu/den)*e(i)*d;
 end
end
e = e.^2;
disp('Done!');
