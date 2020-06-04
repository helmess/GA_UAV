function GAPSO( startp,endp,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

model.startp=startp;
model.endp=endp;

my_chromosome.pos=[];
my_chromosome.alpha=[];
my_chromosome.beta=[];
my_chromosome.atkalpha=[];
my_chromosome.atkbeta=[];
my_chromosome.sol=[];
my_chromosome.cost=[];
my_chromosome.T=[];
my_chromosome.IsFeasible=[];
my_chromosome.vel=[];
my_chromosome.best.pos=[];
my_chromosome.best.alpha=[];
my_chromosome.best.beta=[];
my_chromosome.best.T=[];
my_chromosome.best.sol=[];
my_chromosome.best.cost=[];
%初始染色体个数
chromosome = repmat(my_chromosome,model.NP,1);
%子代染色体
next_chromosome = repmat(my_chromosome,model.NP,1);

%种群的适应度值
seeds_fitness=zeros(1,model.NP);
%全局最优
p_global.cost =inf;

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
  %初始化d维速度为0
  for d=1:3
  chromosome(i).vel(d,:)= zeros(1,model.dim);
  end
  %更新历史最优粒子
  chromosome(i).best.pos =chromosome(i).pos;
  chromosome(i).best.alpha =chromosome(i).alpha;
  chromosome(i).best.beta =chromosome(i).beta;
  chromosome(i).best.T =chromosome(i).T;
  chromosome(i).best.sol =chromosome(i).sol;
  chromosome(i).best.cost =chromosome(i).cost;
  %更新全局最优例子
  if p_global.cost > chromosome(i).best.cost
    p_global = chromosome(i).best;
  end
  
end
close(h);

for it=1:model.MaxIt
    %得到最大和平均适应度值
    model.f_max =max(seeds_fitness);
    model.f_avg =mean(seeds_fitness);
   %按照适应度对染色体排序
    sort_array =zeros(model.NP,2);
    for i=1:model.NP
    sort_array(i,:)= [i,chromosome(i).cost];
    end
    %以cost从小到大进行排序
    sort_array =sortrows(sort_array,2);
    model.p_global =p_global;
    %只保留前一半的染色体,后一般抛弃
    for i=1:model.NP/2
           next_chromosome(i) =chromosome(sort_array(i,1));
           %更新染色体的速度和位置
           [next_chromosome(i).vel,next_chromosome(i).alpha,next_chromosome(i).beta,next_chromosome(i).T]=Update_vel_pos( next_chromosome(i),model );
           [next_chromosome(i).pos]=Angel2Pos( next_chromosome(i),model );
           %计算适应度值
           [next_chromosome(i).cost,next_chromosome(i).sol] = FitnessFunction(next_chromosome(i),model);
    end
    %对剩余的NP/2个染色体进行选择交叉变异操作
    for i=model.NP/2+1:2:model.NP
        %随机选择父母
        parents =repmat(my_chromosome,2,1);
        for p=1:2
        array =ceil(rand(1,2)*model.NP/2);
        if next_chromosome(array(1)).cost < next_chromosome(array(2)).cost
            parents(p) = next_chromosome(array(1));
        else
            parents(p) = next_chromosome(array(2));
        end
        end
        %交叉变异操作
        [ sons] = CrossoverAndMutation( parents,model );
        %符合要求以后计算子代的适应度值
        [sons(1).cost,sons(1).sol] = FitnessFunction(sons(1),model);
        [sons(2).cost,sons(2).sol] = FitnessFunction(sons(2),model);
        next_chromosome(i) = sons(1);
        next_chromosome(i+1) =sons(2);
    end
    for i=1:model.NP
       chromosome(i) =next_chromosome(i);
       %更新局部最优
       if chromosome(i).cost < chromosome(i).best.cost
              chromosome(i).best.pos =chromosome(i).pos;
              chromosome(i).best.alpha =chromosome(i).alpha;
              chromosome(i).best.beta =chromosome(i).beta;
              chromosome(i).best.T =chromosome(i).T;
              chromosome(i).best.sol =chromosome(i).sol;
              chromosome(i).best.cost =chromosome(i).cost;
       end
       %更新全局最优
       if chromosome(i).cost < p_global.cost
           p_global = chromosome(i);
       end
       seeds_fitness(i) =chromosome(i).cost;
    end
    best(it) = p_global.cost;
    disp(['it: ',num2str(it),'   best value:',num2str(p_global.cost)]);
    
end

PlotSolution(p_global.sol,model);

end

