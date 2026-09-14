function [OS,MS,SS]=initial(oper_mac)
global N H Time NM;
SH=sum(H(1:N));
%%%%%%% OS
OS_first=randperm(N,N);
OS_Second=[];
for job=1:N
    for oper=1:H(job)-1
        OS_Second=[OS_Second, job];
    end
end
OS_Second=OS_Second(randperm(numel(OS_Second)));
OS=[OS_first OS_Second];

%%%%%%% MS
MS=ceil(rand(1,SH).*oper_mac);
for k=1:SH
    MS(k)=NM{k}(MS(k));
end
%%%%%%% SS
SS=ceil(rand(1,SH)*3);
end % end function
