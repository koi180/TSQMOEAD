function new_solution = LS4(solution)
    % LS4：随机选择10%的工序进行降速
    % 速度3→2，速度2→1，速度1不变
    global H;    
    OS = solution.OS;
    MS = solution.MS;
    SS = solution.SS;
    SH = length(OS);  % 总操作数   

    num_to_slow = round(SH * 0.1);    
    % 确保至少选择1个工序，不超过总工序数
    if num_to_slow < 1
        num_to_slow = 1;
    elseif num_to_slow > SH
        num_to_slow = SH;
    end
    
    % 随机选择工序
    selected_indices = randperm(SH, num_to_slow);
    
    % 对选中的工序进行降速
    for i = 1:length(selected_indices)
        idx = selected_indices(i);  % 在OS中的位置
        job = OS(idx);
        oper = sum(OS(1:idx) == job);
        pos = sum(H(1:job-1)) + oper;  % 在SS中的位置
               
        if SS(pos) == 3
            SS(pos) = 2;  
        elseif SS(pos) == 2
            SS(pos) = 1; 
        end       
    end
    
    new_solution.OS = OS;
    new_solution.MS = MS;
    new_solution.SS = SS;
    new_solution.obj = FJSP_Fitness(OS, MS, SS);
end

