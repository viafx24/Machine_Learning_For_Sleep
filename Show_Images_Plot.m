
%% parameters

%Folder='D:\MATLAB\Data_Sleep\Image_04_Mar_2020_03_25_50_OK\';
Folder='D:\MATLAB\Data_Sleep\Sleep_05_Mar_2020_03_37_24_OK\'; % add Images in the future
%Folder='D:\MATLAB\Data_Sleep\Sleep_06_Mar_2020_03_30_11_OK\'; % add Images in the future
DataFile=[Folder 'Data.mat']
load(DataFile);

Begin=1;
End=Data.iterationI;
Pas=64;
% 
% Begin=30000;
% End=35000;
% Pas=8;

%% select the mode

%Mode='Live';
Mode='All';

% live mode
Advance=1024;
Retard=1024;

%% figure
close all;
figure;
tiledlayout(4,2);
axImage=nexttile([4 1]);

set(gcf,'colormap',gray); %uncomment if want grayscale

ax1=nexttile;
h1=plot(datetime,NaN,'-b');
ylabel('Diff Image')
ylim([0 4*10^5])
ax2=nexttile;
yyaxis(ax2,'left');
h2=plot(ax2,datetime,NaN,'-r');
ylabel('X')
yyaxis(ax2,'right');
h3=plot(ax2,datetime,NaN,'-k');
ylabel('Y')
ax3=nexttile;
h4=plot(datetime,NaN,'-g');
ylabel('PIR')
ax4=nexttile;
h5=plot(datetime,NaN,'-c','linewidth',2);
ylabel('Heart Rate')
ylim([44 92])

%% loop
for i=Begin:Pas:End
    
    FirstImage=i+Data.Indices_Begin_HR-1;
    Name=[Folder 'Images\image_' num2str(FirstImage) '.jpeg'];
    img=imread(Name);
    image(axImage,img);
    Fileinfo=dir(Name);
    TimeStamp=text(axImage,10,15,Fileinfo.date,'Color','red','FontSize',12);
    % TimeStamp2=text(axImage,10,20,num2str(Data.Time(i)));
    TimeStamp3=text(axImage,10,40,num2str(i),'Color','red','FontSize',12);
    
    if strcmp(Mode,'All')
        h1.XData = Data.DateTimeI(Begin:i);
        h1.YData = Data.SumImageI(Begin:i);
        
        h2.XData=Data.DateTimeI(Begin:i);
        h2.YData = Data.XI(Begin:i);
        
        h3.XData=Data.DateTimeI(Begin:i);
        h3.YData = Data.YI(Begin:i);
        
        h4.XData=Data.DateTimeI(Begin:i);
        h4.YData = Data.PIRI(Begin:i);
        
        h5.XData= Data.DateTimeI(Begin:i);
        h5.YData = Data.HRI(Begin:i);
        
    elseif strcmp(Mode,'Live')
        
        if i>Retard
            
            h1.XData = Data.DateTimeI(i-Retard:i+Advance);
            h1.YData = Data.SumImageI(i-Retard:i+Advance);
            
            h2.XData=Data.DateTimeI(i-Retard:i+Advance);
            h2.YData = Data.XI(i-Retard:i+Advance);
            
            h3.XData=Data.DateTimeI(i-Retard:i+Advance);
            h3.YData = Data.YI(i-Retard:i+Advance);
            
            h4.XData=Data.DateTimeI(i-Retard:i+Advance);
            h4.YData = Data.PIRI(i-Retard:i+Advance);
            
            h5.XData= Data.DateTimeI(i-Retard:i+Advance);
            h5.YData = Data.HRI(i-Retard:i+Advance);
            
        end
    end
    
    drawnow;
end

