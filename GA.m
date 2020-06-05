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

   for it=1:model.MaxIt
    %得到最大和平均适应度值
    model.f_max =max(seeds_fitness);
    model.f_avg =mean(seeds_fitness);
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
    while flag~=1
    [parents,flag] = SelectChromosome(seeds_accumulate_probability,model,chromosome);
    %在父母染色体进行基因重组和变异操作，
    %并获得保证每个子代都符合约束条件
    end
    
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
    
    for i=1:model.NP*2
    eval_array(i,:) = [i,AllChromosome(i).cost];
    end
    %以cost从小到大进行排序
    eval_array =sortrows(eval_array,2);
    last_cost=eval_array(1,2);
    cnt =1;
    chromosome(cnt) = AllChromosome(eval_array(1,1));
    %下次迭代的染色体为不重复cost的最优染色体
    for i=2:model.NP*2
        current_cost = eval_array(i,2);
        if current_cost ~= last_cost
        cnt = cnt+1;
        chromosome(cnt) = AllChromosome(eval_array(i,1));
        last_cost = current_cost;
        end
    end
    %如果下次迭代的染色体数目不够，就根据轮盘赌补染色体。
    cnt_r =cnt;
    while cnt <model.NP
        cnt= cnt+1;
        chromosome(cnt) = AllChromosome(eval_array(cnt - cnt_r,1));
    end
    %选出迭代的染色体和全局最优染色体
    for index =1:model.NP
        if model.std_ga==1
            chromosome(index) =next_chromosome(index);
        end
        seeds_fitness(index) =chromosome(index).cost; 
        if globel.cost >chromosome(index).cost
            globel = chromosome(index);
        end
    end
    
    best(it+1) = globel.cost;
    globel.best_plot =best;
    disp(['it: ',num2str(it),'   best value:',num2str(best(it))]);
    
    end

end

