function new_solution = LS2(solution)
    % LS2：从负载最大的机器上抽走一个随机工序，换到另一台机器上
    global H NM Time M Setup_Time;    
    new_solution = solution;
    OS = new_solution.OS;
    MS = new_solution.MS;
    SS = new_solution.SS;
    time_efficiency = [3 2 1];
    SH = length(OS);   
    machine_load = zeros(1, M);
    Job_on_Mac = zeros(1, M);  % 记录每台机器上最后一个加工的工件
    Mac_Schedule = cell(1, M);  % 记录每台机器上的工序顺序   
    for k = 1:SH
        job = OS(k);
        oper = sum(OS(1:k) == job);
        pos = sum(H(1:job-1)) + oper;
        mac = MS(pos);
        speed = SS(pos);        
        original_time = Time{job}(oper, mac);
        actual_time = original_time * time_efficiency(speed);
        if  Job_on_Mac(mac)~=job
            set_t = Setup_Time(job);
        else
            set_t = 0;
        end
        machine_load(mac) = machine_load(mac) + actual_time + set_t; %计算累计负载
        Mac_Schedule{mac} = [Mac_Schedule{mac}, struct('pos', pos, 'job', job, 'oper', oper)];
        Job_on_Mac(mac) = job;           % 更新该机器最后加工的工件
    end
    [~, busiest_mac] = max(machine_load);
    % 获取负载最大机器上的所有工序
    oper_on_busy_mac = Mac_Schedule{busiest_mac};    
%     % 如果该机器没有工序，直接返回
%     if isempty(oper_on_busy_mac)
%         new_solution.obj = FJSP_Fitness(OS, MS, SS);
%         return;
%     end   
    % 随机选择该机器上的一个工序
    selected_idx = randi(length(oper_on_busy_mac));
    selected_oper = oper_on_busy_mac(selected_idx);
    selected_pos = selected_oper.pos;
    job = selected_oper.job;
    oper = selected_oper.oper;
    current_mac = busiest_mac;
    available_mac = find(Time{job}(oper,:) ~= 0); %该工序的可用机器      
    if length(available_mac) > 1     
        % 随机选择一个不同于当前机器的目标机器
        other_mac = available_mac(available_mac ~= current_mac);
        if ~isempty(other_mac)
            best_machine = other_mac(randi(length(other_mac)));
            MS(selected_pos) = best_machine;
            new_solution.MS = MS;
            new_solution.obj = FJSP_Fitness(OS, MS, SS);
        end
    end
end
