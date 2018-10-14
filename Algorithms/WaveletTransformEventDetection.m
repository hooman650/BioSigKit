function [PeakPositions] = ...
    WaveletTransformEventDetection(signal, fs, wave )
%WAVELETTRANSFORMEVENTDETECTION identifies one wave event in a given search 
%window. This is an adapted version of the algorithm described in the
%following publication:
% Martinez, J. P. et al. (2004). A Wavelet-Based ECG Delineator:
% Evaluation on Standard Databases. IEEE Transactions on Biomedical
% Engineering, 51(4):570-581.
%
%     Inputs:
%          signal - 1-dimensional signal; 
%          data / signal values
%          fs - sampling rate of signal
%          searchWindow - struct with searchWindow.start, searchWindow.end
%                      searchWindow.rPeaks 
%                       searchWindow.start and searchWindow.end in samples 
%                       definee the search region within the signal
%                       searchWindow.rPeaks gives the start of the
%                       considered RR interval (1st column) and the end of
%                       the considered RR interval (2nd column)
%           wave - considered wave; either 'P' for P-wave detection or 'T'
%           for T-wave detection (thresholds are correspondingly adapted)
%
%     Output:
%          PeakPositions - struct PeakPositions.MaxPeak with identified
%        peak in the range of the searchWindow
%
% BY Heike Leutheuser, 31.03.2016, heike.leutheuser@fau.de
% 
% Please cite this publication when using this code: 
% H. Leutheuser, S. Gradl, L. Anneken, M. Arnold, N. Lang, S. Achenbach, B.
% M. Eskofier, "Instantaneous P- and T-wave detection: assessment of three
% ECG fiducial points detection algorithms", submitted, 2016.
%
% MIT License
% 
% Copyright (c) 2016 Heike Leutheuser
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%% Edited by Hooman Sedghamiz, Sep, 2018 
% TODO: Clean up --> Preallocation MaxPeakPosition

MaxPeakPosition = [];
%initialize consecutive numbering of found wave events
ii = 1;


%adapt all values to sampling frequency of 250 Hz -> filter coefficients
%can only be used for a sampling rate of 250 Hz
if (fs ~= 250)
    %downsampling of signal
    signal = resample_new(signal,250,fs);
 
    %adaption of searchWindow to sampling rate of 250 Hz
    %     orgSearchWindow = searchWindow;
    %searchWindow.rPeaks = round(searchWindow.rPeaks/fs*250);
    %searchWindow.start = round(searchWindow.start(:,1)/fs*250);
    %searchWindow.end = round(searchWindow.end(:,1)/fs*250);
    
end

%% ================ Use Pan-Tompkin's to locate R waves ============= %%
[~,R_ind]= pan_tompkin(signal,fs,0);
searchWindow = struct;
searchWindow.rPeaks(:,1) = R_ind(1:end-1);
searchWindow.rPeaks(:,2) = R_ind(2:end);

for i = 1:max(size(searchWindow.rPeaks))
    
    %get searchWindow for sigPart -> RR interval
    startR = searchWindow.rPeaks(i,1);
    stopR = searchWindow.rPeaks(i,2);
    sigRR = signal(startR:stopR);
    
    %get search Window for wave event
    start = startR + round(0.060*fs); % Begin search 60msec after R
    stop =  stopR - round(0.100*fs); % Begin search 100msec prior to R
    
    %get rel Positions (search Window) for search within sigRR
    relStart = start - (startR-1);
    if relStart <= 0
        relStart = 1;
    end
    relStop = stop - (startR-1);
    
    %initial assumption: wave can be detected in the 4th scale
    scale = 4; %initialize scale
    while (scale <= 5) %scale

        %apply Wavelet Transform
        coefsWTRR = algorithmeATrous (sigRR, scale);
        coefsWT = coefsWTRR(relStart:relStop);
        
        %for scale 3
        coefsWTRR3 = algorithmeATrous (sigRR, 3);
        coefsWT3 = coefsWTRR3 (relStart:relStop);
        
        %calculate threshold eta
        %get RMS value of the whole signal
        if (strcmpi(wave,'P'))
            epsilon = 0.02*rootMeanSquare(coefsWTRR);
        elseif (strcmpi(wave,'T'))
            epsilon = 0.25*rootMeanSquare(coefsWTRR);
        end
        
        % Search for local maxima and minima in scale j
        l = 1;
        PosPeaktemp = double.empty;
        for k=2:max(size(coefsWT))-1
            if (coefsWT(k-1) >= coefsWT(k) && coefsWT(k) <= coefsWT(k+1) ...
                    || coefsWT(k-1) <= coefsWT(k) && coefsWT(k) >= coefsWT(k+1))
                PosPeaktemp(l) = k;
                l = l+1;
            end
        end
        clear l k
        
        %comparison to threshold epsilon -> identification if wave is present
        if ~isempty(PosPeaktemp) && length(PosPeaktemp) > 1
            PosPeak = double.empty;
            valPosPeaktemp = abs(coefsWT(PosPeaktemp)); %values
            relPosPeaktemp = valPosPeaktemp > epsilon; %relevant
            PosPeak = PosPeaktemp(relPosPeaktemp);
        else
            scale = scale+1;
            clear PosPeaktemp PosPeak coefsWTRR coefsWT
            continue;
        end
        clear relPosPeaktemp valPosPeaktemp PosPeaktemp
        
        % Calculate threshold gamma
        if (strcmpi(wave,'P'))
            gamma = 0.125*max(abs(coefsWT));
        elseif (strcmpi(wave,'T'))
            gamma = 0.125*max(abs(coefsWT));
        end
        
        %comparison to threshold gamma -> identification if significant wave is
        %present
        if ~isempty(PosPeak) && length(PosPeak) > 1
            % Search modulus maxima which is higher than gamma
            PeakMod = double.empty;
            valPeakModtemp = abs(coefsWT(PosPeak)); %values
            relPeakModtemp = valPeakModtemp > gamma; %relevant
            PeakMod = PosPeak(relPeakModtemp);
            clear valPeakModtemp relPeakModtemp PosPeak
            
            %check if zero crossing exists
            if ~isempty(PeakMod) && length(PeakMod) > 1
                %check for opposite signs
                signPeakMod = sign(coefsWT(PeakMod));
                ind2Remove = [];
                for j = 1:size(signPeakMod,1)-1
                    tmp = sum(signPeakMod(j:j+1));
                    if (tmp ~= 0)
                        ind2Remove = [ind2Remove; j+1];
                    end
                    clear tmp
                end
                PeakMod(ind2Remove) = [];
                clear j
            end
            
            if ~isempty(PeakMod) && (length(PeakMod) > 1)
              
                %look for zero crossings in scale 3; only 1 should exist
                PeakPos = double.empty;
                tmpSign = sign(coefsWT3(PeakMod(1):PeakMod(end)));
                for j = 1:max(size(tmpSign))-1
                    tmp = sum(tmpSign(j:j+1));
                    if tmp == 0
                        PeakPos = [PeakPos;j;];
                    end
                    clear tmp
                end
                clear j
                
                if isempty(PeakPos)
                    clear tmpSign
                    tmpSign = sign(coefsWT(PeakMod(1):PeakMod(end)));
                    
                    clear PeakPos
                    PeakPos = double.empty;
                    for j = 1:max(size(tmpSign))-1
                        tmp = sum(tmpSign(j:j+1));
                        if tmp == 0 %zero crossing
                            PeakPos = [PeakPos;j;];
                        end
                        clear tmp
                    end
                    clear j
                end
                
                if max(size(PeakPos)) > 1
                    %if more than one PeakPos was found --> take average;
                    %assumption of biphasic waves
                    orgPeakPos = PeakPos;
                    clear PeakPos
                    PeakPos = round(mean(orgPeakPos));
                    clear orgPeakPos
                end
                
                if ~isempty(PeakPos)
                    MaxPeakPosition(ii,1) = startR + PeakPos -1 + ...
                        relStart + PeakMod(1);
                    ii = ii+1;

                    scale = 6;
                else
                    scale = scale+1;
                    continue;
                end
            else
                scale = scale+1;
                continue;
            end
        else
            scale = scale+1;
            continue;
        end
        clear PeakMod PeakPos gamma PosPeaktemp
    end
    clear sigPart scale
    clear coefsWT coefsWT3 coefsWTRR coefsWTRR3 epsilon relStart relStop ...
        scale start startR stop stopR tmpSign
end

PeakPositions.MaxPeak = round(MaxPeakPosition*fs/250);

%nested function
    function [rmsVal] = rootMeanSquare(inputVector)
        squaredInput = inputVector.^2;
        rmsVal = sqrt(nanmean( squaredInput));
    end

%nested function
    function [resampled_data] = resample_new(original_data,fs_adapted,...
            fs_original)
        time = length(original_data)/fs_original;
        t = (1:1:length(original_data))'/fs_original;
        t_adapted = (1:1:time*fs_adapted)/fs_adapted;
        
        resampled_data = interp1(t,original_data,t_adapted, 'linear');
    end
end