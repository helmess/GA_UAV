function [ flag_r ,AttackAlpha,AttackBeta] = IsReasonble( chromosome,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%检查航路是否合理
%位置坐标越界则该航路不满足要求，重新生成
sum_alpha =0;
sum_beta =0;
%记录新的角的值

   for i=1:model.dim
      if  chromosome.pos(i,1) <model.Xmin || chromosome.pos(i,2) <model.Ymin || ...
          chromosome.pos(i,1) >model.Xmax || chromosome.pos(i,2) >model.Ymax||...
          chromosome.pos(i,3) <model.Zmin || chromosome.pos(i,3) > model.Zmax
          AttackAlpha=0;
          AttackBeta =0;
          flag_r =2;
          
      
          return
      end
   end

  %检查最后的偏角能否符合要求
 
     %航路最后一个点
   lastpoint=chromosome.pos(model.dim,:);
   endpoint =model.endp;
   last2end = endpoint -lastpoint;
   
   %计算最终偏角方向和最后一个点到终点的方向的夹角
   %分别计算航偏角和俯仰角
   for i=1:model.dim
      sum_alpha=sum_alpha + chromosome.alpha(i);
      sum_beta  = sum_beta + chromosome.beta(i);
   end
   
    %计算起始到目标的向量
   st = model.endp - model.startp;
   %水平向量
   vhorizontal=[1,0];
   %计算起始到目标的航偏角
    st_alpha = rad2deg( acos(dot(st(1:2),vhorizontal)/norm(st(1:2))/norm(vhorizontal) )  );
    %如果正弦值小于0
    if st(2)/norm(st(1:2)) <0
        st_alpha =360 - st_alpha;        
    end
    %计算起始到目标的俯仰角
    st_beta = rad2deg(asin(st(3)/norm(st)));
   %角度转换弧度
    sum_alpha = sum_alpha + st_alpha;
    sum_beta= sum_beta +st_beta;
    sum_alpha= deg2rad(sum_alpha);
    sum_beta= deg2rad(sum_beta);
    %总的航偏角的方向向量
    lastdeg =[cos(sum_alpha),sin(sum_alpha)];
    %投影到XOY计算航偏角的最后变化值
    theta = rad2deg(acos(dot(last2end(1:2),lastdeg)/norm(last2end(1:2))/norm(lastdeg)));
    %计算last2end的俯仰角
    ag1 = rad2deg(asin(last2end(3)/norm(last2end)));
    %用last2end的俯仰角 - 总的俯仰角 = 从最后一个点到终点的俯仰角变化 
    ag2 =abs( ag1 - sum_beta);
    %计算最后的攻击角
    AttackAlpha = theta;
    AttackBeta = ag2;
    %根据指定攻击角计算每个航偏角平均增加的角度值
%     average_value(uav) = (model.attack_alpha(uav) -  AttackAlpha(uav))/(model.dim+1);
   
    
    if theta >0 && theta < model.alpha_max &&...
       ag2 >0 && ag2 <model.beta_max
        flag_r = 1;
    else
        flag_r = 0;
    end
  end
  %若不是所有无人机都满足航偏角及俯仰角在范围内，则淘汰
%   if sum(flag)~=model.UAV
%       flag_r =0;
%       ETA=0;
%       return;
%   end
%    %检查能否达到时间上的协同 
%   [flag_time ,ETA_r] =EstimateTime( chromosome,model ); 
%   %两者都满足说明该解符合要求
%   flag_r = flag_time ;
%   ETA =ETA_r;
  

