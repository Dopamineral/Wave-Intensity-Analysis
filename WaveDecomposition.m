function [] = WaveDecomposition(PP_isolated,UU_isolated,speed_output,time_isolated,intensity_isolated,experiment)
%Calculates forward and backward waves

%Calculation of forward and backward waves
c = speed_output; 
rho = 1050; 
PP_isolated_SI = PP_isolated; 
UU_isolated_SI = UU_isolated; 
WI_isolated_time = time_isolated;
WI_isolated = intensity_isolated;
dt = time_isolated(2)-time_isolated(1);
%decomposing pressure
%%%FORMULAS: SEE RADEMAKER ET AL. ARTERIAL WAVE INTENSITY AND
%%%VENTRICULAR... page 269-270

PP_forward = ((PP_isolated_SI - PP_isolated_SI(1)) + (rho*c*UU_isolated_SI))/2;
PP_backward = ((PP_isolated_SI - PP_isolated_SI(1)) - (rho*c*UU_isolated_SI))/2;

%decomposing speed
UU_forward = PP_forward / (rho*c);
UU_backward = PP_backward / (rho*c);

%decomposing wave intensity
dPP_forward = (PP_forward(2:end)-PP_forward(1:end-1))/dt;
dPP_backward = (PP_backward(2:end)-PP_backward(1:end-1))/dt;

dUU_forward = (UU_forward(2:end)-UU_forward(1:end-1))/dt;
dUU_backward = (UU_backward(2:end)-UU_backward(1:end-1))/dt;

WI_forward = (dPP_forward.*dUU_forward);
WI_forward_filter = sgolayfilt(WI_forward,3,51);

WI_backward = -(dPP_backward.*dUU_backward);
WI_backward_filter = sgolayfilt(WI_backward,3,51);

%%%PLOTS NET WAVE INTENSITY AND DECOMPOSED PLOTS UNDERNEATH EACHOTHER
% figure
% topfig = subplot(2,1,1)
% plot(topfig,WI_isolated_time,(WI_isolated),'k')
% line(xlim(),[0,0], 'LineWidth', 0.25, 'Color','r');
% xlabel('Time(ms)');
% ylabel('Wave Intensity (Pa*m*s^{-3})');
% title('Net Wave Intensity')
% 
% bottomfig = subplot(2,1,2)
% plot(bottomfig,WI_isolated_time(1:end-1),WI_forward_filter);
% hold
% plot(WI_isolated_time(1:end-1),WI_backward_filter,'k');
% title('Seperated Wave Intensities. Blue = forward, Black = backward')
% xlabel('Time(ms)');
% ylabel('Wave Intensity (Pa*m*s^{-3})');


figure
plot(WI_isolated_time,(WI_isolated),'k')
hold
plot(WI_isolated_time(1:end-1),WI_forward_filter,'Color',[0.35 0.35 1])
plot(WI_isolated_time(1:end-1),WI_backward_filter,'Color',[1 0.35 0.35]);
line(xlim(),[0,0], 'LineWidth', 0.1, 'Color',[0.7 0.7 0.7]);
xlabel('Time(ms)');
ylabel('Wave Intensity (Pa*m*s^{-3})');
xlim([0 1])
ylim([-350000 1500000])
fig_title = 'Wave Intensity ' + experiment
title(fig_title)
legend('Net Wave Intensity','Forward WI','Backward WI')




end

