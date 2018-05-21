function [R,out,deni] = RTpca(X,nPCA,nit,T)
%% Inputs :
% X : Input Matrix, each variable is fed into one row and each single
% column denotes a single datapoint
% nPCA : Number of required PCs to estimate 
% nit : number of iterations
%% Outputs :
% R : EigenVectors of each PC, each row is a complete eigenvector.
% out : Estimated PCs in realtime; The las row is an outcome made by the
% wiegth of the first three PCs.
% deni : eigenvalues
%% Method
% The real time PCA (RTpca) is a brilliant approach to estimate the PCs in
% real time with the help of Hebian learning rule and iterative learning
% with a single neuron. This method is first inspired and motivated by Oja
% et al but the current algorithm is an out of the work by Principe et al.
% The convergence speed is determined by T. This function works perfect for 
% estimating the first 4 PCs.

%% Reference
% [1] H. Dongho; Y.N. Rao, J.C. Principe, K. Gugel.
% ‘’ Real-Time PCA(Principa1 Component Analysis)’’. IEEE International Joint Conference
% on Neural Networks (IEEE Cat. No.04CH37541) , 2004, p2159-2159, 1p. Publisher: IEEE

%% Author : Hooman Sedghamiz     hooman.sedghamiz@gmail.com
% Copyright August 2014

%%
if nargin < 4
    T = 0.90;                                                                  % default is 0.90
    if nargin < 3
       nit = 1;
       if nargin < 2
          nPCA = size(X,1); 
       end
    end
end

% get the dimensionality
[m,n] = size(X);


% ----------------- random initial weights if no input --------------- %
w = rand(m,nPCA);


% -------- T determines convergance (higher faster convergence)------- %
out = zeros(nPCA,n);
numi = zeros(m,nPCA);                                                      %first iteration always zero
deni = zeros(nPCA,1);                                                      %first iteration always zero
y = zeros(nPCA,1);
R = zeros(m,nPCA);

%dummi =[];

 for iter = 1:nit
  XX = X;       
  for ii = 1:n
        for r = 1 : nPCA 
          %% =================== Network ========================= %%
          y(r) = w(:,r)'*XX(:,ii); 
          % update network nominator
          numi(:,r) = (1-(1/ii))*numi(:,r) + (1/ii)*(XX(:,ii)*y(r)); 
          deni(r) = (1-(1/ii))*deni(r) + (1/ii)*y(r)^2;
          w(:,r) = (1 - T)*w(:,r) + T*(numi(:,r)/deni(r));  
          out(r,ii) = w(:,r)'*XX(:,ii);
          %% ========== Deflation to compute the remining PCs =========%%
          deflation_s = (w(:,r)*y(r));
          XX(:,ii) = XX(:,ii) - deflation_s;
          %% =============== Check for convergance =================== %%
          if R(:,r) == w(:,r)
             fprintf('Converged! in %d iteration and %d Sample',iter,ii);    
          end
          %% =============== Save the EigenVector ==================== %%
          R(:,r) = w(:,r);      
        end
        %dummi =[dummi deni(:)]; %length of eigenvectors
        %M = deni(1:end)./sum(deni(:));
        %out(r+1,ii) = M(3)*X(1,ii) + M(2)*X(2,ii) + M(1)*X(3,ii);
  end
  
 end
end

