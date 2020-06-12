function [ gapso_global ] = DGAPSO( model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%设定子种群个数
model.npop=3;
npop=model.npop;

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
my_chromosome.best.pos=[];
my_chromosome.best.alpha=[];
my_chromosome.best.beta=[];
my_chromosome.best.T=[];
my_chromosome.best.sol=[];
my_chromosome.best.cost=[];
%初始染色体个数
input_chromosome = repmat(my_chromosome,model.NP,1);

%种群的适应度值
seeds_fitness=zeros(1,model.NP);
%全局最优
gapso_global.cost=inf;
%适应度最优值保留
best=zeros(model.MaxIt+1,1);
best(1)=model.globel.cost;
%种群初始化
for i=1:model.NP
    input_chromosome(i).pos=model.chromosome(i).pos;
    input_chromosome(i).alpha=model.chromosome(i).alpha;
    input_chromosome(i).beta=model.chromosome(i).beta;
    input_chromosome(i).atkalpha=model.chromosome(i).atkalpha;
    input_chromosome(i).atkbeta=model.chromosome(i).atkbeta;
    input_chromosome(i).T=model.chromosome(i).T;
    input_chromosome(i).sol=model.chromosome(i).sol;
    input_chromosome(i).cost=model.chromosome(i).cost;
    input_chromosome(i).IsFeasible=model.chromosome(i).IsFeasible;

    seeds_fitness(i)=model.seeds_fitness(i);
  for d=1:3
  input_chromosome(i).vel(d,:)= zeros(1,model.dim);
  end
  %更新历史最优粒子
  input_chromosome(i).best.pos =input_chromosome(i).pos;
  input_chromosome(i).best.alpha =input_chromosome(i).alpha;
  input_chromosome(i).best.beta =input_chromosome(i).beta;
  input_chromosome(i).best.T =input_chromosome(i).T;
  input_chromosome(i).best.sol =input_chromosome(i).sol;
  input_chromosome(i).best.cost =input_chromosome(i).cost;
  if gapso_global.cost > input_chromosome(i).cost
    gapso_global = input_chromosome(i);
  end
  
end
w=1;
wdamp=0.95;
c1=1.5;
c2=1.5;
c_max=3;
c_min=1;
w_ini=0.9;
w_end=0.4;
model.w=w;
model.c1=c1;
model.c2=c2;
muti_pop_chromosome=input_chromosome;

for it=1:model.MaxIt
    
    for pop=1:npop
    SonNP =model.NP/npop;
    if improve==1
    model.w =w_ini - (w_ini-w_end)*it/model.MaxIt;
    model.c1 = c_min + it*(c_max - c_min)/model.MaxIt;
    model.c2 = c_max - it*(c_max - c_min)/model.MaxIt;
    end
    chromosome = muti_pop_chromosome((pop-1)*model.NP/npop+1:pop*model.NP/npop);
    global_pop(pop)=chromosome(1);
    for i=1:SonNP
        seeds_fitness(i)=chromosome(i).cost;
    end
    
    %得到最大和平均适应度值
    model.f_max =max(seeds_fitness);
    model.f_avg =mean(seeds_fitness);
   %按照适应度对染色体排序
    sort_array =zeros(SonNP,2);
    for i=1:SonNP
    sort_array(i,:)= [i,chromosome(i).cost];
    end
    %以cost从小到大进行排序
    sort_array =sortrows(sort_array,2);
    model.p_global =gapso_global;
    %只保留前一半的染色体,后一般抛弃
    for i=1:SonNP/2
           next_chromosome(i) =chromosome(sort_array(i,1));
           %更新染色体的速度和位置
           [next_chromosome(i).vel,next_chromosome(i).alpha,next_chromosome(i).beta,next_chromosome(i).T]=Update_vel_pos( next_chromosome(i),model );
           [next_chromosome(i).pos]=Angel2Pos( next_chromosome(i),model );
           %检验坐标是否合理
           [flag(i),next_chromosome(i).atkalpha,next_chromosome(i).atkbeta] = IsReasonble(next_chromosome(i),model);
           %计算适应度值
           
           [next_chromosome(i).cost,next_chromosome(i).sol] = FitnessFunction(next_chromosome(i),model);
    end
    %子代染色体序号
    son_index=1;
    %对剩余的NP/2个染色体进行选择交叉变异操作
    for i=SonNP/2+1:2:SonNP
        %随机选择父母
        parents =repmat(my_chromosome,2,1);
        for p=1:2
        array =ceil(rand(1,2)*SonNP/2);
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

        ga_next_chromosome(son_index) = sons(1);
        ga_next_chromosome(son_index+1) =sons(2);
        son_index =son_index+2;
    end
    %择优更新种群
    all_chromosome(1:SonNP/2) = next_chromosome;
    all_chromosome(SonNP/2+1:SonNP) =ga_next_chromosome(1:SonNP/2);
     %以cost从小到大进行排序
    [~,order_index]= sort([all_chromosome.cost]);
    
    for i=1:SonNP
       chromosome(i) =all_chromosome((order_index(i)));
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
       if chromosome(i).cost < global_pop(pop).cost
           global_pop(pop) = chromosome(i);
       end
       seeds_fitness(i) =chromosome(i).cost;
      
    end
    %选出该子群里最优秀的pop_num个染色体进行交换
    pop_num=1;
    for i=1:pop_num
         pop_trans(i+(pop-1)*pop_num)=  all_chromosome(order_index(i));
    end
    
    muti_pop_chromosome((pop-1)*SonNP+1:pop*SonNP) = chromosome;
    end
    %所有子种群更新完毕，开始种群交换
    pop_1=pop_trans(1:pop_num);
    tp_pop =pop_trans(pop_num+1:end);
    pop_trans(1:pop_num* (npop-1)) =tp_pop;
    pop_trans(pop_num* (npop-1)+1:end)=pop_1;
    if it>2
    for pop=1:npop
        muti_pop_chromosome(pop*SonNP - pop_num+1:pop*SonNP)=pop_trans((pop-1)*pop_num+1:pop*pop_num);
    end
    end
    for pop=1:npop
       if  gapso_global.cost>global_pop(pop).cost
             gapso_global=global_pop(pop);
       end
    end
    
    
    best(it+1) = gapso_global.cost;
    gapso_global.best_plot =best;
    disp(['it: ',num2str(it),'   best value:',num2str(best(it))]);
    
end

    









end

