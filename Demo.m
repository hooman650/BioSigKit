%% =============== Demo ======================== %%
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
%--------------- Only Hit the Run button -----------------%

%% ===================== DEMO FOR QRS DETECTORS ======================== %%
%---------------- Load a Sample ECG Signal from (\SampleSignals) directory -----------------%
slashchar = char('/'*isunix + '\'*(~isunix)); 
load([fileparts(which(mfilename)),slashchar,'SampleSignals',slashchar,...
    'ECG1.mat']);
% ------------------ Call the BioSigKit Wrapper -------------------%
Analysis = RunBioSigKit(EKG1,250,0);          % Uses ECG1 as input,Fs=250
%-------------------- Call Pan Tompkins Algorithm ------------------- %
Analysis.MTEO_qrstAlg;                        % Runs MTEO algorithm
QRS = Analysis.Results.R;                     % Stores R peaks in QRS
%-------------------- Call MTEO QRS ------------------- %
Analysis.MTEO_qrstAlg;                        % Runs MTEO algorithm
QRS = Analysis.Results.R;                     % Stores R peaks in QRS
Qwave = Analysis.Results.Q;                   % Indice of Q peaks
Swave = Analysis.Results.S;                   % Indice of S peaks
Twave = Analysis.Results.T;                   % Indice of T peaks
Pwave = Analysis.Results.P;                   % Indice of P peaks
% ------------------------ Change Sample rate ------------------%
Analysis.Fs =360;

%--------------------------- Open GUI -----------------------------%
% Analysis = RunBioSigKit();                    % Opens GUI 

%% ==================  DEMO FOR OTHER SUBROUTINES =================== %%
% ----------------- Activity detection with hilber Transform -------------%
Analysis.PlotResult = 1;                           % Set the plot flag on
Analysis.Env_hilbert;                              % detect activities

v = repmat([.1*ones(200,1);ones(100,1)],[10 1]);   % generate true variance profile
Analysis.Sig = sqrt(v).*randn(size(v));            % Add white noise
Analysis.Env_hilbert;
Analysis.Sig = EKG1;
% ---------------- Compute mobility and complexity ------------------- %
[mobility,complexity] = Analysis.ComputeHjorthP;
fprintf(['Mobility = ',mat2str(mobility),'\n']);
fprintf(['Complexity = ',mat2str(complexity),'\n']);
%--------------------- Template matching -------------------------------%
template = Analysis.Sig(QRS(2)-60:QRS(2)+100);          % extract a heart-beat
[PsC_s,best_lag] = Analysis.TemplateMatch(template);    % Find it in the signal
fprintf(['PsuedoScore = ',mat2str(PsC_s),'\n']);
fprintf(['Location = ',mat2str(best_lag),'\n']);
figure,plot(Analysis.Sig);
hold on,plot((best_lag:best_lag+160),...
    Analysis.Sig(best_lag:best_lag+160));               % Highlight the template in Sig
title('PsuedoCorrelation Demo...');

% ------- Fetal ECG extraction in real time with neural PCA -------------%
load([fileparts(which(mfilename)),slashchar,'SampleSignals',slashchar,...
    'foetal_ecg.dat']);                                  % Load Foeatal ECG
Analysis.Sig = foetal_ecg(:,2:9)';                       % Load all the 8 channels
[~,PC] = Analysis.neural_pca(8,2);                       % get the PCs
figure;
for i = 1: 5
    subplot(5,1,i),plot(PC(i,:));
end
title('Foetal Beat detection with real-time neural-PCA...');
% ------------------------- Adaptive Filters ---------------------------%
Analysis.Sig = EKG1;
Analysis.Fs=250;
out = Analysis.adaptive_filter(2,[],250);                % Use adaptive line enhancer (type =2)
figure,plot(Analysis.Sig/max(Analysis.Sig));
hold on,plot(out/max(out));
title('Adaptive Line Enhancer with 1 Sec Delay');

% ------------------------- ECG derived Respiration --------------------%
Analysis.PlotResult = 0;                           % Set the plot flag of0
EDR = Analysis.EDR_comp;
figure,plot(Analysis.Sig/max(Analysis.Sig));
hold on,plot(EDR/max(EDR));
title('ECG Derived Resp Signal');

% ------- Single Channel Foetal ECG extraction with nonlinear filter -------------%
Analysis.Sig = foetal_ecg(:,2)';                                  % Load channel 2
Analysis.Fs=250;
output = Analysis.nonlinear_phase_filt(1, 50, 45, 1500);          % run the filter
figure,plot(Analysis.Sig);
hold on,plot(Analysis.Sig - output);
title('Foetal ECG extracted...');

% ----------------- ACC derived respiration ----------------------% 
load([fileparts(which(mfilename)),slashchar,'SampleSignals',slashchar,...
    'ACC.mat']);
Analysis.Sig = ACC;
Analysis.Fs = 200;
EDR = Analysis.ADR_comp;
figure,plot(Analysis.Sig/max(Analysis.Sig));
hold on,plot(EDR/max(EDR));
title('ECG Derived Resp Signal');

%---------------- ACC processing and Posture detection ---------------%
[output,state,EE,F,SMA] = Analysis.ACC_Act;
States ={'Steady','Slight Movement','High Activity'};
fprintf(['State is ',States{state+1},' and Energy Expenditure = ',mat2str(EE),'\n']);
