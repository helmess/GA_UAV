function  PlotSolution(sol,model )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    XS =sol.XS;
    YS =sol.YS;
    ZS =sol.ZS;

    xx=sol.xx;
    yy=sol.yy;
    zz=sol.zz;
    global Scene;
    global p1;global p2;global p3;global p4;
    
    %alpha =0:pi/50:2*pi;
    %[x1 y1 z1]=sphere;       %将球体数据写入三矩阵中
    %a=[8 -2 2  4];                  %设置球体参数
    %s1=surf(x1*a(1,4)+a(1,1),y1*a(1,4)+a(1,2),z1*a(1,4)+a(1,3),'FaceColor',[0,0,1]);
    figure(Scene);
    view(0,90);
    hold on;
    if(model.alg_choose==1)
    p1=plot3(xx,yy,zz,'k','LineWidth',2);
    elseif(model.alg_choose==2) 
    p2=plot3(xx,yy,zz,'y','LineWidth',2);
    elseif(model.alg_choose==3)
    p3=plot3(xx,yy,zz,'g','LineWidth',2); 
    else
    p4=plot3(xx,yy,zz,'m','LineWidth',2);    
    end
    plot3(XS(2:model.dim+1),YS(2:model.dim+1),ZS(2:model.dim+1),'ro');
    hold off;
    title('GA')
    grid on;



end

