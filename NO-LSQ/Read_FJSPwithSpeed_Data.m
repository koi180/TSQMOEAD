function [Time,N,M,H]=Read_FJSPwithSpeed_Data(Data_Path)
fin=fopen(Data_Path); 
A=fscanf(fin,'%f');
A=A';
N=A(1);
M=A(2);
pos=4;
H=zeros(1,N);
for job=1:N
    H(job)=A(pos); pos=pos+1;
    for oper=1:H(job)
        mac_num=A(pos); pos=pos+1;
        for mac1=1:mac_num
            mac=A(pos); pos=pos+1;
            time=A(pos); pos=pos+1;
            Time{job}(oper,mac)=time;
        end
    end % end oper 
end
fclose(fin);
end 