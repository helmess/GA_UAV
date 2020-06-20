function p_global=GAPSO(model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

improve=model.improve_gapso;
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
my_chromosome.pso=[];
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
    chromosome(i).beta=model.chromosome(i).beta;
    chromosome(i).atkalpha=model.chromosome(i).atkalpha;
    chromosome(i).atkbeta=model.chromosome(i).atkbeta;
    chromosome(i).T=model.chromosome(i).T;
    chromosome(i).sol=model.chromosome(i).sol;
    chromosome(i).cost=model.chromosome(i).cost;
    chromosome(i).IsFeasible=model.chromosome(i).IsFeasible;
    chromosome(i).pso=1;
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
    global_index =i;
  end
  
end
w=0.8;
wdamp=0.95;
c1=1;
c2=1;
c_max=3;
c_min=1;
w_ini=0.9;
w_end=0.4;
model.w=w;
model.c1=c1;
model.c2=c2;
for it=1:model.MaxIt
    %
%     if improve==1
%     model.w =w_ini - (w_ini-w_end)*it/model.MaxIt;
%     model.c1 = c_min + it*(c_max - c_min)/model.MaxIt;
%     model.c2 = c_max - it*(c_max - c_min)/model.MaxIt;
%     end
    %得到最大和平均适应度值
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
           %检验坐标是否合理
           [flag,next_chromosome(i).atkalpha,next_chromosome(i).atkbeta] = IsReasonble(next_chromosome(i),model);
           if flag==2
           next_chromosome(i) =chromosome(i);
           end
           %计算适应度值
           [next_chromosome(i).cost,next_chromosome(i).sol] = FitnessFunction(next_chromosome(i),model);
           next_chromosome(i).pso=1;
         
    end
    %对剩余的NP/2个染色体进行选择交叉变异操作
    for i=model.NP/2+1:2:model.NP
        %随机选择父母
        parents =repmat(my_chromosome,2,1);
        for p=1:2
        array =ceil(rand(1,2)*(model.NP)/2);
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
%         if improve==2
% %         next_chromosome(i) = SA(sons(1),model);
% %         next_chromosome(i+1) =SA(sons(2),model);
%         else
        next_chromosome(i) =sons(1);
        next_chromosome(i+1)=sons(2);
%         end
        next_chromosome(i).pso=0;
        next_chromosome(i+1).pso=0;
    end
  
    for i=1:model.NP
      
        [~,order_index]= sort([next_chromosome.cost]);
        chromosome(i) =next_chromosome((order_index(i)));
      
     
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
           %记录最优值的索引
           global_index =i;
       end
       seeds_fitness(i) =chromosome(i).cost;
    end
    %自适应禁忌搜索
    f_max =max(seeds_fitness);
    f_min =min(seeds_fitness);
    
    
    if improve==1 
    model.it =it;
    p_global =tabusearch(p_global,model);
    %更新最优染色体
    chromosome(global_index).cost =p_global.cost;
    chromosome(global_index).pos =p_global.pos;
    chromosome(global_index).alpha =p_global.alpha;
    chromosome(global_index).beta =p_global.beta;
    chromosome(global_index).T =p_global.T;
    chromosome(global_index).sol =p_global.sol;
           if chromosome(global_index).best.cost < chromosome(global_index).cost
              chromosome(global_index).best.pos =chromosome(global_index).pos;
              chromosome(global_index).best.alpha =chromosome(global_index).alpha;
              chromosome(global_index).best.beta =chromosome(global_index).beta;
              chromosome(global_index).best.T =chromosome(global_index).T;
              chromosome(global_index).best.sol =chromosome(global_index).sol;
           end
 
    end
    best(it+1) = p_global.cost;
    disp(['it: ',num2str(it),'   best value:',num2str(best(it))]);
end
p_global.best_plot =best;
%PlotSolution(p_global.sol,model);

end

