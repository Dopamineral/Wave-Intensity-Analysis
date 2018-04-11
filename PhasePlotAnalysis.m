function [c] = PhasePlotAnalysis(PP_isolated,UU_isolated)
%Continues phase plot analysis after net WI has been done. The range of one
%peak WI produces isolated PP and UU values, PP_isolated and UU isolated
%respectively which are the inputs for this function to work on. The are
%converted to m/s and kPa 

answer_c = questdlg('Continue with phase plot?','Continue with phase plot','Continue','Do nothing','OK')

switch answer_c
    case 'Continue'
        
        UU_phaseplot = UU_isolated 
        PP_phaseplot = PP_isolated 
        
        figure
        plot(UU_phaseplot,PP_phaseplot);
        hold
        plot(UU_phaseplot(1),PP_phaseplot(1),'ro')
        xlabel('Velocity (m/s)');
        ylabel('Pressure (kPa)');
        title("Phase plot");
        
        
        answer_calc = questdlg('Does it look ok? Select left to right','Select slope to calculate c','Yes','No','OK')
        
        switch answer_calc 
            case 'Yes'
                [x_phase1, y_phase1] = ginput(1);
                [x_phase2, y_phase2] = ginput(1);
                
                slope_phase = (y_phase2 - y_phase1)/(x_phase2 - x_phase1);
                
                rho = 1050; 
                
                c = slope_phase * (1/rho);
                                
            case 'No'   
        end
                
    case 'Do nothing'
        
end

end

