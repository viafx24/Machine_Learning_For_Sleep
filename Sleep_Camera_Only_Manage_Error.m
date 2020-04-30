
%% some cleaning
close all;

clearvars -except Cam mypi;

%% parameters to calibrate before acquisition

Wanted_Pause=0.5;
Wanted_Image_Frequence=1;

% for testing purpose
% Hours=1;
% Minutes=1;
% Secondes=60;

Hours=12;
Minutes=60;
Secondes=60;

Time=Secondes/Wanted_Pause*Minutes*Hours;
Plot_Limited_Number_Of_Iteration=Time;
Plot_Limited_Number_Of_Iteration=100;
% real acquisition

Date = datestr(now,'dd-mmm-yyyy HH:MM:SS');
Date = strrep(Date,'-','_');Date = strrep(Date,' ','_');Date = strrep(Date,':','_');
FolderData=['Sleep_' Date]; 
Parent='D:\MATLAB\Data_Sleep';
mkdir(Parent,FolderData);
FolderPath=[Parent '\' FolderData];% path where are saved data
FolderImage='Images';
mkdir(FolderPath,FolderImage);
FolderImagePath=[FolderPath '\' FolderImage];% path where are saved images
FileImage='\image_';

PooledName=[FolderImagePath FileImage];% name to save each image

FolderFile=[FolderPath '\' 'Data.mat'];
FolderFig=[FolderPath '\' 'Figure.fig'];
FolderPNG=[FolderPath '\' 'Figure.png'];

sprintf('Folder created: %s',FolderPath)
disp(Hours);
input('Sure about the time?');

[Data.SumImage, Data.Time] = deal(zeros(1,Time));

Data.TheoriticalTime=Time*Wanted_Pause;
Data.Error_Cam=0;
Data.Number_Error_Cam=0;
Data.iteration=0;

%% preparing the sensors

if isequal(exist('Cam','var'),0)% ouvre bluethoot si pas encore fait.
    Cam = ipcam('http://192.168.0.16:13901/videostream.cgi','via_fx_24','tDKDyFbppg55ZyNY');
end

disp('Connection succeed.');

%% figure

f=figure;
h1=plot(datetime,NaN,'-+b');
ylabel('Diff Image');

%% Main loop

Timer_1=tic;
for i=1:Time
    Timer_2=tic;
    
    %% take a snapshot with the camera
    
    if mod(i,Wanted_Image_Frequence)==1 || Wanted_Image_Frequence==1% get an image a multiple of i (ex 4*0.25=1sec)
        try
            
            img = rgb2gray(snapshot(Cam));
            Name=[PooledName num2str(i) '.jpeg'];
            imwrite(img,Name,'Quality',75);
            
            if i>1
                Data.SumImage(i)=sum(sum(img-previous_img));
            end
            
            previous_img=img;
            
        catch
            warning('snapshot failed %d',i);
            Data.Number_Error_Cam=Data.Number_Error_Cam+1;
            Data.Error_Cam(Data.Number_Error_Cam)=i;
            if Data.Number_Error_Cam>15 && Data.Error_Cam(end)-Data.Error_Cam(end-1)==1
                clear cam;
                disp('cam cleared');
                pause(60);
                try
                Cam = ipcam('http://192.168.0.16:13901/videostream.cgi','via_fx_24','tDKDyFbppg55ZyNY');
                catch
                    warning('launch camera failed');
                end
            end
        end
    end

    
    %% get the timestamp
    
    Data.DateTime(i)=datetime('now');
    Data.ElapsedTime=toc(Timer_1);
    Data.Time(i)=toc(Timer_1);
    
    %% plot first iteration
%    Timer_3=tic;
    if i<Plot_Limited_Number_Of_Iteration
        
        %h1.XData= Data.Time(1:i);
        h1.XData=Data.DateTime;
        h1.YData = Data.SumImage(1:i);
        
        drawnow;
    end
%    toc(Timer_3)
%% save Data struct at each iteration   
    Data.iteration=i;
    save(FolderFile,'Data');

%% maintain the time of each iteration constant
    Remain_Time=Wanted_Pause-toc(Timer_2);
    pause(Remain_Time);
    sprintf('Data saved; i=%d ; TicToc=%f ;Number_Error_Cam=%d, Elapsed Time=%f;'...
        ,i,toc(Timer_2),Data.Number_Error_Cam,Data.ElapsedTime)
end

saveas(gcf,FolderFig);
saveas(gcf,FolderPNG);
disp('Figure saved')
