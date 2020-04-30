
%% Preparation

clearvars -except mypi FDS;
close all;

FDS = fileDatastore( fullfile('D:\','MATLAB','Data_Sleep'),'ReadFcn',@load,'FileExtensions','.mat','IncludeSubfolders',true);

tic

Iteration_Event=1;

for iterationFDS=1:length(FDS.Files)
    if strcmp(FDS.Files{iterationFDS}(end-7:end),'Data.mat')==1 % only load Data.mat (not ccopy or Data_XYZ)
        
        FDS.Files{iterationFDS}
        load(FDS.Files{iterationFDS});        
        
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
        
        %% call to the segmentation function
        Data=Function_Segmentation(Data,Min,Max,Percentage_Of_Changes,Threshold, MinDistNoMouv);
        
        %show the result and save it 
        Data.ML
        save(FDS.Files{iterationFDS},'Data')
        
        %% Show the figure and save it
        
        figure
        hold on
        for i=1:length(Data.ML.Segmentation)
            if mod(i,2)==1
                plot(Data.DateTime(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),Data.SumImage(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),'-+b');
            else
                plot(Data.DateTime(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),Data.SumImage(Data.ML.Segmentation(i,1):Data.ML.Segmentation(i,2)),'-+g');
            end
        end

        Date=datestr(Data.DateTime(1));
        Date = strrep(Date,'-','_');Date = strrep(Date,' ','_');Date = strrep(Date,':','_');
        Name=['C:\Users\Guillaume\Documents\MATLAB\Machine_Learning_For_Sleep\Nouveau_Tri_2020_03_06\Save_ML_Result\' Date '.fig'];
        saveas(gcf,Name);
%        pause(1);
        close all;
        %% Create the Event structure
        
                for i=1:length(Data.ML.Segmentation)
                    
                    Event(Iteration_Event).Begin=Data.ML.Segmentation(i,1);
                    Event(Iteration_Event).End=Data.ML.Segmentation(i,2);
                    Event(Iteration_Event).Data=Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End);
                    Event(Iteration_Event).DateTime=Data.DateTime(Event(Iteration_Event).Begin:Event(Iteration_Event).End);
                    Event(Iteration_Event).DateTimeBegin=Data.DateTime(Event(Iteration_Event).Begin);
                    Event(Iteration_Event).Length=length(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Mean=mean(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Median=median(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Std=std(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Min=min(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Max=max(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End));
                    Event(Iteration_Event).Integrale=trapz(Data.SumImage(Event(Iteration_Event).Begin:Event(Iteration_Event).End))/Event(Iteration_Event).Length;
                    Event(Iteration_Event).Theoritical_Mov=Data.ML.Theoritical_Mov(Event(Iteration_Event).Begin);% use the first point
                    Event(Iteration_Event).Parent=FDS.Files{iterationFDS};
                    Iteration_Event=Iteration_Event+1;
                end  
    end
end

%% Save the structure Event and create the corresponding table and save it too.
length(Event)
save('C:\Users\Guillaume\Documents\MATLAB\Machine_Learning_For_Sleep\Nouveau_Tri_2020_03_06\Save_ML_Result\Event.mat','Event');
disp('Structure Event Saved');

Table_Feature = struct2table(Event);

save('C:\Users\Guillaume\Documents\MATLAB\Machine_Learning_For_Sleep\Nouveau_Tri_2020_03_06\Save_ML_Result\Table_Feature.mat','Table_Feature')
disp('Table_Feature Saved');
toc

