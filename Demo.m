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
%---------------- Load a Sample ECG Signal from (\SampleSignals) directory -----------------%
addpath(genpath(fileparts(which(mfilename))));
load('ECG1.mat');
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
