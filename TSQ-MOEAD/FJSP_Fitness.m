function [fitness,OS]=FJSP_Fitness(OS,MS,SS)
global N H M Time Setup_Time;

Job_on_Mac=zeros(1,M); %%机器上的工件
Speed_on_Mac=zeros(1,M); %% 机器上的速度
Mac_Time=zeros(1,M);  %%机器可用时间
Job_Time=zeros(1,N);  %%工件可用时间

%%% 磨损 加工-换速度
Wear=0;
wear_factor=[0.1 0.05 0.15];  %%%%akv
time_efficiency=[3,2,1];
eta=7.5;  %%主轴转换磨损因子（2.5*3）
SH=sum(H);
TEC=0;
set_p=1;  %%设置功率
idle_p=1; %%空闲功率
transfer_t=0.25; %%速度转换时间
for k=1:SH
    job=OS(k);
    oper=sum(OS(1:k)==job);
    pos=sum(H(1:job-1))+oper;
    mac=MS(pos);
    speed=SS(pos);
    Original_time=Time{job}(oper,mac); %%速度为1的时间
    actual_time = Original_time * time_efficiency(speed);
    if Job_on_Mac(mac)~=job % 设置时间,2~5的随机整数
        set_t=Setup_Time(job);
    else
        set_t=0;
    end
    TEC=TEC+set_t*set_p;  %%设置能耗

    if Speed_on_Mac(mac)~=speed && Speed_on_Mac(mac)~=0  %%
        Wear=Wear+(abs(Speed_on_Mac(mac)-speed))*eta; %%%%% 调速磨损       
        TEC = TEC + (speed^2 + Speed_on_Mac(mac)^2)/2 * transfer_t;%% 转换能耗
    end
    start_time=max(Mac_Time(mac)+set_t,Job_Time(job));
    idle_time=start_time-set_t-Mac_Time(mac);
    TEC=TEC+idle_time*idle_p; %%空闲能耗
    completion_time=start_time+actual_time;
    TEC=TEC+actual_time*speed^2;  %%加工能耗，也是总能耗
    Wear=Wear+actual_time*wear_factor(speed);  %%刀具磨损，也是总磨损
    Mac_Time(mac)=completion_time;
    Job_Time(job)=completion_time;
    Job_on_Mac(mac)=job;
    Speed_on_Mac(mac)=speed;
end
Cmax=max(Mac_Time);
fitness=[Cmax TEC Wear];
end % end function
