function [globel]=GA( model )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
seeds_fitness =model.seeds_fitness;
chromosome =model.chromosome;
next_chromosome=model.next_chromosome;
AllChromosome=model.AllChromosome;
globel.cost =inf;
%适应度最优值保留
best=zeros(model.MaxIt+1,1);
best(1)=model.globel.cost;
[~,global_index ]=min(seeds_fitness);
   for it=1:model.MaxIt

    %由于适应度值越小越好
    seeds_fitness = 1./seeds_fitness;
    total_fitness = sum(seeds_fitness);
    seeds_probability = seeds_fitness/ total_fitness;
    %计算累计概率
    seeds_accumulate_probability = cumsum(seeds_probability, 2);    
    %根据轮盘赌选择父母,总共选择出NP个子代
    for seed=1:2:model.NP
    flag =0;
    %保证父母和子代都符合要求

    [parents,flag] = SelectChromosome(seeds_accumulate_probability,model,chromosome);
    %在父母染色体进行基因重组和变异操作，
    %并获得保证每个子代都符合约束条件

    
    [ sons] = CrossoverAndMutation( parents,model );
    
    %符合要求以后计算子代的适应度值
    [sons(1).cost,sons(1).sol] = FitnessFunction(sons(1),model);
    [sons(2).cost,sons(2).sol] = FitnessFunction(sons(2),model);
    next_chromosome(seed) = (sons(1));
    next_chromosome(seed+1) = (sons(2));
    end
   %把新旧合并同一种群
    AllChromosome(1:model.NP) = chromosome(1:model.NP);
    AllChromosome(model.NP+1:model.NP*2) = next_chromosome(1:model.NP);
    %精英保留,新旧种群一起比较
    

    [~,order]=sort([AllChromosome.cost]);
    
    %选出迭代的染色体和全局最优染色体
    for index =1:model.NP
        chromosome(index) = next_chromosome(index);
        seeds_fitness(index) =chromosome(index).cost; 
        if globel.cost >chromosome(index).cost
            globel = chromosome(index);
            global_index =index;
        end
    end
    %保留最优值
    chromosome(global_index) = globel;
    best(it+1) = globel.cost;
    disp(['it: ',num2str(it),'   best value:',num2str(best(it))]);
    
    end
    globel.best_plot =best;
end

