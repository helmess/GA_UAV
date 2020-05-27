function   plotmap( model )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global zcubic;
global wi;
global di;
global Scene;
    Scene=figure(1);
    scale=[model.Xmin,model.Xmax,model.Ymin,model.Ymax,model.Zmin,model.Zmax];
    axis(scale);
    hold on;
    %画地形
width=300:100:1000;%x
depth=300:100:900;%y
height=[157,187,195,182.5,135,100,60,110;
    205,237.50,230,225,200,280,260,235;
    222.5,250,250,225,130,165,170,150.5;
    245.75,175,150,212.5,237.5,195,190.5,180.5;
    245.5,175,150,262.5,275,262.5,370,142.5;
    245.25,262.5,275,262.5,275,275,275,262.5;
    245,250,262.5,252.5,232.5,200,175,120];
    wi=300:5:1000;
    di=300:5:900;
    di=di';
    %差值拟合  嗯嗯
    zcubic=interp2(width,depth,height,wi,di,'cubic');
    %三维地形显示
    surfc(wi,di,zcubic,'FaceColor','none','EdgeColor','flat');  
    xlabel('Width')  
    ylabel('Depth')  
    zlabel('Heitht')  
    %alpha(0.6);
    %画起点、终点
    plot3(model.sx,model.sy,model.sz,'*');
    plot3(model.ex,model.ey,model.ez,'*');
    % 画雷达
for k=1:numel(model.xobs)   
    [x,y,z]=sphere(16);
    z(z<0)=nan;
    r=model.robs(k);
    x0=model.xobs(k);    y0=model.yobs(k);    z0=model.zobs(k);
    X=x*r+x0;    Y=y*r+y0;    Z=z*r+z0; 
    surf(X,Y,Z,'EdgeColor','b','FaceColor','none');
    hold on;
end
%画任务
for k=1:numel(model.mission_x)
    [x,y,z]=sphere(30);  
    r=model.mission_r(k);
    x0=model.mission_x(k);    y0=model.mission_y(k);    z0=model.mission_z(k);
    X=x*r+x0;    Y=y*r+y0;    Z=z*r+z0; 
    surf(X,Y,Z,'EdgeColor','none','FaceColor',[0.929,0.694,0.125]);
    hold on;
end
%画武器
for k=1:numel(model.weapon_x)
    [x,y,z]=sphere(12);
    z(z<0)=nan;
    r=model.weapon_r(k);
    x0=model.weapon_x(k);    y0=model.weapon_y(k);   z0=model.weapon_z(k);
    X=x*r+x0;    Y=y*r+y0;    Z=z*r+z0; 
    surf(X,Y,Z,'EdgeColor','r','FaceColor','none');  
    hold on;
end

end

