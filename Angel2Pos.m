function [ pos ] = Angel2Pos( chromosome,model )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
   startp =model.startp;
    endp =model.endp;
%%计算无人机位置
%计算起始到中点的方向    
     %计算起始到目标的向量
   st = endp-startp;
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
    
%初始起点坐标
last_pos=startp;
acum_beta=cumsum(deg2rad( chromosome.beta));
acum_alpha=cumsum(deg2rad( chromosome.alpha));
%加上起始点到目标的朝向
acum_alpha =acum_alpha+deg2rad( st_alpha);
acum_beta =acum_beta + deg2rad(st_beta);
for i =1:model.dim
%俯仰角相对于起始位置
beta =acum_beta(i);
%航偏角相对于起始位置
alpha = acum_alpha(i);
% a = chromosome.T(i,uav)*model.vel*cos(theta)*sin(alpha);
% d = chromosome.T(i,uav)*model.vel*sin(theta);
L = chromosome.T(i)*model.vel;
dz = L*sin(beta);
dx = L*cos(beta)*cos(alpha);
dy = L*cos(beta)*sin(alpha);
next_pos =[last_pos(1)+dx,last_pos(2)+dy,last_pos(3)+dz];
%更新下一个坐标点
last_pos = next_pos;
%更新无人机的位置坐标
pos(i,1) = last_pos(1);
pos(i,2) = last_pos(2);
pos(i,3) = last_pos(3);
end





end

