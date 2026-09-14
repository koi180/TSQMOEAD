function [child1,child2]=Crossover(pop1,pop2)
global N H;
SH=sum(H(1:N));

OS1=pop1.OS; OS2=pop2.OS; 
MS1=pop1.MS; MS2=pop2.MS; 
SS1=pop1.SS; SS2=pop2.SS; 
%%%% OS
o1 = OS1;
o2 = OS2;
o1_offspring = zeros(1, SH);   %存储子代1
o2_offspring = zeros(1, SH);   %存储子代2
save1 = randperm(N, ceil(rand * (N - 1)));       %o1保留的工件
save2 = setdiff(cumsum(ones(1,N)),save1);        %o2保留的工件
index_save1_o1=find(ismember(o1, save1)==1);
index_save1_o2=find(ismember(o2, save1)==1);
index_save2_o1=find(ismember(o1, save2)==1);
index_save2_o2=find(ismember(o2, save2)==1);
temp_1=o1; temp_2=o2; %存储o1的位置
o1_offspring(index_save1_o1)=o1(index_save1_o1);
o2_offspring(index_save2_o2)=o2(index_save2_o2);
o1_offspring(index_save2_o1)=temp_2(index_save2_o2);
o2_offspring(index_save1_o2)=temp_1(index_save1_o1);
OS1=o1_offspring;
OS2=o2_offspring;

%%%% MS
pro=rand(1,SH)<0.5;
temp=MS1;
MS1(pro)=MS2(pro);
MS2(pro)=temp(pro);

%%%%% ss
pro=rand(1,SH)<0.5;
temp=SS1;
SS1(pro)=SS2(pro);
SS2(pro)=temp(pro);

child1=pop1; 
child1.OS=OS1;
child1.MS=MS1;
child1.SS=SS1;
child2=pop2; 
child2.OS=OS2;
child2.MS=MS2;
child2.SS=SS2;
end  %% end function 

