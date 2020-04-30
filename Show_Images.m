%close all;
figure;
set(gcf,'colormap',gray); %uncomment if want grayscale

%% parameters
Folder='D:\MATLAB\Data_Sleep\Sleep_30_Apr_2020_00_01_20_Cam_Acc_50_OK\'; % add Images in the future
DataFile=[Folder 'Data.mat']
load(DataFile);

Time=Data.iteration;
Pas=16;

%% loop
for i=1:Pas:Time
   % Name=[Folder 'image_' num2str(i) '.jpeg'];
    Name=[Folder 'Images\image_' num2str(i) '.jpeg'];
    try
    img=imread(Name);
    image(img);
    Fileinfo=dir(Name);
    TimeStamp=text(10,15,Fileinfo.date,'Color','red','FontSize',12);
   % TimeStamp2=text(10,20,num2str(Data.Time(i)));
    drawnow
    catch
        disp('Warning: image does not exist; probable error cam')
    end
end