function Analysis = RunBioSigKit(Sig,Fs,Gr)
%% =========== This Function initiates BioSigKit =========== %%
%% Inputs :
% Sig: Input Signal
% Fs : Sample Frequency
% Gr : Set 1 if you want to use the interface otherwise 0.
%% Outputs :
% Analysis object: This is an object with subroutines detailed below.
%% ============= List Of Subroutines that you can call ============= %%
% ------- Algorithm -------------------- How to Call ---------------
% (1) Pan-Tompkins Algorithm :        Analysis.PanTompkins
% (2) Phase Space Reconstruction :    Analysis.PhaseSpaceAlg
% (3) RST State-Machine :             Analysis.StateMachine
% (4) Filter Bank:                    Analysis.FilterBankQRS
% (5) MTEO qrstAlg:                   Analysis.MTEO_qrstAlg 
% (6) AMPD:                           Analysis.AMPD_PAlg
%% ================= Analysis object details ===================== %%
% Analysis.Results.R :                       Indice of R peaks
% Analysis.Results.Q :                       Indice of Q peaks
% Analysis.Results.S :                       Indice of S peaks
% Analysis.Results.T :                       Indice of T peaks
% Analysis.Results.P :                       Indice of P peaks
%% ==================== Examples ================================== %%
%-------------- Exmp1 : --------------------
% Analysis = RunBioSigKit();                    % Opens GUI   
%-------------- Exmp2 : --------------------
% Analysis = RunBioSigKit(ECG1);                % Uses ECG as input, opens GUI
%-------------- Exmp3 : --------------------
% Analysis = RunBioSigKit(ECG1,250,0);          % Uses ECG1 as input,Fs=250
% Analysis.MTEO_qrstAlg;                        % Runs MTEO algorithm
% QRS = Analysis.Results.R;                     % Stores R peaks in QRS
% Analysis.Fs = 360;                            % Change SampFreq to 360
% Analysis.Sig = ECG2;                          % Change input sig to ECG2
% Analysis.PanTompkins;                         % Run Pan-Tompk Algorithm
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
%% =================== Initialize =================================== %%
if nargin < 3
   Gr = 1;
   if nargin < 2
      Fs = 250;
      if nargin < 1
         Analysis = BioSigKit();
         return;
      end
   end
end

Analysis = BioSigKit(Sig,Fs,Gr);

end