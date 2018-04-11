function [WI] = wave_intensity(pressure, pressure_time,speed, speed_time)
%UNTITLED Summary of this function goes here
%   Takes pressures and speeds as input, calculates corresponding wave
%   intensity and plots this against pressure and speed

%defining starting variables for further calculations
%%Deze comments horen bij uitgecommente argumenten bovenaan
P = pressure; 
Pt = pressure_time;
U = speed; 
Ut = speed_time;
t = Ut;

% temporary usage of single time variable, will have to modify so in future
% different pressure and speed timescales can be normalized
% 
%  A = importdata(filename,"\t");
%  P = A(:,3);
%  U = A(:,2);
%  t = A(:,1);
 
 Pt = t;
 Ut = t;
 
dI = [];

%Quick differentiation using matrix properties
dP = (P(2:end)-P(1:end-1));
dU = (U(2:end)-U(1:end-1));
dt = (t(2:end)-t(1:end-1)); 

dI = ((dP./dt).*(dU./dt));


%%semi efficient while loop differentiation:
% % setting i=2 so further crude calculation of differential don't result in
% % matrix error 
% i = 2;
% %setting while loop condition to run for full n lengt of 1xn matrix
% [jj,j] = size(P);
% while i <= j
%     dP = (P(i)-P(i-1));
%     internal check to see if dP differential value makes sense
%     dPcheck = [dPcheck,dP];
%     
%     dU = (U(i)-U(i-1));
%     internal check o see if dU differential value makes sense
%     dUcheck = [dUcheck,dU];
%         
%     dt = (t(i)-t(i-1));
%     
%     calculating the value of wave intensity at certain timepoint and
%     adding it to the dI (1xn) matrix
%     value = (dP/dt)*(dU/dt);
%     dI = [dI,value];
%     
%     +1 iteration of i so it runs all values in matrix
%     i = i+1;
% end

dIt = t(1:end-1)+(t(2)-t(1))/2;


%returns Wave Intensity value for further use outside
WI = dI;

figure
%subplot pressure
fig1 = subplot(3,1,1);
plot(fig1,t,P);
title('Pressure')
set(gca,'xlim',[0,t(end)])

%subplot speed
fig2 = subplot(3,1,2);
plot(fig2,t,U)
title('Speed')
set(gca,'xlim',[0,t(end)])

%subplot WI
fig3 = subplot(3,1,3);
plot(fig3,dIt,dI)
title('Wave Intensity')
set(gca,'xlim',[0,t(end)])


end

