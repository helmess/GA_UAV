function [ improve_global ] = tabusearch( chromosome,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    improve_global= chromosome;
    for di=1:2
    model.di=di;
    local_cost =chromosome.cost;
    cur_cost=inf;
    %设定初始解
    if di==1
    x =chromosome.alpha;
    else
    x =chromosome.beta;
    end
    %随机搜索每个维度的领域
    tabulist=[];
    tabulist=[tabulist;x'];
    for echo=1:4
       sneiborhood =  getneighborhood(x,model);
       bestcandidate =  x;
       [k,~]=size(sneiborhood);
       for i=1:k
           if di==1
           chromosome.alpha = sneiborhood(i,:)';
           else
           chromosome.beta = sneiborhood(i,:)';    
           end
           [chromosome.pos] = Angel2Pos(chromosome,model);
           [chromosome.cost,chromosome.sol] = FitnessFunction(chromosome,model);
           if chromosome.cost< local_cost && findneighbor(tabulist,bestcandidate,model)~=1
               bestcandidate = sneiborhood(i,:);
               improve_global =chromosome;
               cur_cost = chromosome.cost;
               local_cost =cur_cost;
           end
            %计算fitness
       end
        %加到搜索列表
           bestcandidate =reshape(bestcandidate,1,model.dim);
           tabulist=[bestcandidate;tabulist];
           if di==1
           alpha =bestcandidate;
           else
           beta =bestcandidate;
           end
    end
    if di==1
        chromosome.alpha =alpha';
        chromosome.cost =local_cost;
    else
        chromosome.beta =beta';
    end
    
    end

end


function alpha_neighbor = getneighborhood(x,model)
    step=1;
    neighborrange=5;
    di =model.di;
    if di==1
    x_min =model.alpha_min;
    x_max = model.alpha_max;
    else
    x_min =model.beta_min;
    x_max = model.beta_max;    
    end
    x=reshape(x,1,model.dim);
    for i=1:neighborrange
    x = x + rand(1,model.dim)*step*2 -step;
    x =max(x,x_min);
    x =min(x,x_max);
    x =reshape(x,1,model.dim);
    alpha_neighbor(i,:) =x;
    end
end

function flag = findneighbor(tabulist,x,model)
    [k,~]=size(tabulist);
    x=reshape(x,1,model.dim);
    for i=1:k
       if sum( find(tabulist(i,:)==x ))==model.dim
           flag=1;
           break;
       end
    end
    flag=0;    
end
