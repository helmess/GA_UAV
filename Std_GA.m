function [ output_args ] = Std_GA( startp,endp,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    model.startp=startp;
    model.endp=endp;
    %在起始和目的点30等分，获得顺序的x坐标
    x= linspace(startp(1),endp(1),model.dim);
    y =linspace(model.Ymin,model.Ymax,30);
    z=linspace(200,400,25);
    my_chromosome.pos=[];
    my_chromosome.cost=[];
    my_chromosome.sol=[];
    chromosome = repmat(my_chromosome,model.NP,1);
     %子代染色体
    next_chromosome = repmat(my_chromosome,model.NP,1);
    %两代染色体
    AllChromosome = repmat(my_chromosome,model.NP*2,1);
    %种群的适应度值
    seeds_fitness=zeros(1,model.NP);
    %全局最优
    globel.cost =inf;
    len =numel(x);
    %初始化染色体
    for i=1:model.NP
    for dim=1:len
        chromosome(i).pos(dim,1)=x(dim);
        chromosome(i).pos(dim,2)=y(ceil(rand*(len)));
        chromosome(i).pos(dim,3)=z(ceil(rand*(len)));
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
    
    %符合要求以后计算子代的适应度值
    [sons(1).cost,sons(1).sol] = FitnessFunction(sons(1),model);
    [sons(2).cost,sons(2).sol] = FitnessFunction(sons(2),model);
    next_chromosome(seed) = (sons(1));
    next_chromosome(seed+1) = (sons(2));
    end
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

