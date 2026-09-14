function new_solution = LS3(solution)
    % LS3：随机选择30%的工序，提速一档（1→2, 2→3）
    global H;
    OS = solution.OS;
    MS = solution.MS;
    SS = solution.SS;
    
    SH = length(OS);
    % 随机选择30%的工序，确保至少选择1个
    num_selected = max(1, round(SH * 0.3));
    selected_indices = randperm(SH, num_selected);
    
    for i = 1:length(selected_indices)
        idx = selected_indices(i);  % 在OS中的位置
        job = OS(idx);
        oper = sum(OS(1:idx) == job);
        pos = sum(H(1:job-1)) + oper;  % 在SS中的位置        
        % 提速一档：1→2, 2→3
        if SS(pos) == 1
            SS(pos) = 2;  % 速度1变为速度2
        elseif SS(pos) == 2
            SS(pos) = 3;  % 速度2变为速度3
        end
        % 速度3保持不变
    end    
    new_solution.OS = OS;
    new_solution.MS = MS;
    new_solution.SS = SS;
    new_solution.obj = FJSP_Fitness(OS, MS, SS);
end
