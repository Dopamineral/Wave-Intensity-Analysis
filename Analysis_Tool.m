%SELECT RELEVANT AREA IN FLOW CHART BEFORE BEGINNING
%EXPORT PHASE CONTRAST TO GRAPH_DATA BEFORE BEGINNING

%specify output parameters
sample_number = '3';

patient_ID = "CTEPH_42";
mode = "viagra"; % base/viagra;
experiment = "flow66"; %flow00 (=rest), flow25, flow66

data = RightHemo_importADI;

P = data.data*133.322368; %Pa
P = sgolayfilt(P,3,301); %filering P signal (comment out if necesssary)
Pt = data.time; %s
Pt = Pt - Pt(1);


global GRAPH_DATA;

U = GRAPH_DATA.trace/100; %m/s
U = sgolayfilt(U,3,31); %filtering U signal (comment out if necessary)
Ut = GRAPH_DATA.time/1000; %s
U = U';
Ut = Ut';
Ut = Ut-U(1);

% %Clipping pressure data so equal amount of heartbeats as speed data
[~,Pt_start] = min(abs(Pt - Ut(1)));
[~,Pt_end] = min(abs(Pt - Ut(end)));

%dUt = round(Ut(end)-Ut(1))+1;

PPt = Pt(Pt_start:Pt_end);
PP = P(Pt_start:Pt_end);

%Upsampling speed data so as many points as pressure data
UU = interp1(Ut,U,PPt);
UU = UU';

%bugfix, sometimes lengts don't match up for some reason
if length(UU) < length(PP)
    PP = PP(1:length(UU));
    PPt = PPt(1:length(UU));
end
    
%Visualizing output
figure;
fig1 = subplot(2,1,1);
plot(fig1,PPt,PP);
title('Pressure');

fig2 = subplot(2,1,2);
plot(fig2,PPt,UU);
title('Speed');

%Alligning the graphs (click interface)
%first click pressure point
[xp,yp] = ginput(1);
%upstream click speed point
[xu,yu] = ginput(1);

deltax = (xu - xp);
roundx = round(deltax*1000);
UUt = PPt + deltax;

if roundx >= 0
    shiftmatrix = nan(1,roundx)';
    UUN = [UU,shiftmatrix'];
    UU = UUN(roundx+1:end)';
 else
    shiftmatrix = nan(1,-roundx)';
    UUN = [shiftmatrix',UU];
    UU = UUN(1:end+roundx)';
 end

figure;
fig1 = subplot(2,1,1);
title(fig1,'Pressure');
plot(PPt,PP);
set(gca,'xlim',[0,PPt(end)]);

fig2 = subplot(2,1,2);
title(fig2,'Speed');
plot(PPt,UU);
set(gca,'xlim',[0,PPt(end)]);

WI = wave_intensity(PP,PPt,UU,PPt);
WI = sgolayfilt(WI,3,51); %filering WI signal
WI(end+1) = NaN;

%Prompt user to select further data output

answer_WI = questdlg('Select output mode','Data output','Select Custom','No Output','OK'); %"All data" var can be added to save certain vars in csv format

switch answer_WI
    case 'Select Custom'
        % Select region of interest for Wave intensity export
        [x1_s,y1] = ginput(1);
        [~,x1] = min(abs(PPt - x1_s));
        
        [x2_s,y2] = ginput(1);
        [~,x2] = min(abs(PPt - x2_s));
        
        UU_isolated = UU(x1:x2);
        PP_isolated = PP(x1:x2);
        WI_isolated = WI(x1:x2);
        WI_isolated_time = PPt(x1:x2);
        WI_isolated_time = WI_isolated_time - WI_isolated_time(1);
        
        %Save raw data to mat file
        %WI_output = ['P', 'U', 'Pt', 'Ut', 'PP', 'UU', 'PPt', 'UUt', 'WI_isolated_time', 'PP_isolated', 'UU_isolated', 'WI_isolated'];
        
        filename = patient_ID +"_"+ "WI_single_" + mode + "_" + experiment + "_sample" +sample_number + ".mat";
        save(filename,'patient_ID','mode','experiment','P', 'U', 'Pt', 'Ut', 'PP', 'UU', 'PPt', 'UUt', 'WI_isolated_time', 'PP_isolated', 'UU_isolated', 'WI_isolated');
        
        %visualize data and save figure as filename.fig
        filename_fig =patient_ID +"_" + "_WI_single_"+ mode + "_" + experiment + "_sample" +sample_number + ".fig";
        
        figure
        plot(WI_isolated_time,WI_isolated,'k');
        line(xlim(),[0,0], 'LineWidth', 0.25, 'Color','r');
        xlabel('Time(ms)');
        ylabel('Wave Intensity (Pa*m*s^{-3})');
        title("Wave Intensity");
        saveas(gcf,filename_fig)
        
                
    case 'All Data'
        WI_output =[PPt PP UU WI];
        filename = patient_ID + "WI_multi_"+ "_" + mode + "_" + experiment + "_sample" +sample_number + ".csv";
        csvwrite(filename,WI_output);
        
    case 'No Output'
        % Select region of interest for Wave intensity export
        [x1,y1] = ginput(1);
        [x2,y2] = ginput(1);

        UU_isolated = UU(x1:x2);
        PP_isolated = PP(x1:x2);
        WI_isolated = WI(x1:x2);
        WI_isolated_time = PPt(x1:x2);
        WI_isolated_time = WI_isolated_time - WI_isolated_time(1);

        figure
        plot(WI_isolated_time,WI_isolated,'k');
        line(xlim(),[0,0], 'LineWidth', 0.25, 'Color','r');
        xlabel('Time(ms)');
        ylabel('Wave Intensity (Pa*m*s^{-3})');
        title("Wave Intensity");
        
end

speed_output = PhasePlotAnalysis(PP_isolated,UU_isolated);
%save phaseplot
phaseplot_filename_fig = patient_ID + "_WI_phaseplot_"+ mode + "_" + experiment + "_sample" +sample_number + ".fig";
saveas(gcf,phaseplot_filename_fig)

WaveDecomposition(PP_isolated,UU_isolated,speed_output,WI_isolated_time,WI_isolated,experiment)

%Data output from final wave intensity graphs
answer_dataOutput = questdlg('Do you want to output data via ginput? Select all peaks (also net WI backcurrent peak) from left to right, top to botom','Output ginput data to csv','Yes','No','OK')

switch answer_dataOutput 
    case 'Yes'
        
        %save current image
        data_filename_fig = patient_ID + "_WI_decomposed_"+ mode + "_" + experiment + "_sample" +sample_number + ".fig";
        saveas(gcf,data_filename_fig)
        
        %save peak data to csv file using fprintf (click from top left to right botom,
        %first net wave intensity peak, then
        [WI_peak1_time,WI_peak1] = ginput(1)
        [WI_backcurrent_time,WI_backcurrent] = ginput(1)
        [WI_peak2_time,WI_peak2] = ginput(1)
        [forward_peak1_time,forward_peak1] = ginput(1)
        [forward_peak2_time,forward_peak2] = ginput(1)
        [backward_peak1_time,backward_peak1] = ginput(1)
        [backward_peak2_time,backward_peak2] = ginput(1)
        
        data_filename = patient_ID + '_DATA_WI' +  '_' + mode + '_' + experiment + '_sample_' + sample_number + '.csv'
        %data_output = [patient_ID WI_Peak1 WI_backcurrent WI_Peak2 Forward_peak1 Forward_peak2 Backward_peak1 Backward_peak2]
        fid = fopen(data_filename,'w');
        fprintf(fid,'%s,%s,%s,%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n',patient_ID,sample_number, mode,experiment,WI_peak1_time,WI_peak1,WI_backcurrent_time,WI_backcurrent,WI_peak2_time,WI_peak2,forward_peak1_time,forward_peak1,forward_peak2_time,forward_peak2,backward_peak1_time,backward_peak1,backward_peak2_time,backward_peak2);
        fclose(fid);
        %csvwrite(data_filename,data_output)
        
        fclose('all')
       
    case 'No'
end

