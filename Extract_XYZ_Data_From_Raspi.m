mypi = raspi('192.168.0.10','pi','cardyna!')
tic
getFile(mypi,'/home/pi/Documents/data_XYZ.txt')
toc
Data_XYZ=readtable('data_XYZ.txt','HeaderLines',1);
save('Data_XYZ.mat','Data_XYZ');

figure 
hold on
plot(Data_XYZ.Var1,Data_XYZ.Var2)
plot(Data_XYZ.Var1,Data_XYZ.Var3)
%plot(Data_XYZ.Var1,Data_XYZ.Var4)