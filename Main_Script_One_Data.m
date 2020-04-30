%% Preparation

clearvars -except Data mypi FDS
close all

%% parameters
%FDS = fileDatastore( fullfile('D:\','MATLAB','Data_Sleep'),'ReadFcn',@load,'FileExtensions','.mat','IncludeSubfolders',true);

FDS.Files

load(FDS.Files{14});

%% small correction of outlier that appears in the 3 first points.
% take the mean of 25 points of the beginning and replace the 3 first point
% with this mean.
Data.SumImage(1:3)=mean(Data.SumImage(5:30));

%% Main parameters
Min=1;
Max=length(Data.DateTime);
Percentage_Of_Changes=1; % 1% for instance
Threshold=1000;
MinDistNoMouv=20;% the distance between no mouvement event can't be inferior to 15 seconds(30/2)

%% launch the main function
Data=Function_Segmentation(Data,Min,Max,Percentage_Of_Changes,Threshold, MinDistNoMouv);

%% result
Data.ML

figure
hold on
for i=1:Data.ML.Number_Of_Segments
    if mod(i,2)==1
        plot(Data.DateTime(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),Data.SumImage(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),'-+b');
    else
        plot(Data.DateTime(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),Data.SumImage(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),'-+g');
    end
end
