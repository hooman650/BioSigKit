function [ey,ex]=energyop(sig,gr)
%% %calculates the energy operator of a signal

%% %input

%1. Raw signal (Vector)
%2. gr (Plot or not plot)

%% %Output

%Energy operator signal (ey)
%Teager operator (ex)
%% %Method

%The Teager Energy Operator is determined as
	%(x(t)) = (dx/dt)^2+ x(t)(d^2x/dt^2) (1.1)
%in the continuous case (where x_ means the rst derivative of x, and x means the second
%derivative), and as
	%[x[n]] = x^2[n] + x[n - 1]x[n + 1] (1.2)
%in the discrete case.
%% Method
%Note that the function is vectorized for optimum processing speed(Keep calm and vectorize)
%Author : Hooman Sedghamiz 

%% hoose792@student.liu.se
%%
if nargin<2
    gr=0;
end

sig=sig(:);



%% (x(t)) = (dx/dt)^2+ x(t)(d^2x/dt^2) 
%Operator 1
y=diff(sig);
y=[0;y];
squ=y(2:length(y)-1).^2;
oddi=y(1:length(y)-2);
eveni=y(3:length(y));
ey=squ - (oddi.*eveni);
%% [x[n]] = x^2[n] - x[n - 1]x[n + 1] 
%operator ex
squ1=sig(2:length(sig)-1).^2;
oddi1=sig(1:length(sig)-2);
eveni1=sig(3:length(sig));
ex=squ1 - (oddi1.*eveni1);
ex = [ex(1); ex; ex(length(sig)-2)]; %make it the same length

%% plots

if gr
figure,ax(1)=subplot(211);plot((sig/max(sig))-mean(sig/max(sig)),'b'),
hold on,
plot((ey/max(ey))-mean(ey/max(ey)),'Linewidth',2,'LineStyle','--','color','r'),
axis tight;
hleg1=legend('Original Signal','Energy Operator');
set(hleg1,'Location','NorthWest')
ax(2)=subplot(212);plot((sig/max(sig))-mean(sig/max(sig)),'b'),
hold on,
plot((ex/max(ex))-mean(ex/max(ex)),'Linewidth',2,'LineStyle','--','color','g'),
hleg2=legend('Original Signal','Teager Energy');
set(hleg2,'Location','NorthWest')
axis tight,
zoom on;
linkaxes(ax,'x');
end