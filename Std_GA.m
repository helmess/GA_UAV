function Std_GA( startp,endp,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    model.startp=startp;
    model.endp=endp;
    model.NP=40;
    model.MaxIt=50;
    %在起始和目的点30等分，获得顺序的x坐标
    model.dim=10;
    x= linspace(startp(1),endp(1),model.dim+2);
    slice =50;
    y =linspace(startp(2),endp(2),slice);
    z=linspace(200,350,slice);
    my_chromosome.pos=[];
    my_chromosome.cost=[];
    my_chromosome.sol=[];
    chromosome = repmat(my_chromosome,model.NP,1);
    %两代染色体
    AllChromosome = repmat(my_chromosome,model.NP*2,1);
     %子代染色体
    next_chromosome = repmat(my_chromosome,model.NP,1);
    %种群的适应度值
    seeds_fitness=zeros(1,model.NP);
    %全局最优
    globel.cost =inf;
    len =numel(x)-2;
    %初始化染色体
    for i=1:model.NP
        if i<2
            for dim=1:len
                chromosome(i).pos(dim,1)=x(dim+1);
                chromosome(i).pos(dim,2)=y(ceil(dim*slice/len));
                chromosome(i).pos(dim,3)=z(ceil(dim*slice/len));
            end
        else
            for dim=1:len
            chromosome(i).pos(dim,1)=x(dim+1);
            chromosome(i).pos(dim,2)=y(ceil(rand*slice));
            chromosome(i).pos(dim,3)=z(ceil(rand*slice));
            end
        end
    [chromosome(i).cost,chromosome(i).sol]=FitnessFunction( chromosome(i),model );
    seeds_fitness(i) = chromosome(i).cost;
    end
    
    %开始迭代进化
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
    while flag~=1
    [parents,flag] = SelectChromosome(seeds_accumulate_probability,model,chromosome);
    %在父母染色体进行基因重组和变异操作，
    %并获得保证每个子代都符合约束条件
    end
    %重组
    sons =parents;
    if model.cross_prob > rand
        %保存所有需要重组的基因
        cross_prob = 0.8;
        gene_pos(:,:,1)=parents(1).pos(:,2:3);
        gene_pos(:,:,2)=parents(2).pos(:,2:3);
        sons(1).pos(:,2:3) = cross_prob*gene_pos(:,:,1)+(1-cross_prob)*gene_pos(:,:,2);
        sons(2).pos(:,2:3) = cross_prob*gene_pos(:,:,2)+(1-cross_prob)*gene_pos(:,:,1);
    end
    %变异
    if model.mutation_prob>rand
    r = randi(10,1,1);
    k = 0.1;
    if mod(r,2) ==1
    sons(1).pos(:,2:3) = sons(1).pos(:,2:3) - k*(sons(1).pos(:,2:3) - ones(model.dim,1)*[model.Ymin,200])*r/10;
    sons(2).pos(:,2:3) = sons(2).pos(:,2:3) - k*(sons(2).pos(:,2:3) - ones(model.dim,1)*[model.Ymin,200])*r/10;
    else
    sons(1).pos(:,2:3) = sons(1).pos(:,2:3) + k*(ones(model.dim,1)*[model.Ymax,500]-sons(1).pos(:,2:3))*r/10;
    sons(2).pos(:,2:3) = sons(2).pos(:,2:3) + k*(ones(model.dim,1)*[model.Ymax,500]-sons(2).pos(:,2:3))*r/10;
    end
    
    end
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
        seeds_fitness(index) =chromosome(index).cost; 
        if globel.cost >chromosome(index).cost
            globel = chromosome(index);
        end
    end
  
    best(it) = globel.cost;
    disp(['it: ',num2str(it),'   best value:',num2str(globel.cost)]);
    
    
    
    end
model.std_ga=1;
PlotSolution(globel.sol,model);   
end

