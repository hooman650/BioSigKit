classdef BioSigKit < handle 
%% ============== BioSigKit ==================  
% BioSigKit is a set of useful signal processing tools that are either
% developed by me personally or others in different fields of biosignal
% processing. BioSigKit is a wrapper with a simple visual interface that
% gathers this tools under a simple easy to use platform. This tool might
% be only used for non-commercial, academic, research and learning
% purposes.
%
%% ============== How to start =================== 
% example:: obj = BioSigKit(Sig, Fs, Gr)
% Where:::
% Sig: is the signal
% Fs : Sample Rate
% Gr : Flag for showing the interface or not
% Then you can call any subroutine
%% ====List Of Subroutines that you can call for QRS detection ========= 
% ------- Algorithm -------------------- How to Call ---------------
% (1) Pan-Tompkins Algorithm :        obj.PanTompkins
% (2) Phase Space Reconstruction :    obj.PhaseSpaceAlg
% (3) RST State-Machine :             obj.StateMachine
% (4) Filter Bank:                    obj.FilterBankQRS
% (5) MTEO qrstAlg:                   obj.MTEO_qrstAlg 
% (6) AMPD:                           obj.AMPD_PAlg
%% ==== List of all subroutines for ACC, EMG and etc processing ======== 
% (7) Activity Detection Hilbert:     obj.Env_hilbert
            % ---------------- Inputs ------------------ %
            % Smooth_window : Length of smoothing window in nr of sample
            % threshold_style : Set 0 for Automatic, Set 1 for Manual
            % DURATION : The number of samples for signal to be above
            % threshold to be considered active
            % ---------------- Output ------------------ %
            % alarm :  Pattern of activities
            % ---------------- Demo -------------------- %
            % v = repmat([.1*ones(200,1);ones(100,1)],[10 1]);                    % generate true variance profile
            % obj.sig = sqrt(v).*randn(size(v));
            % obj.Env_hilbert;
%-----------------
% (8) Comp Mobility and Complexity:   obj.ComputeHjorthP
%-----------------
% (9) Posture detection 3 Chann ACC:  obj.ACC_Act
            % ------------- Inputs ----------------------- %
            % obj.sig : 3 axis Accelerometer signal where, each row is an axis
            % and each column a sample (e.g. (3,:))
            % obj.Fs : Sampling frequency of the Accelerometer 
            % ------------- Output ----------------------- %
            % output : adaptively filtered ACC channels based on activity
            % state : activity level (0:steady,1:walking,2:joggin)
            % EE : Energy Expenditure over 1 min (or length sig)
            % F : Bandpass filter in Hz
            % SMA : Signal Magnitude area
%------------------
% (10)PsuedoCorr template matching :  obj.TemplateMatch
            % ------------------- Inputs --------------------- %
            % template :  A template in the form of a vector, the length of
            % the template should be smaller than the signal.
            % lag : a lag in terms of nr of samples to move the template,
            % it should be smaller than the length of the template
            % ------------------- Outputs -------------------- %
            % PsC_s : template matching score in range [0,1]. 
            % best_lag: the lag that gave the highest correlation score.
%-----------------
% (11)ECG derived respiration :       obj.EDR_comp
%-----------------
% (12)ACC derived respiration :       obj.ADR_comp
%% ===== General Projective, linear and nonlinear filterings ============ %%
% (13)Real-time neural PCA:           obj.neural_pca
            % ----------------- Inputs ------------------- %
            % X : Multi-channel signal, each row represents a channel and
            % each column a sample. 
            % nPCA: Number of PCAs to extract
            % nit: Number of iterations to go through the whole signal
            % T : Learning rate in range [0,1], default:0.9
            % ---------------- Outputs ------------------- %
            % EigVec: Eigen vectors
            % PC : PCs
            % Eigval : Eigenvalues
%-----------------
% (14)Adaptive Filtering:             obj.adaptive_filter
%                 * RLS : Recursive Least Squares Filter
%                 * ALE : Adaptive Line Enhancer (Delayed Filter)
%                 * VLALE : Variable Leaky Adaptive Line Enhancer
%                 * NLMS_ecg : Normalized Least Mean Squares filter for artficat
%                   removal in ECG based on 3 channel Accelerometer recordings  
%-------------------- Inputs ---------------------------%
           % type: type of the filter (numeric): 
           %       (1) RLS : Recursive Least Squares Filter
           %       (2) ALE : Adaptive Line Enhancer (Delayed Filter)
           %       (3) VLALE : Variable Leaky Adaptive Line Enhancer
           %       (4) NLMS_ecg : Normalized Least Mean Squares filter for
           %       artficat removal in ECG based on 3 channel Accelerometer
           %       recordings
           % ref: Reference signal:
           %        * For RLS filter it is single channel (1*N)
           %        * For NLMS_ECG filter it should be 3 Channel
           %        Accelerometer (3*N)
           % obj.Sig: input signal to clean (single channel vector)
           % order : order of the filter (for VLALE and ALE also delay)
           % lambda : learning rate(0<= lambda <=1, usually close to 1)
           %-------------------- Outputs --------------------------%
           % output: cleaned signal
           % error_sig : error signal 
%-----------------
% (15)Nonlinear phasespace filtering: obj.nonlinear_phase_filt
%-------------------- Method ---------------------------%
         % Employs nonlinear phasespace filter to clean up the signal. This
         % method is very strong and even able to extract foetal ecg from
         % single channel maternal recordings. Please refer to examples of
         % BioSigKit for further details.
         %-------------------- Inputs ----------------------------%
         % sig : Signal to be analyzed (single channel)
         % t : Number of samples for computing delayed phase space (def: 1)
         % d : Embedding dimension to consider (def: 50)
         % m : dimension of null space (def: 49)
         % r : number of nearest neighbors to consider
         % (normally a large number def: length(sig)/4)
         % --------------------- Output ------------------------ %
         % output : Cleaned Signal
         % --------------------- example ----------------------- %
         % output = projective(foetal_ecg(:,2), 1, round(Fs/5), round(Fs/6.25), 1500);
% (16)Teager-Keiser energy operator:  obj.TK_comp

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
%% ============== End Helper ================= %%
    %------------ Class Definition of BioSigKit Toolbox -------------- %
    properties(GetAccess = 'public', SetAccess = 'private')
        panel = [];                                                        % Main Visualization Panel
        SigView = [];                                                      % Signal View Axis
        FreqValHolder;                                                     % Holds SampFreq from interface
        Alg;                                                               % Alg type from interface
        Status;                                                            % Loader
        LoadedSig;                                                         % Loaded Sig
        path_alg = addpath(genpath(fileparts(fileparts(which(mfilename)))));% Path of Algorithm
        slashchar = char('/'*isunix + '\'*(~isunix));                      % OS dependent /
    end  
    %------------ Interface and private methods -------------%
    methods(Access = protected)
           BioSigKitPanel(obj);             % Setup the interface
    end
    %------------ Properties for BioSigKit ------------------%
    properties(GetAccess = 'public', SetAccess = 'public')
           Fs;                              % Sample Freq
           Sig;                             % Signal
           Gr = 0;                          % Flag for showing the interface
           Results;                         % Struct holding results
           statsC;                          % Holding Stats
           PlotResult = 0;                  % Verbose results of each algorithm
           PhasePeriod = 0.020;             % Phase Period Used for Phase Space
           ScalogramL;                      % Scalogram Length
           complexity;                      % Complexity based on Hjorth Param
           mobility;                        % mobility based on Hjorth
           ACC;                             % 3 channel ACC
    end
    %% ------------------ Methods ----------------------------- %%
    methods 
       %% --------------------- Constructor -------------------------- %%
       function obj = BioSigKit(Sig, Fs, Gr)
           % --------- Check Inputs -------------%
           if nargin < 3 
             Gr = 0;
             if nargin < 2
              Fs = 250; 
              if nargin < 1
                 BioSigKitPanel(obj);
                 return;
              end
              Gr = 1;
             end
           end
           %--------- Pack Necessary Parameters -------------%
           obj.Sig = Sig;
           obj.Gr = Gr;
           obj.Fs = Fs;
           obj.ScalogramL = ceil(length(Sig)/2) - 1;
           %--------- Create the interface of Flag is on ------------- %
           if obj.Gr
              %------ Initialize Figure------%
              BioSigKitPanel(obj);
              %------ Update Figure -----------%
              UpdateFig(obj);
           end
       end
      %% ----------------------Run Algorithms method-------------------- %%
      function RunAlg(obj)
          if isempty(obj.Sig)
              msgbox('First Load a Signal!'); 
              return;
          end
          [~,ind] = min(size(obj.Sig));
          if ind == 1
                  obj.Sig = obj.Sig(1,:);
          else
                  obj.Sig = obj.Sig(:,1);
          end
          % ------------------ Set the Values --------------------------%
          obj.Fs = str2double(obj.FreqValHolder.String);
          % ------------------ Start Loader ----------------------------%
          obj.Status.start;
          obj.Status.setBusyText('Processing...');
          pause(0.01);
          UpdateFig(obj);
          obj.Results = [];
          ResetStats(obj);
          % --------------- Run the appropriate method ------------------%
        try
          switch obj.Alg.Value
              % ----- Pan-Tompkins -------%
              case 1
                 PanTompkins(obj);
              % ----- Phase Space --------%
              case 2
                 PhaseSpaceAlg(obj);
              % ----- RST State-Machine ------%
              case 3
                 StateMachine(obj);
              % ----- QRS Filter-Bank -------- %
              case 4
                 FilterBankQRS(obj);
              % ---------- QRST MTEO ------------ %
              case 5
                 MTEO_qrstAlg(obj); 
              %----------- AMPD Peak Detector --------%
              case 6
                 AMPD_PAlg(obj);
              otherwise
                 return;
          end
         % -------------------- Update Figure --------------------- %
           visualizeResults(obj);    
        catch ME
           msgbox(ME.message);
        end
          % ------------------- Update Loader ---------------------- %
          obj.Status.setBusyText('Done!');
          pause(1);
          obj.Status.stop;
      end
      %% ---------------------- Import Sig ------------------------------ %%
      function ImportSig(obj)
          [FileName,Path] = uigetfile(fullfile(pwd,...
                '*.mat'),...
                'Select Your Signal');
          if ~FileName
              return;
          end
          data = load([Path,obj.slashchar,FileName]);
          FN = fields(data);
          if ~isempty(FN)
             obj.Sig = data.(FN{1}); 
          else
             msgbox('Bad Input Signal! Input should be a vector!');
             return;
          end
          if ~isempty(obj.LoadedSig)
             obj.LoadedSig.String = [Path,FileName];
             % ----------------- Update Figure ------------------ %
             UpdateFig(obj);
             obj.Results = [];
          end
          
      end
      %% ================= Phase Space ===================== %%
       %----- Employs Phase Space for QRS detection ------ %
       % Call : obj.PhaseSpaceAlg  OR PhaseSpaceAlg(obj)
       % Outputs :  
       % R : R Beats, 
       % V : Processed area computed from Phase Space
      function [R,V] = PhaseSpaceAlg(obj)
          obj.Results = [];
          [R,V] = PhaseSpaceQRS(obj.Sig,obj.Fs,obj.PhasePeriod,...
              obj.PlotResult);
          obj.Results.R(1,:) = R(:,1);
      end
      %% ================= MTEO QRST Delineation ============== %%
       %------ Emlpoys MultiValued MTEO to delineate ECG---------- %
       % Call : obj.MTEO_qrstAlg OR MTEO_qrstAlg(obj)
       % Outputs: Delineated Waves (QRSTP)
       function [R,Q,S,T,P_w] = MTEO_qrstAlg(obj)
           obj.Results = [];
           [R,Q,S,T,P_w] = MTEO_qrst(obj.Sig,obj.Fs,obj.PlotResult);
           obj.Results.R(1,:) = R(:,1);
           obj.Results.Q(1,:) = Q(:,1);
           obj.Results.S(1,:) = S(:,1);
           obj.Results.T(1,:) = T(:,1);
           obj.Results.P(1,:) = P_w(:,1);
       end
     %% =================== AMPD Peak Detection ================== %%
     % ------------- Employs AMPD Algorithm for Peak detection -----------%
     % Inputs : 
     % Sig
     % L : Max sample number for Scalogram computation(Leave free if have not idea)
       function R = AMPD_PAlg(obj)
          obj.Results = [];
          if isempty(obj.ScalogramL)
             obj.ScalogramL = ceil(length(obj.Sig)/2) - 1;
          end
          try
            R = AMPD_P(obj.Sig,obj.ScalogramL,obj.PlotResult); 
            obj.Results.R(1,:) = R(:,1);
          catch ME
             msgbox(ME.message); 
          end
            
       end
     %% ================== Filter Bank QRS Detector ================== %%
     function R = FilterBankQRS(obj)
          obj.Results = [];
          R = nqrsdetect(obj.Sig,obj.Fs);   
          obj.Results.R(1,:) = R(:);
     end
     %% ==================== Pan-Tompkins QRS Detector ================ %%
     function [R_amp,R_ind] = PanTompkins(obj)
         obj.Results = [];
         [R_amp,R_ind]=pan_tompkin(obj.Sig,obj.Fs,obj.PlotResult);
         obj.Results.R(1,:) = R_ind(:);
     end
     %% ===================== Simple State-Machine ===================== %%
     % Outputs : R_i : Index of R peaks, R_a : Amplitude
     function [R_i,R_a,S_i,S_a,T_i,T_a,Q_i,Q_a] = StateMachine(obj)
         [R_i,R_a,S_i,S_a,T_i,T_a,Q_i,Q_a] = SimpleRST(obj.Sig,obj.Fs,...
             obj.PlotResult);
         obj.Results.R(1,:) = R_i;
         obj.Results.Q(1,:) = Q_i;
         obj.Results.S(1,:) = S_i;
         obj.Results.T(1,:) = T_i;
     end
     %% ===============Update the plot in interface ========== %%
     function visualizeResults(obj)
         % --------------- First the Figure ------------------%
         if ~isempty(obj.Results)
             PP = fields(obj.Results);
             Index = [5,10,15;3,8,13;2,7,12;1,6,11;4,9,14];
             colors = distinguishable_colors(length(PP),{'k','y'});
             for i= 1: length(PP)
                 % ----------- Update Signal ------------------ %
                 line(repmat(obj.Results.(PP{i})(1,:),[2 1]),...
                      repmat([min(obj.Sig-mean(obj.Sig))/2; max(obj.Sig-mean(obj.Sig))/2],...
                      size(obj.Results.(PP{i})(1,:))),'LineWidth',1.5,...
                      'LineStyle','-.','color',colors(i,:),'Parent',obj.SigView);
                 % ----------- Update Stats -------------------- %
                 intervals = round((diff(obj.Results.(PP{i})(1,:)))./obj.Fs,3);
                 obj.statsC.Children(Index(i,1)).String = mat2str(max(intervals));
                 obj.statsC.Children(Index(i,2)).String = mat2str(round(mean(intervals),3));
                 obj.statsC.Children(Index(i,3)).String = mat2str(length(obj.Results.(PP{i})(1,:)));
             end
         end
     end
     %% ================= Update VisualInterface Axis ================= %%
     function UpdateFig(obj)
              cla(obj.SigView);
              plot(obj.Sig - mean(obj.Sig),'LineWidth',2,'Parent',obj.SigView,'color','yellow');
              set(obj.SigView,'XGrid','on',...
                 'YGrid','on','XMinorGrid','on','YMinorGrid','on',...
                 'Color',[0,0,0],'YColor',[1,1,1],'XColor',[1,1,1]);
              axis(obj.SigView,'tight');
     end
     %% ================ Update Stats ================================== %%
     function ResetStats(obj)
        for j = 1: 15
           obj.statsC.Children(j).String = '\bf --';
        end
     end
    end
    %% ============ Experimental Methods not in GUI Yet ================== %%
    methods
        %% ------ Use Hilber Tr to detect Activity in signals --------- %%
        function alarm = Env_hilbert(obj,Smooth_window,threshold_style,...
                DURATION)
            % ---------------- Inputs ------------------ %
            % Smooth_window : Length of smoothing window in nr of sample
            % threshold_style : Set 0 for Automatic, Set 1 for Manual
            % DURATION : The number of samples for signal to be above
            % threshold to be considered active
            % ---------------- Output ------------------ %
            % alarm :  Pattern of activities
            % ---------------- Demo -------------------- %
            % v = repmat([.1*ones(200,1);ones(100,1)],[10 1]);                    % generate true variance profile
            % obj.sig = sqrt(v).*randn(size(v));
            % obj.Env_hilbert;
            % ---------------- Input Handling ------------------%
            if nargin < 4
               DURATION = 20;                                                     % default
               if nargin < 3
                  threshold_style = 1;                                            % default 1 , means it is done automatic
                   if nargin < 2
                      Smooth_window = 20;                                         % default for smoothing length
                   end
                end
            end
            alarm = envelop_hilbert(obj.Sig,...
                Smooth_window,...
                threshold_style,DURATION,obj.PlotResult);
        end
        %% ------ Employ Hjorth Parameters to analyze a signal --------- %%
        function [mobility,complexity] = ComputeHjorthP(obj)
            % ---------------- Hjorth Parameters ------------------- %
            % ---------------- Output ----------------------%
            % mobility : Central frequency
            % complexity : bandwith of the signal
              [mobility,complexity] = simpleHjorth(obj.Sig,obj.Fs);
              obj.mobility = mobility;
              obj.complexity = complexity;
        end
        %% ------ Activity Detection in ACC signals ---------------- %%
        function [output,state,EE,F,SMA] = ACC_Act(obj)
            % ------------- Inputs ----------------------- %
            % obj.sig : 3 axis Accelerometer signal where, each row is an axis
            % and each column a sample (e.g. (3,:))
            % obj.Fs : Sampling frequency of the Accelerometer 
            % ------------- Output ----------------------- %
            % output : adaptively filtered ACC channels based on activity
            % state : activity level (0:steady,1:walking,2:joggin)
            % EE : Energy Expenditure over 1 min (or length sig)
            % F : Bandpass filter in Hz
            % SMA : Signal Magnitude area
             if isempty(obj.Sig)
                error('Please first load your ACC to obj.ACC!'); 
             end
             [output,state,EE,F,SMA] = ACC_Activity(obj.Sig,obj.Fs);
        end
 %% ------------- Template Matching with Psuedo Corr--------------------- %%
        function [PsC_s,best_lag] = TemplateMatch(obj,template,lag)
            % ------------------- Inputs --------------------- %
            % template :  A template in the form of a vector, the length of
            % the template should be smaller than the signal.
            % lag : a lag in terms of nr of samples to move the template,
            % it should be smaller than the length of the template
            % ------------------- Outputs -------------------- %
            % PsC_s : template matching score in range [0,1]. 
            % best_lag: the lag that gave the highest correlation score.
            if nargin < 3
               [PsC_s,best_lag] = PsC(template,obj.Sig);
            else
               [PsC_s,best_lag] = PsC(template,obj.Sig,lag);
            end
              
        end
      %% ---------------- Real time Neural PCA Filter ----------------- %%
        function  [EigVec,PC,Eigval] = neural_pca(obj,nPCA,nit)
            % ----------------- Inputs ------------------- %
            % X : Multi-channel signal, each row represents a channel and
            % each column a sample. 
            % nPCA: Number of PCAs to extract
            % nit: Number of iterations to go through the whole signal
            % T : Learning rate in range [0,1], default:0.9
            % ---------------- Outputs ------------------- %
            % EigVec: Eigen vectors
            % PC : PCs
            % Eigval : Eigenvalues
            % ---------------- Check Inputs -------------- %
            if size(obj.Sig,1) < 2 
                fprintf('|#| BioSigKit> Input signals should be channles*N.\n');
            end
            [EigVec,PC,Eigval] = RTpca(obj.Sig,nPCA,nit);
        end
       %% ----------------- Adaptive Filters --------------------- %%
       function [output,error_sig] = adaptive_filter(obj,type,ref,...
               order,lamda)
           %-------------------- Inputs ---------------------------%
           % type: type of the filter (numeric): 
           %       (1) RLS : Recursive Least Squares Filter
           %       (2) ALE : Adaptive Line Enhancer (Delayed Filter)
           %       (3) VLALE : Variable Leaky Adaptive Line Enhancer
           %       (4) NLMS_ecg : Normalized Least Mean Squares filter for
           %       artficat removal in ECG based on 3 channel Accelerometer
           %       recordings
           % ref: Reference signal:
           %        * For RLS filter it is single channel (1*N)
           %        * For NLMS_ECG filter it should be 3 Channel
           %        Accelerometer (3*N)
           % obj.Sig: input signal to clean (single channel vector)
           % order : order of the filter (for VLALE and ALE also delay)
           % lambda : learning rate(0<= lambda <=1, usually close to 1)
           %-------------------- Outputs --------------------------%
           % output: cleaned signal
           % error_sig : error signal 
           % ------------------- Process Inputs -------------------%
           output= [];
           error_sig = [];
           if nargin < 2
              fprintf('|#| BioSigKit> Please select a filter type! (1-4).\n'); 
              fprintf('|#| BioSigKit> Exiting.');
              return;
           end
           if nargin < 5
               lamda = 1;
               if nargin < 4
                   order = 1*obj.Fs;
                   if nargin < 3
                      ref= [];
                   end
               end
           end
           % ------------------- Run the Filters-------------------%
           switch type
               % ------ Recursive Least Squars (RLS) ------ %
               case 1 
                   if isempty(ref) || size(ref,1) > 1
                      fprintf('|#| BioSigKit> Ref signal should be 1*N!\n');
                      return;
                   end
                   fprintf('|#| BioSigKit> Adaptive RLS Filter...\n');
                   [output,error_sig] = RLS(ref,obj.Sig,order,lamda);
               % ------ Adaptive Line Enhancer (ADLE) ------ %
               case 2
                   fprintf('|#| BioSigKit> Adaptive Delayed Line Enhancer...\n');
                   [output,error_sig] = ALE_imp(obj.Sig,obj.Fs,order);
               % ------ Variable Leaky ALE (VLALE) ------ %
               case 3 
                   fprintf('|#| BioSigKit> Variable Leaky ALE Running...\n');
                   [output,error_sig] = VLALE_imp(obj.Sig,obj.Fs,order); 
               % ------ ECG artifact removal with 3 channel ACC ------ %
               case 4
                   if isempty(ref) || size(ref,1) < 3 || size(ref,1) > 3 
                      fprintf('|#| BioSigKit> Accelerometer signals should be 3*N!\n');
                      return;
                   end
                   fprintf('|#| BioSigKit> ECG Artifact removal with NLMS...\n');
                   output = NLMS_ecg(ref,obj.Sig,order,obj.PlotResult);
               otherwise 
                   fprintf('|#| BioSigKit> Filter type not recognized!\n');
           end
            fprintf('|#| Done!\n');
       end
       %% ----------------- Non-Linear PhaseSpace Filter -------------- %%
       function output = nonlinear_phase_filt(obj,t,d,m,r)
         %-------------------- Method ---------------------------%
         % Employs nonlinear phasespace filter to clean up the signal. This
         % method is very strong and even able to extract foetal ecg from
         % single channel maternal recordings. Please refer to examples of
         % BioSigKit for further details.
         %-------------------- Inputs ----------------------------%
         % sig : Signal to be analyzed (single channel)
         % t : Number of samples for computing delayed phase space (def: 1)
         % d : Embedding dimension to consider (def: 50)
         % m : dimension of null space (def: 49)
         % r : number of nearest neighbors to consider
         % (normally a large number def: length(sig)/4)
         % --------------------- Output ------------------------ %
         % output : Cleaned Signal
         % --------------------- example ----------------------- %
         % output = projective(foetal_ecg(:,2), 1, round(Fs/5), round(Fs/6.25), 1500);
         %---------------------- Input Handling ----------------------%
            if nargin < 5
             r = round(length(obj.Sig)/4); 
             if nargin < 4
               m = 49;          
               if nargin < 3
                     d = 50;
                   if nargin < 2 
                       t = 1; 
                   end
               end
             end
            end
            % ------------------- Run filter ------------------- %
            fprintf('|#| BioSigKit> Running Non-linear Filter...\n');
            output = projective (obj.Sig, t, d, m, r);
            fprintf('|#| Done!\n');
       end
       %% =================== ECG derived Respiration =============== %%
       function EDR = EDR_comp(obj)
           % --------------------- Method ------------------------ %
           % 1) Use Pan-tompkins for R peak detection
           % 2) Extract templates
           % 3) Use neural PCA to extract the eigenvectors
           % 4) construct EDR signal.
           % ---------------- Compute R peaks --------------------- %
              obj.PanTompkins();
           % --------------- Segment window size ------------------ %
              Win = round(0.356*obj.Fs);
              if ~mod(Win,2)
                  L = Win/2;
                  Win = Win + 1;
              else
                  L = (Win-1)/2;
              end
           % --------------- Segment the signal --------------------- %
              R = zeros(Win,length(obj.Results.R));
              for i = 1 : length(obj.Results.R)   
                  if obj.Results.R(i)-L < 1
                     dummy = Win - length(obj.Sig(1:obj.Results.R(i)+L));
                     R(:,i) = [ones(dummy,1)*mean(obj.Sig(1:obj.Results.R(i)+L));...
                         obj.Sig(1:obj.Results.R(i)+L)]; 
                  elseif obj.Results.R(i)+L > length(obj.Sig)
                     dummy = Win - length(obj.Sig(obj.Results.R(i)-L:end));
                     R(:,i) = [obj.Sig(obj.Results.R(i)-L:end);...
                         ones(dummy,1)*mean(obj.Sig(obj.Results.R(i)-L:end))]; 
                  else
                     R(:,i) = obj.Sig(obj.Results.R(i)-L:obj.Results.R(i) + L); 
                  end  
              end
           % ------------------- Real Time PCA ------------------------ %
              temp_ecg = obj.Sig;
              obj.Sig = R';
              PC = neural_pca(obj,size(R,2),2);
              obj.Sig = temp_ecg;
              PC = PC(:,1);
           % ------------------- Build EDR Signal --------------------- %
              xx = 1 : length(temp_ecg);
              interp1 = [0 obj.Results.R length(temp_ecg)];
              PC = [0 PC' 0];
              EDR = spline(interp1,PC,xx);
              EDR = detrend(EDR);
       end
       %% ================ 3 Channel ACC derived Respiration ========== %%
       function ADR = ADR_comp(obj)
            %------------ Method -----------------------------%
            % (1) Adaptively filter the ACC signals
            % (2) Real Time PCA
            % (3) Mix PCs and reconstruct the signal
            %------------------- Input handling ----------------%
            if size(obj.Sig,1) < 3
                fprintf('|#| BioSigKit> ACC signal should be 3*n!');
                return;
            end
            
            output = ACC_Activity(obj.Sig,obj.Fs);
            % ------------------- Real Time PCA ------------------------ %
            PC = neural_pca(obj,3,2);
            PC = PC(:,1);
            ADR = output'*PC;
            ADR = detrend(ADR);
       end
       %% =================== Teager-Keiser Energy Op =========== %%
       function [ey,ex] = TK_comp(obj)
           % --------------- Outputs ----------------%
           % ey: energy operator
           % ex: Teager operator
           [ey,ex]=energyop(obj.Sig,obj.PlotResult);
       end
    end
end 
