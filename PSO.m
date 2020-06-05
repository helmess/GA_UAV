function p_global = PSO( model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
p_global.cost=inf;
%适应度最优值保留
best=zeros(model.MaxIt+1,1);
best(1)=model.globel.cost;
%种群初始化
for i=1:model.NP
    chromosome(i).pos=model.chromosome(i).pos;
    chromosome(i).alpha=model.chromosome(i).alpha;
    chromosome(i).beta=model.chromosome(i).alpha;
    chromosome(i).atkalpha=model.chromosome(i).atkalpha;
    chromosome(i).atkbeta=model.chromosome(i).atkbeta;
    chromosome(i).T=model.chromosome(i).T;
    chromosome(i).sol=model.chromosome(i).sol;
    chromosome(i).cost=model.chromosome(i).cost;
    chromosome(i).IsFeasible=model.chromosome(i).IsFeasible;

    seeds_fitness(i)=model.seeds_fitness(i);
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
%传递参数
model.p_global =p_global;
for it=1:model.MaxIt
    for i=1:model.NP
           next_chromosome(i) =chromosome(i);
           %更新染色体的速度和位置
           [next_chromosome(i).vel,next_chromosome(i).alpha,next_chromosome(i).beta,next_chromosome(i).T]=Update_vel_pos( next_chromosome(i),model );
           [next_chromosome(i).pos]=Angel2Pos( next_chromosome(i),model );
           %计算适应度值
           [next_chromosome(i).cost,next_chromosome(i).sol] = FitnessFunction(next_chromosome(i),model);
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
    best(it+1) = p_global.cost;
    p_global.best_plot =best;
    disp(['it: ',num2str(it),'   best value:',num2str(best(it))]);
    
end

end

