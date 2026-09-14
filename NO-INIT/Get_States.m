function STATES = Get_States(Elite, Pop)
    % 提取适应值
    fit = cat(1, Pop.obj);
    E_fit = cat(1, Elite.obj);
    % 计算中位数
    M_F1 = median(fit(:,1));
    M_F2 = median(fit(:,2));
    M_F3 = median(fit(:,3));    
    % 为每个精英个体分配状态
    for k = 1:numel(Elite)
        STATES(k,1) = get_fit_states(E_fit(k,:), M_F1, M_F2, M_F3);
    end
end

function a = get_fit_states(b, M1, M2, M3)
    % b: 个体的三个目标值 [f1, f2, f3]
    % M1, M2, M3: 三个目标的中位数
    
    % 根据与中位数的比较划分8个状态
    if b(1) <= M1 && b(2) <= M2 && b(3) <= M3
        a = 1;
    elseif b(1) <= M1 && b(2) <= M2 && b(3) > M3
        a = 2;
    elseif b(1) <= M1 && b(2) > M2 && b(3) <= M3
        a = 3;
    elseif b(1) <= M1 && b(2) > M2 && b(3) > M3
        a = 4;
    elseif b(1) > M1 && b(2) <= M2 && b(3) <= M3
        a = 5;
    elseif b(1) > M1 && b(2) <= M2 && b(3) > M3
        a = 6;
    elseif b(1) > M1 && b(2) > M2 && b(3) <= M3
        a = 7;
    else  % b(1) > M1 && b(2) > M2 && b(3) > M3
        a = 8;
    end
end




