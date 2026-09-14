function [OS, MS, SS] = initial(oper_mac)
    global N H Time NM M;    
    SH = sum(H);  % 总操作数    
    %%% OS  
    OS = MOR();
    %%% MS
    MS_strategy = rand();  
    if MS_strategy <= 0.3      
        MS = shortest_processing_time(oper_mac); % 最短加工时间（30%）
    elseif MS_strategy <= 0.6       
        MS = load_balancing(OS,oper_mac);% 负载均匀（30%）
    elseif MS_strategy <= 0.9       
        MS = earliest_completion_time(OS,oper_mac);% 最早完工时间（30%）
    else
        MS = random_ms(oper_mac);
    end
    %%% SS
    SS=ceil(rand(1,SH)*3);
end



%%% OS
function OS = MOR()
    % 策略：优先排剩余工序最多的工件
    global N H;    
    SH = sum(H);
    OS = zeros(1, SH);
    remaining_ops = H;  % 每个工件剩余的操作数
    position = 1;    
    while position <= SH
        max_remaining = max(remaining_ops);  %找到剩余工序最多的工件
        candidates = find(remaining_ops == max_remaining);             
        if length(candidates) > 1  % 如果多个工件剩余操作数相同，随机选一个
            selected_job = candidates(randi(length(candidates)));
        else
            selected_job = candidates;
        end        
        OS(position) = selected_job;       
        remaining_ops(selected_job) = remaining_ops(selected_job) - 1;
        position = position + 1;
    end
end
%%% MS - 最短加工时间策略
function MS = shortest_processing_time(oper_mac)
    global N H Time NM;
    SH = sum(H);
    MS = zeros(1, SH);    
    for job = 1:N
        for oper = 1:H(job)
            pos = sum(H(1:job-1)) + oper;
            mac_options = NM{pos};
            num_options = oper_mac(pos);
            processing_times = zeros(1, num_options);
            for m_idx = 1:num_options
                machine = mac_options(m_idx);
                processing_times(m_idx) = Time{job}(oper, machine);
            end            
            % 选择最短加工时间的机器
            [~, min_idx] = min(processing_times);
            MS(pos) = mac_options(min_idx);
        end
    end
end
%%% MS - 负载均匀策略
function MS = load_balancing(OS, oper_mac)
    global N H Time NM M Setup_Time;
    SH = length(OS);
    MS = zeros(1, SH);   
    machine_load = zeros(1, M);  % 机器累计负载
    Job_on_Mac = zeros(1, M);    
    oper_count = zeros(1, N);    
    % 按照OS码的顺序处理工序
    for k = 1:SH
        job = OS(k);
        oper_count(job) = oper_count(job) + 1;
        oper = oper_count(job);       
        pos = sum(H(1:job-1)) + oper;
        mac_options = NM{pos};
        num_options = oper_mac(pos);        
        % 计算预估负载（考虑加工时间+设置时间）
        mac_loads = zeros(1, num_options);
        for m_idx = 1:num_options
            mac = mac_options(m_idx);
            processing_time = Time{job}(oper, mac);            
            % 计算设置时间
            if Job_on_Mac(mac) ~= job 
                set_time = Setup_Time(job);  
            else
                set_time = 0; 
            end                      
            mac_loads(m_idx) = machine_load(mac) + processing_time + set_time;
        end        
        % 选择负载最小的机器
        [~, min_idx] = min(mac_loads);
        selected_mac = mac_options(min_idx);
        MS(pos) = selected_mac;       
        if Job_on_Mac(selected_mac) ~= job 
            actual_set_time = Setup_Time(job);
        else
            actual_set_time = 0;
        end
        processing_time = Time{job}(oper, selected_mac);
        machine_load(selected_mac) = machine_load(selected_mac) + processing_time + actual_set_time;
        Job_on_Mac(selected_mac) = job;
    end
end
%%% MS - 最早完工时间策略
function MS = earliest_completion_time(OS, oper_mac)
    global N H Time NM M Setup_Time;
    SH = length(OS);
    MS = zeros(1, SH);
    machine_available = zeros(1, M);
    job_available = zeros(1, N);
    Job_on_Mac = zeros(1, M);
    oper_count = zeros(1, N);    
    % 按照OS码的顺序处理工序
    for k = 1:SH
        job = OS(k);
        oper_count(job) = oper_count(job) + 1;
        oper = oper_count(job);        
        pos = sum(H(1:job-1)) + oper;
        machine_options = NM{pos};
        num_options = oper_mac(pos);        
        % 计算完成时间
        completion_times = zeros(1, num_options);
        for m_idx = 1:num_options
            machine = machine_options(m_idx);
            processing_time = Time{job}(oper, machine);           
            % 计算设置时间
            if Job_on_Mac(machine) ~= job
                set_t = Setup_Time(job);
            else
                set_t = 0;
            end           
            start_time = max(machine_available(machine) + set_t, job_available(job));
            completion_times(m_idx) = start_time + processing_time;
        end        
        % 选择最早完工的机器
        [~, min_idx] = min(completion_times);
        selected_machine = machine_options(min_idx);
        MS(pos) = selected_machine;        
        % 重新计算设置时间
        if Job_on_Mac(selected_machine) ~= job 
            set_t = Setup_Time(job);
        else
            set_t = 0;
        end       
        % 更新时间
        processing_time = Time{job}(oper, selected_machine);
        start_time = max(machine_available(selected_machine) + set_t, job_available(job));
        finish_time = start_time + processing_time;
        machine_available(selected_machine) = finish_time;
        job_available(job) = finish_time;
        Job_on_Mac(selected_machine) = job;
    end
end
%%% MS - 随机分配策略
function MS = random_ms(oper_mac)
    global N H NM;
    SH = sum(H);
    MS = zeros(1, SH);   
    for k = 1:SH
        % 从可选机器中随机选择一台
        machine_options = NM{k};
        num_options = oper_mac(k);
        random_idx = ceil(rand() * num_options);
        MS(k) = machine_options(random_idx);
    end
end