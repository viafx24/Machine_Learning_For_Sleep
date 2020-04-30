%system(mypi,'nohup python ./Get_Sensor_Data.sh > /dev/null 2>&1 &','sudo')
clearvars -except Cam mypi;
%mypi = raspi('192.168.0.10','pi','cardyna!')
system(mypi,'python /home/pi/Documents/Get_XYZ_Data_April_2020.py > /dev/null 2>&1 &','sudo')
%system(mypi,'ls','sudo')
%system(mypi,'python ./Get_XYZ_Data_April_2020.py','sudo')
%system(mypi,'pkill python','sudo')
%/home/pi/Documents