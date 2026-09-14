clc
clear
close all
dbstop if error
clear global all
global M N H Time Setup_Time
%%% M-机器数目  N-工件数目
%%% H-每个工作对应的操作数，数据结构为 H=[1 2 ... N]
%%% Time- 存储对应的加工时间 如 Time{i}(j,k)就是指的是操作$O_{i,j}$在机器k上的加工时间
Popsize=120;
pc=0.7;
pm=0.1;
Runs=10;
Problem=28;
Data_Path=Get_Data_Path();
currentPath = pwd; % 获取当前路径
[pathstr,~,~] = fileparts(currentPath); % 获取当前路径的上一级路径
for prob=1:Problem
    [Time,N,M,H]=Read_FJSPwithSpeed_Data(Data_Path{prob});
    load([pathstr,'\DataSet\Setup_Time_Problem_',num2str(prob),'.mat'], 'Setup_Time');
    
    MaxFES=sum(H)*200;
    for run=1:30
        [prob run]
        T=25;
        [Elite,times]=MOEAD(Popsize,MaxFES,pc,pm,T);
        write_name=[pathstr,'\results\INITIAL_Problem_',num2str(prob),'_run_',num2str(run),'.mat'];
        save(write_name,'Elite','times');
    end
end








function Data_Path=Get_Data_Path()
k=0;
currentPath = pwd; % 获取当前路径
[pathstr,~,~] = fileparts(currentPath); % 获取当前路径的上一级路径
for prob=1:28
    k=k+1;
    Data_Path{k,1}=[pathstr,'\DataSet\Problem_',num2str(prob),'.txt'];
end % end prob
end