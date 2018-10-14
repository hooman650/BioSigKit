function [filteredSig] = algorithmeATrous (signal, scale)
%ALGORITHMEATROUS applies the algorithme ? trous implementation as
%suggested by Martinez et al. (2004): A Wavelet-based ECG delineator:
%evaluation on standard databases to the signal up to indented scale.
%filteredSig is the high-pass part of the signal at the chosen scale.
%
%     Inputs:
%          signal - 1-dimenionsal signal.
%          scale - intented scale of algorithme a trous; scale up to 5 can
%                   be realised.
%
%     Output:
%          filteredSig - high-pass part of the signal at the chosen scale
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


for i = 1:scale
    switch i
        case 1
            filteredSig = signal;
            %filtering with G(z)
            bG = 2*[1 -1];
            %             delayG = 1; %n -> n-1
            
            %filtering with H(z)
            %used in the following
            hSigTmp = signal;
            bH = 1/8*[1 3 3 1];
            %             delayH = 2;
        case 2
            %filtering with G(z^2)
            bG = 2*[1 0 -1];
            %             delayG = 2; %n -> n-2
            
            %filtering with H(z^2)
            bH = 1/8*[1 0 3 0 3 0 1];
            %             delayH = 4;
        case 3
            %filtering with G(z^4);
            bG = 2*[1 0 0 0 -1];
            
            %filtering with H(z^4);
            bH = 1/8*[1 0 0 0 3 0 0 0 3 0 0 0 1];
        case 4
            %filtering with G(z^8)
            bG = 2*[1 zeros(1,7) -1];
            
            %filtering with H(z^8)
            bH = 1/8*[1 zeros(1,7) 3 zeros(1,7) 3 zeros(1,7) 1];
        case 5
            %filtering with G(z^16)
            bG = 2*[1 zeros(1,15) -1];
    end
    
    aG = 1;
    aH = 1;
    
    delayG = 2^(scale-1);
    delayH = 2^((scale-1)-1);
    
    %filtering with G
    filteredSig = modFilter(bG,aG,hSigTmp,delayG);
    clear bG aG delayG
    
    if (scale < 5)
        %filtering with H
        hSigTmp = modFilter(bH,aH,hSigTmp,delayH);
        clear bH aH delayH
    end
    
    
end


%nested function with filtering
    function sigOutput = modFilter(bVar,aVar,sigInput,delayVar)
        sigOutput = filter(bVar,aVar,sigInput);
        
        %considering the "Einschwingzeit" -> length of filter coefficients - 1
        [~,m] = size(bVar);
        sigOutput(1:m-1,1) = NaN;
        sigOutput(end-(m-1)+1:end,1) = NaN;
        clear m
        
        %adapt signal according to delay (introduced by the filtering itself)
        [n,~] = size(sigInput);
        sigOutput(1:delayVar) = [];
        sigOutput(n-delayVar+1:n,1) = NaN;
        clear n
    end

end