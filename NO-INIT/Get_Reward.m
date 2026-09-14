function reward=Get_Reward(new_fit,old_fit,med_fit,fitcount,MaxFES)
% 新个体适应值；老个体适应值；种群适应值的中位数；当前适应值评价次数；总评价次数
focus_obj=old_fit<=med_fit;
improve_obj=new_fit<old_fit;
reward=-1;  %%初始奖励   
if fitcount<MaxFES*0.6
    if any((focus_obj & improve_obj)==1)
        reward=2;   %%%如果某个优势目标有改善
    elseif any(new_fit<old_fit)  %%% && all(new_fit<old_fit)
        reward=1;   %%%如果和原来互不支配  支配的话就不注释上面
    end
else
    if all(new_fit<=old_fit) && any(new_fit<old_fit)  %%%支配
        reward=2;   
    elseif any(new_fit<old_fit)  %%% && all(new_fit<old_fit) %%互不支配
        reward=1;  
    end
end
end