function model = CreateModel()
%起始点坐标
sx =[300];
sy =[450];
sz =[285];
%终点坐标
ex =930;
ey =810;
ez =285;
%航偏角范围
alpha_min= -30;
alpha_max = 30;
%俯仰角范围
beta_min = -15;
beta_max = 15;
%GA种群数
NP=30;
%GA最大迭代次数
MaxIt=50;
%每条染色体的维度
dim =10;
%num个个体初始化方式
num=3;
%交叉概率
cross_prob =0.9;
%变异概率
mutation_prob=0.1;
%雷达位置
xobs =[500,675,830];
yobs =[475,750,515];
zobs = [238, 275, 240];
robs =[150,163,150];
%武器位置
weapon_x=[700,530];
weapon_y=[680,520];
weapon_z=[275,263];
weapon_r=[93,93];

model.weapon_x=weapon_x;
model.weapon_y=weapon_y;
model.weapon_z=weapon_z;
model.weapon_r=weapon_r;
%任务点
mission_seq=[2 3 1];
mission_x=[800,410,555];
mission_y=[580,545,675];
mission_z=[278,280,280];
mission_r=[15,15,15];
model.mission_seq =mission_seq;
model.mission_x=mission_x;
model.mission_y=mission_y;
model.mission_z=mission_z;
model.mission_r=mission_r;
%地图大小
%x,y,z方向范围
Xmin=300;Xmax=1000;Ymin=300;Ymax=900;Zmin=0;Zmax=500;
model.Xmin =Xmin;
model.Xmax =Xmax;
model.Ymin =Ymin;
model.Ymax =Ymax;
model.Zmin =Zmin;
model.Zmax =Zmax;
mapmin=[0 0 0];
mapmax=[700e3 600e3 500e3];
%指定攻击角alpha
attack_alpha =[60 -60];
model.attack_alpha = attack_alpha;
model.beta_max =beta_max;
model.beta_min = beta_min;
model.sz =sz;
model.ez =ez;
model.zobs =zobs;
model.mapmin =mapmin;
model.mapmax =mapmax;
model.xobs=xobs;
model.yobs=yobs;
model.robs=robs;
model.mutation_prob=mutation_prob;
model.cross_prob=cross_prob;
model.num=num;
model.dim=dim;
model.NP=NP;
model.MaxIt=MaxIt;
model.sx =sx;
model.sy =sy;
model.ex =ex;
model.ey=ey;
model.alpha_min =alpha_min;
model.alpha_max =alpha_max;


%%定义无人机
UAV = numel(sx);
vel =200;
vrange=[180 200];
%协同时间分为intervel个时间间隔之和
intervel=20;
%无人机安全距离
security_dist =5;
model.security_dist =security_dist;
model.intervel=intervel;
%计算起点到目标的距离除以最大速度
Tmax = norm([sx(1)-ex,sy(1)-ey,ez(1)-ez(1)])/vrange(1);
Tmin =0;
model.Tmin =Tmin;
model.Tmax =Tmax;
model.vrange =vrange;
model.vel = vel;
model.UAV=UAV;

%matlab调试
debug =1;
model.debug =debug;


end