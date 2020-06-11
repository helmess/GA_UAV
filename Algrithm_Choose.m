function [ globel ] = Algrithm_Choose( startp,endp,model )
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
  if globel.cost >chromosome(i).cost
     globel.cost =chromosome(i).cost;
  end
end
close(h)
%保存初始化参数
model.seeds_fitness=seeds_fitness;
model.chromosome=chromosome ;
model.next_chromosome=next_chromosome;
model.AllChromosome=AllChromosome;
model.globel =globel;
% %%设置ga选择改进和不改进的测试
% model.std_ga=1;
% std_globel_ga= Std_GA(model.startp,model.endp,model);
% PlotSolution(std_globel_ga.sol,model);
% model.std_ga=0;
% model.alg_choose=1;
% globel_ga=GA(model);
% PlotSolution(globel_ga.sol,model);
% pause(0.01);
model.alg_choose=2;
model.improve_gapso=0;
global_gapso =GAPSO(model);
PlotSolution(global_gapso.sol,model);
pause(0.01);
model.alg_choose=4;
model.improve_gapso=1;
global_improve_gapso =GAPSO(model);
PlotSolution(global_improve_gapso.sol,model);
pause(0.01);
% model.alg_choose=3;
% global_particle =PSO(model);
% PlotSolution(global_particle.sol,model);
% pause(0.01);
figure;
% plot(globel_ga.best_plot);
% hold on;
plot(global_gapso.best_plot);
hold on;
% plot(global_particle.best_plot);
%hold on;
plot(global_improve_gapso.best_plot);
% legend('GA','GAPSO','PSO','IGAPSO');
legend('GAPSO','IGAPSO');
end

