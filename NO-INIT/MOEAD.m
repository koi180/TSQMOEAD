function [Elite,used_time]=MOEAD(Popsize,MaxFES,pc,pm,T)
global N H Time M NM oper_mac;
Start_time=cputime;
[oper_mac,NM]=get_oper_mac();
empty_ind.obj = [];
empty_ind.OS=[];
empty_ind.MS=[];
empty_ind.SS=[];

[W,Popsize] = UniformPoint(Popsize,3,'MUD');
B = pdist2(W,W);
[~,B] = sort(B,2);
B = B(:,1:T);

fitcount=0;
Pop = repmat(empty_ind, Popsize, 1);
for i=1:Popsize
    [Pop(i).OS,Pop(i).MS,Pop(i).SS]=initial(oper_mac);
    [Pop(i).obj]=FJSP_Fitness(Pop(i).OS,Pop(i).MS,Pop(i).SS);
    fitcount=fitcount+1;
end
Z = min(cat(1,Pop.obj),[],1);
Zmax = max(cat(1,Pop.obj),[],1);
iter=0;
% 强化学习参数
Qtable=zeros(8,5);
gamma=0.85;
alpha=0.15;

while fitcount<MaxFES
    iter=iter+1; 
    epsilon = 0.5 + 0.4 * (fitcount/MaxFES);
    for i = 1 : Popsize
        % Choose the parents
        P = B(i,randperm(size(B,2)));
        if rand<pc
            [child1,child2]=Crossover(Pop(P(1)),Pop(P(2)));
            if rand<pm
                [child1,child2]=Mutation(child1,child2);
            end
        else
            child1=Pop(P(1)); child2=Pop(P(2));
            [child1,child2]=Mutation(child1,child2);
        end
       [child1.obj]=FJSP_Fitness(child1.OS,child1.MS,child1.SS);
        Z = min(Z,child1.obj);
        Zmax = max(Zmax,child1.obj);
        [child2.obj]=FJSP_Fitness(child2.OS,child2.MS,child2.SS);
        Z = min(Z,child2.obj);
        Zmax = max(Zmax,child2.obj);

        % 比较父代和子代适应值，如果适应值相同，保留父代
        parent1 = Pop(P(1));
        parent2 = Pop(P(2));
        child1_valid = true;
        child2_valid = true;     
        if isequal(child1.obj, parent1.obj) || isequal(child1.obj, parent2.obj)
            child1_valid = false;
        end
        if isequal(child2.obj, parent1.obj) || isequal(child2.obj, parent2.obj)
            child2_valid = false;
        end
        fitcount=fitcount+2;
        % Update the ideal point       
        if child1_valid
            g_old = max(abs(cat(1,Pop(P).obj)-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(P,:),[],2);
            g_new = max(repmat(abs(child1.obj-Z)./(Zmax-Z),T,1).*W(P,:),[],2);
            Update=find(g_old>=g_new);
            if numel(Update)>0
                update=P(Update(randperm(numel(Update),1)));
                Pop(update)=child1;
            end
        end

        if child2_valid
            g_old = max(abs(cat(1,Pop(P).obj)-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(P,:),[],2);
            g_new = max(repmat(abs(child2.obj-Z)./(Zmax-Z),T,1).*W(P,:),[],2);
            Update=find(g_old>=g_new);
            if numel(Update)>0
                update=P(Update(randperm(numel(Update),1)));
                Pop(update)=child2;
            end
        end
    end

    [~,FrontNo,CrowdDis] = EnvironmentalSelection(Pop,Popsize);
    Elite=Pop(FrontNo==1);

    all_obj = cat(1,Pop.obj);
    med_fit = median(all_obj, 1);
    %局部搜索+Q
    locals_pop=[];
    STATES=Get_States(Elite,Pop);
    for k =1:numel(Elite)
        state= STATES(k);
        for locals=1:1
            if rand<epsilon
                Action_Value=Qtable(state,:);
                action_set=find(Action_Value==max(Action_Value));
                action=action_set(randperm(numel(action_set),1));
            else
                action=randperm(5,1);
            end
                        
            if action==1
                pop=  LS1(Elite(k));
            elseif action==2
                pop=  LS2(Elite(k));
            elseif action==3
                pop=  LS3(Elite(k));
            elseif action==4
                pop=  LS4(Elite(k));
            else
                pop=  LS5(Elite(k));
            end %end if
            
            [pop.obj]=FJSP_Fitness(pop.OS,pop.MS,pop.SS);
            old_fit = Elite(k).obj;
            new_fit = pop.obj;
            reward = Get_Reward(new_fit, old_fit, med_fit, fitcount, MaxFES);
            next_state=Get_States(pop,Pop);           
            maxreward=max(Qtable(next_state,:));
            Qtarget=reward+gamma*maxreward;
            Qtable(state,action)=Qtable(state,action)+alpha*(Qtarget- Qtable(state,action));
            fitcount=fitcount+1;
            locals_pop=[locals_pop;pop];
            Z = min(Z,pop.obj);
            Zmax = max(Zmax, pop.obj);
            all_obj = cat(1,Pop.obj, locals_pop.obj);
            med_fit = median(all_obj, 1);       
            g_old = max(abs(cat(1,Pop.obj)-repmat(Z,Popsize,1))./repmat(Zmax-Z,Popsize,1).*W,[],2);
            g_new = max(repmat(abs(pop.obj-Z)./(Zmax-Z),Popsize,1).*W,[],2);
            Update=find(g_old>=g_new);
            if numel(Update)>0
                update=(Update(randperm(numel(Update),1)));
                Pop(update)=pop;
            end
        end % end locals
    end % end k
    [~,FrontNo,CrowdDis] = EnvironmentalSelection([Pop;locals_pop],Popsize);
    Elite=Pop(FrontNo==1);
end
[Elite]=Eliminate_Duplicates1(Elite);
[Elite,FrontNo,CrowdDis] = EnvironmentalSelection(Elite,numel(Elite));
Elite=Elite(FrontNo==1);
used_time=cputime-Start_time;
end   % end function




%%%% oper_mac
function [oper_mac,NM]=get_oper_mac()
global N H Time;
k=0;
for job=1:N
    for oper=1:H(job)
        k=k+1;
        NM{1,k}=find(Time{job}(oper,:)~=0);  %先工件后工序排列
        oper_mac(1,k)=numel(find(Time{job}(oper,:)~=0)); %每个工序可用的机器数量
    end  % end oper
end  % end job
end % end function



