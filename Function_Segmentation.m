
function Data=Function_Segmentation(Data,Min,Max,Percentage_Of_Changes,Threshold, MinDistNoMouv)

% This function aims to partition Data.SumImage into Event (movement and no
% movement). findchangepts detect abrupt changes and is used twice to
% generate the location of movement event (store in locs). then, the
% position between locs (i.e lying position) are included as event "lying
% position" (i.e without movement). A last step is usefull to remove lying
% event that are too small and should be pooled with a movement event.
% The function takes as argument Data and min and max for ROI if needed.
% Then arguments are passed that will change the number and the length of
% the event. Percentage of changes: should be closed to 1%; Treshold: could
% be adapted but 1000 looks nice. MinDistMouv: should be closed to 20. This
% function also output Data with a new boolean field "theoritcal_mov" that
% indicates if THIS Data point belong or not to a mov.


%% first detection of changes (ipt)
MaxChanges=round(Percentage_Of_Changes*length(Data.SumImage(Min:Max))/100);
ipt=findchangepts(Data.SumImage(Min:Max),'MaxNumChanges',MaxChanges,'MinDistance',1);

% figure;
% hold on
% plot(Data.SumImage(Min:Max),'-b')
% for i=1:length(ipt)
%     plot(ipt(i),Data.SumImage(ipt(i)),'+r')
% end

%% first detection of changes (ipt2 on ipt)

ipt2=findchangepts(ipt,'Statistic','linear','MinThreshold',Threshold,'MinDistance',2);

% figure
% hold on
% plot(ipt,'-+b')
% for i=1:length(ipt2)
%     plot(ipt2(i),ipt(ipt2(i)),'+r')
% end

%% extract location of movements and shows the result

for i=1:length(ipt2)+1
    if i==1
        Mov=ipt(1:ipt2(i)-1);
    elseif i==length(ipt2)+1
        Mov=ipt(ipt2(i-1):end);
    else
        Mov=ipt(ipt2(i-1):ipt2(i)-1);
    end
    locs(i,1)=(Min-1)+Mov(1);
    locs(i,2)=(Min-1)+Mov(end);
end

% figure;
% hold on;
% plot(Data.DateTime(Min:Max),Data.SumImage(Min:Max),'-b');
%
% for i=1:length(locs)
%     plot(Data.DateTime(locs(i,1):locs(i,2)),Data.SumImage(locs(i,1):locs(i,2)),'-+r');
% end

%% include event in lying position (i.e when i don't move)

for i=1:2*length(locs)+1
    if i==1
        SegmentAllData(i,1)=1;
        SegmentAllData(i,2)=locs(i,1)-2;
    elseif mod(i,2)==0
        SegmentAllData(i,1)=locs(i/2,1)-1;
        SegmentAllData(i,2)=locs(i/2,2)+1;
    elseif mod(i,2)==1 && i~=1 && i~=2*length(locs)+1
        SegmentAllData(i,1)=locs(floor(i/2),2)+2;
        SegmentAllData(i,2)=locs(ceil(i/2),1)-2;
    elseif i==2*length(locs)+1
        SegmentAllData(i,1)=locs(floor(i/2),2)+2;
        SegmentAllData(i,2)=length(Data.DateTime);
    end
end

%% remove event in lying position that are two small

% detect event wihtout movement with too small number of data
CorrectedSegmentData=SegmentAllData;
Compteur=0;
for i=1:length(SegmentAllData)
    
    if mod(i,2)==1
        if SegmentAllData(i,2)-SegmentAllData(i,1)<MinDistNoMouv && i~=1 % i~=1: don't touch to the first segment "no movement".
            CorrectedSegmentData(i-1,2)=CorrectedSegmentData(i+1,2);
            Compteur=Compteur+1;
            Line_to_Delete(Compteur)=i;
        end
    end
end

% detect event without movement thar are contigu to delete the event
% betwenn them
for i=1:length(Line_to_Delete)-1
    if Line_to_Delete(i+1) - Line_to_Delete(i)==2
        Line_to_Delete=vectorInsertAfter(Line_to_Delete,i,Line_to_Delete(i)+1); % function of Walter Robinson to include in the workspace
    end
end

% delete the line that should be delete (count begin from the end to
% preserve i)
for i=length(Line_to_Delete):-1:1
    CorrectedSegmentData(Line_to_Delete(i)+1,:)=[];
    CorrectedSegmentData(Line_to_Delete(i),:)=[];
end
% correction of indices number 2 for double contiguous event
for i=1:length(CorrectedSegmentData)-1
    if CorrectedSegmentData(i,2)+1~=CorrectedSegmentData(i+1,1)
        CorrectedSegmentData(i,2)=CorrectedSegmentData(i+1,1)-1;
    end
end

Number_Of_Events=length(CorrectedSegmentData); % output information

%% show the difference before and after correction

% figure
% hold on
% yyaxis left
% for i=1:length(SegmentAllData)
%     if mod(i,2)==1
%         plot(Data.DateTime(SegmentAllData(i,1):SegmentAllData(i,2)),Data.SumImage(SegmentAllData(i,1):SegmentAllData(i,2)),'-+b');
%     else
%         plot(Data.DateTime(SegmentAllData(i,1):SegmentAllData(i,2)),Data.SumImage(SegmentAllData(i,1):SegmentAllData(i,2)),'-+r');
%     end
% end
% 
% yyaxis right
% for i=1:length(CorrectedSegmentData)
%     if mod(i,2)==1
%         plot(Data.DateTime(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2)),Data.SumImage(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2)),'-+b');
%     else
%         plot(Data.DateTime(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2)),Data.SumImage(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2)),'-+g');
%     end
% end

%% write important output to Data in Data.ML (Machine Learning)

Data.ML.Segmentation=CorrectedSegmentData;
Data.ML.Number_Of_Segments=Number_Of_Events;

% write the theoritical boolean vector for each Data point in data
% "true" movement or "false"

Data.ML.Theoritical_Mov=zeros(1,Max);% ATTENTION maybe Max-Min+1 if problem
for i=1:length(CorrectedSegmentData)
    if mod(i,2)==1
        Data.ML.Theoritical_Mov(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2))=false;
    else
        Data.ML.Theoritical_Mov(CorrectedSegmentData(i,1):CorrectedSegmentData(i,2))=true;
    end
end

end