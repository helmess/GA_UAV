function [ sons ] = CrossoverAndMutation( parents,model )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %在种群中随机选择两个父母，保证父母不是同一染色体
    %一共进行NP/2次选择
%     %设置空的基因准备存储重组后的基因
     gene_alpha = zeros(model.dim,2);
     gene_beta = zeros(model.dim,2);
     gene_t = zeros(model.dim,2);
     flag =zeros(2,1);   
     %若不发生重组,令孩子的基因等于父母的基因
     sons(1) = parents(1);
     sons(2) = parents(2);
%      %随机选取基因断点位置
%      BreakPos = floor(unifrnd(1,model.dim-1,1));
     %同时获取待重组父母的基因,作为交叉的中间变量
     for j=1:2
     gene_alpha(:,j) = parents(j).alpha;
     gene_beta(:,j) = parents(j).beta;
     gene_t(:,j) =parents(j).T;
     end
     %随机选取父母任一适应度值
     f = parents(randi(2,1,1)).cost;
     %个体适应度大则大概率交叉，适应度小则小概率交叉
     if f < model.f_avg && model.std_ga==0
        model.cross_prob = (model.f_max -f)/(model.f_max - model.f_avg)*model.cross_prob;
        model.mutation_prob = (model.f_max -f)/(model.f_max - model.f_avg)*model.mutation_prob;
     end
     %浮点数交叉
      if model.cross_prob > rand
         %浮点数交叉用随机数a(0,1);
         %x1(t+1) = a*x1(t)+(1-a)x2(t)
         %x2(t+1) = a*x2(t)+(1-a)x1(t)
           %各个基因分别交叉
           cross_prob = 0.8;
           sons(1).alpha =  cross_prob*gene_alpha(:,1)+(1-cross_prob)*gene_alpha(:,2);
           sons(2).alpha =  cross_prob*gene_alpha(:,2)+(1-cross_prob)*gene_alpha(:,1);
           sons(1).beta =  cross_prob*gene_beta(:,1)+(1-cross_prob)*gene_beta(:,2);
           sons(2).beta =  cross_prob*gene_beta(:,2)+(1-cross_prob)*gene_beta(:,1);
           sons(1).T     =  cross_prob*gene_t(:,1)+(1-cross_prob)*gene_t(:,2);
           sons(2).T     =  cross_prob*gene_t(:,2)+(1-cross_prob)*gene_t(:,1);
           %各个基因约束范围
           [sons(1).alpha,sons(1).beta,sons(1).T] = Constrain(sons(1).alpha,sons(1).beta,sons(1).T,model);
           [sons(2).alpha,sons(2).beta,sons(2).T] = Constrain(sons(2).alpha,sons(2).beta,sons(2).T,model);
      end
     %%对新的基因进行变异操作
     for j=1:2
     [sons(j).alpha,sons(j).beta,sons(j).T] = Mutation(sons(j),model);
     [sons(j).alpha,sons(j).beta,sons(j).T] = Constrain(sons(j).alpha,sons(j).beta,sons(j).T,model);
     end
     %判断两个子代的新基因是否合理,若不合理重新选择父母进行杂交
     
    for j=1:2
    [sons(j).pos] = Angel2Pos(sons(j),model);
    [flag(j),sons(j).atkalpha,sons(j).atkbeta] = IsReasonble(sons(j),model);
     sons(j).IsFeasible = (flag(j)==1);
%     [sons(j).cost,sons(j).sol] = FitnessFunction(sons(j),model);
    end
    %如果不是所有的子代都符合约束则直接返回父母(为了避免程序卡主),返回0
    
    for i=1:2
       if sons(i).IsFeasible~=1 
           sons(i) = parents(i);
       end      
    end
    sons(1).T=reshape(sons(1).T,1,model.dim);
    sons(2).T =reshape(sons(1).T,1,model.dim);
end

