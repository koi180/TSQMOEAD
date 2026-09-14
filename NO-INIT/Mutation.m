function [child1,child2]=Mutation(pop1,pop2)
global N H oper_mac NM; 
SH=sum(H(1:N));

C_OS1=pop1.OS; C_OS2=pop2.OS; 
C_MS1=pop1.MS; C_MS2=pop2.MS; 
C_SS1=pop1.SS; C_SS2=pop2.SS; 

%%% OS  mutation 1
pos=randperm(SH,2);
while numel( unique( C_OS1(1, pos ) ) )==1 %确保工序不重复
    pos=randperm(SH,2);
end
temp=C_OS1(1, pos(1) );
C_OS1(1, pos(1) )= C_OS1(1, pos(2) );
C_OS1(1, pos(2) )= temp;

%%% OS mutation 2
pos=randperm(SH,2);
while numel( unique( C_OS2(1, pos ) ) )==1 %确保工序不重复
    pos=randperm(SH,2);
end
temp=C_OS2(1, pos(1) );
C_OS2(1, pos(1) )= C_OS2(1, pos(2) );
C_OS2(1, pos(2) )= temp;


%%% MS    mutation 1
mutation_mac_num=ceil(SH*0.02);

multi=find(oper_mac>1);
position=multi(randperm(numel(multi),mutation_mac_num));
for k=1:mutation_mac_num
    pos=position(k);
    mutation_mac=NM{pos}(randperm(oper_mac(pos),1));
    while C_MS1(pos)==mutation_mac
        mutation_mac=NM{pos}(randperm(oper_mac(pos),1));
    end
    C_MS1(1,pos)=mutation_mac;
end

%%% MS  mutation 2
multi=find(oper_mac>1);
position=multi(randperm(numel(multi),mutation_mac_num));
for k=1:mutation_mac_num
    pos=position(k);
    mutation_mac=NM{pos}(randperm(oper_mac(pos),1));
    while C_MS2(pos)==mutation_mac
        mutation_mac=NM{pos}(randperm(oper_mac(pos),1));
    end
    C_MS2(1,pos)=mutation_mac;
end



mutation_mac_num=ceil(SH*0.02);
position=randperm(SH,mutation_mac_num);
for k=1:mutation_mac_num
    pos=position(k);
    last_speed=C_SS1(pos);
    C_SS1(pos)=randperm(3,1);
    while last_speed==C_SS1(pos)
        C_SS1(pos)=randperm(3,1);
    end
end


position=randperm(SH,mutation_mac_num);
for k=1:mutation_mac_num
    pos=position(k);
    last_speed=C_SS2(pos);
    C_SS2(pos)=randperm(3,1);
    while last_speed==C_SS2(pos)
        C_SS2(pos)=randperm(3,1);
    end
end

child1.OS=C_OS1;
child1.MS=C_MS1;
child1.SS=C_SS1;
child2.OS=C_OS2;
child2.MS=C_MS2;
child2.SS=C_SS2;
end % end function