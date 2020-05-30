function [ globel ] = GA_Run( startp,endp,model )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    %定义染色体
%123
model.startp=startp;
model.endp=endp;

my_chromosome.pos=[];
my_chromosome.alpha=[];
my_chromosome.beta=[];
my_chromosome.atkalpha=[];
my_chromosome.atkbeta=[];
my_chromosome.T=[];
my_chromosome.sol=[];
my_chromosome.cost=[];
my_chromosome.ETA=[];
my_chromosome.IsFeasible=[];
my_chromosome.AllPos=[];
%初始染色体个数
chromosome = repmat(my_chromosome,model.NP,1);
%子代染色体
next_chromosome = repmat(my_chromosome,model.NP,1);
%两代染色体
AllChromosome = repmat(my_chromosome,model.NP*2,1);
%种群的适应度值
seeds_fitness=zeros(1,model.NP);
%全局最优
globel.cost =inf;
%种群初始化
h= waitbar(0,'initial chromosome');
for i=1:model.NP
  flag =0;
  while flag ~=1
  %初始化角度和时间
  [chromosome(i).alpha,chromosome(i).T,chromosome(i).beta] = InitialChromosome(model,i);
  %根据角度和DH矩阵获得对应坐标
  [chromosome(i).pos] = Angel2Pos(chromosome(i),model);
    %形成可执行路径后,由于实际的路径可能比起始到目标的直线距离远,调整运行时间T
   [chromosome(i).T] =Modify_Chromosom_T(chromosome(i),model);
   %重新计算新的pos
  [chromosome(i).pos] = Angel2Pos(chromosome(i),model);
  %检查坐标合理
  [flag,chromosome(i).atkalpha,chromosome(i).atkbeta] = IsReasonble(chromosome(i),model);
  
  chromosome(i).IsFeasible = (flag==1);
  end

  %计算每个符合协调函数解的适应度值和每个解的具体解决方案
  [chromosome(i).cost,chromosome(i).sol] = FitnessFunction(chromosome(i),model);
  %记录所有解的适应度值，作为轮盘赌的集合
  seeds_fitness(i) = chromosome(i).cost;
  h=waitbar(i/model.NP,h,[num2str(i),':chromosomes finished']);
  
end
close(h)

%开始迭代进化
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
        seeds_fitness(index) =chromosome(index).cost; 
        if globel.cost >chromosome(index).cost
            globel = chromosome(index);
        end
    end
    
    best(it) = globel.cost;
    disp(['it: ',num2str(it),'   best value:',num2str(globel.cost)]);
    
    
    
end
model.std_ga=0;
PlotSolution(globel.sol,model);
end

