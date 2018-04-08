function peaks = AMPD_P(sig1,L,gr)
%% Automatic Multiscale Based Peak Detection
%% Inputs :
% sig : vector of data points or one dimensional signal to be analyzed
% L : Length for which we compute Scalogram. Note that you can leave it
% free and the algorithm autmatically would set it to half the length of
% the signal. Note that this directly depends on signal Frequency of
% interest. If you look for sharp peaks then it is safe to set it to a low
% number, otherwise leave it as the default.
% gr : Show the plots or not (gr = 1, shows plots)
%% Outputs : 
% peaks : First column of peaks matrix (peaks(:,1)) contains the index of
% maxima and the second column (peaks(:,2))the amplitude of the maxima.

%% Methods :
% The first step of the automatic multiscale-based peak detection
%(AMPD) algorithm consists of calculating the local maxima scalogram (LMS).
% To this end, the signal x is first linearly detrended, i.e., the 
% least-squares fit of a straight line to x is calculated and subtracted
% from x. In the Next stages, LMS is further processed and local maxes
% determined.
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
%% References :
% H. Sedghamiz. BioSigKit: A Toolbox for biosignal analysis. In 
% Journal of Open Source Software, 2018.
% Scholkman. F, Boss. J, and Martin. W."An Efficient Algorithm for 
% Automatic Peak Detection in Noisy Periodic and Quasi-Periodic Signals."
% in Algorithms 2012.
%% ======== Initializing ============== %%
N = length(sig1);
if nargin < 3
    gr = 1;
    if nargin < 2
       L = ceil(N/2) - 1;
    end
end

sig = detrend(sig1(:));                  % detrend
m = zeros(L,N);                          %  LMS Matrix
Gamma = zeros(1,L);                      %  To Store Sums
alpha = 1;
%% ================= Local Maxima Scalogram (LMS) ================== %%
for k = 1 : L
    for i = 1 : N
        if (i >= (k + 2)) && (i <= (N - k + 1))
            if (sig(i-1) > sig(i-k-1)) && (sig(i-1) > sig(i+k-1))
                m(k,i) = 0;
            else
                m(k,i) = rand(1) + alpha;
            end   
        else
            m(k,i) = rand(1) + alpha;
        end
    end
    Gamma(k) = sum(m(k,:)); % Row-wise summation
end

%% ======================= Global Min of the LMS ===================== %%
[~,Lambda] = min(Gamma(:));

if Lambda < 2
    error('Low Signal!');   
end

%% ====================== Generating the new matrix ============ %%
M_r = m(1:Lambda,:);

%% ==================== Compute STD along the columns ============== %%
Phi = std(M_r,0,1);

%% ======================== Find Maxima ============================ %%
peaks(:,1) = find(Phi == 0);
peaks(:,2) = sig1(peaks(:,1)-1);

%% ======================== Plots results ============================== %%
if gr    
    ax(1)=subplot(321);imagesc(m);colormap(jet(5));title('LMS');
    xlabel('Samples N'); ylabel('Scales K');   
    Arbitrary = (min(Gamma):max(Gamma));
    subplot(322),plot(Gamma),hold on,...
        plot(ones(1,length(Arbitrary))*Lambda,(Arbitrary),'color','r',...
        'Linewidth',2);
    title(strcat('Summation Output, Lambda = ',mat2str(Lambda)));grid on;   
    ax(2)=subplot(323);imagesc(M_r);colormap(jet(5));
    title('Rescaled LMS (M_r)');
    xlabel('Samples N'); ylabel('Scales K');   
    ax(3)=subplot(324);plot(Phi);title('Standard Deviation of LMS');   
    ax(4)=subplot(3,2,[5 6]);plot(sig1);hold on,
    scatter(peaks(:,1),peaks(:,2),'filled',...
        'MarkerEdgeColor','r','MarkerFaceColor','c');
    title('Detected Peaks');  
    linkaxes(ax,'x');   
end
    






end