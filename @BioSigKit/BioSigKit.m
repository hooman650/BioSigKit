classdef BioSigKit < handle 
%% ============== BioSigKit ================== %% 
% BioSigKit is a set of useful signal processing tools that are either
% developed by me personally or others in different fields of biosignal
% processing. BioSigKit is a wrapper with a simple visual interface that
% gathers this tools under a simple easy to use platform. This tool might
% be only used for non-commercial, academic, research and learning
% purposes.

%% ============== How to start =================== %%
% example:: obj = BioSigKit(Sig, Fs, Gr)
% Where:::
% Sig: is the signal,
% Fs : Sample Rate
% Gr : Flag for showing the interface or not
% Then you can call any subroutine
%% ============= List Of Subroutines that you can call ============= %%
% ------- Algorithm -------------------- How to Call ---------------
% (1) Pan-Tompkins Algorithm :        obj.PanTompkins
% (2) Phase Space Reconstruction :    obj.PhaseSpaceAlg
% (3) RST State-Machine :             obj.StateMachine
% (4) Filter Bank:                    obj.FilterBankQRS
% (5) MTEO qrstAlg:                   obj.MTEO_qrstAlg 
% (6) AMPD:                           obj.AMPD_PAlg
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
           %---------- Check Signal -------------%
           if min(size(Sig)) > 1
              Warning({'BioSigKit currently only supports Single Channel Signals!',...
                  'Only Loaded Channel 1!'}); 
              [~,ind] = min(size(Sig));
              if ind == 1
                  Sig = Sig(1,:);
              else
                  Sig = Sig(:,1);
              end
           end
           %--------- Pack Necessary Parameters -------------%
           obj.Sig = Sig(:);
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
          data = load([Path,'\',FileName]);
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
          [R,V] = PhaseSpaceQRS(obj.Sig,obj.Fs,obj.PhasePeriod,...
              obj.PlotResult);
          obj.Results.R(1,:) = R(:,1);
      end
      %% ================= MTEO QRST Delineation ============== %%
       %------ Emlpoys MultiValued MTEO to delineate ECG---------- %
       % Call : obj.MTEO_qrstAlg OR MTEO_qrstAlg(obj)
       % Outputs: Delineated Waves (QRSTP)
       function [R,Q,S,T,P_w] = MTEO_qrstAlg(obj)
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
          if isempty(obj.ScalogramL)
             obj.ScalogramL = ceil(length(obj.Sig)/2) - 1;
          end
          try
            R = AMPD_P(obj.Sig,obj.ScalogramL,obj.PlotResult); 
            obj.Results.R = R;
          catch ME
             msgbox(ME.message); 
          end
            
       end
     %% ================== Filter Bank QRS Detector ================== %%
     function R = FilterBankQRS(obj)
          R = nqrsdetect(obj.Sig,obj.Fs);   
          obj.Results.R(1,:) = R(:);
     end
     %% ==================== Pan-Tompkins QRS Detector ================ %%
     function [R_amp,R_ind] = PanTompkins(obj)
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
             colors = distinguishable_colors(length(PP));
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
    
end