function new_solution = LS1(solution)
    % LS1：随机选择两个工序进行插入操作
    new_solution = solution;
    OS = new_solution.OS;
    MS = new_solution.MS;
    SS = new_solution.SS;
    
    SH = length(OS);
    if SH < 2
        new_solution.obj = solution.obj;
        return;
    end    
    % 随机选择两个不同的位置
    pos_pair = randperm(SH, 2);
    pos1 = min(pos_pair);
    pos2 = max(pos_pair);    
    % 提取要插入的工序（取pos2位置的工序）
    op_insert = OS(pos2);
    new_OS = OS;
    new_OS(pos2) = [];  % 删除原位置
    % 插入到pos1位置
    new_OS = [new_OS(1:pos1-1), op_insert, new_OS(pos1:end)];    
    new_solution.OS = new_OS;
    new_solution.obj = FJSP_Fitness(new_OS, MS, SS);
end
