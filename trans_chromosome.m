function [ trans_chromosome ] = trans_chromosome( chromosome,model,end2start_flag )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    trans_chromosome =chromosome;
    %转换航偏角
    for i=2:model.dim
        trans_chromosome.alpha(i) = chromosome.alpha(model.dim-i+2);
    end
    %由于起始到终点和终点到起点的初始朝向不同，所以第一个航偏角要计算
    if end2start_flag==1
    %最后一个点到起点的向量
    last2start =[chromosome.pos(model.dim,1)-model.startp(1),chromosome.pos(model.dim,2)-model.startp(2),chromosome.pos(model.dim,3)-model.startp(3)];
    %终点到起点的向量
    end2start=model.endp -model.startp;
      %计算起始到目标的航偏角
    st_alpha = rad2deg( acos(dot(last2start(1:2),end2start(1:2))/norm(last2start(1:2))/norm(end2start(1:2)) ) );
    else
    %最后一个点到终点的向量
    last2end =[chromosome.pos(model.dim,1)-model.endp(1),chromosome.pos(model.dim,2)-model.endp(2),chromosome.pos(model.dim,3)-model.endp(3)];
    %终点到起点的向量
    start2end=model.endp -model.startp;   
    st_alpha = rad2deg( acos(dot(last2end(1:2),start2end(1:2))/norm(last2end(1:2))/norm(start2end(1:2)) ) );
    end
    trans_chromosome.alpha(1)=st_alpha;
    %转换俯仰角和时间
    for i=1:model.dim
        trans_chromosome.beta(i)= -chromosome.beta(model.dim-i+1);
        trans_chromosome.T(i) =chromosome.T(model.dim-i+1);
    end
    
    
end

