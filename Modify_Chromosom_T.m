function [ T ] = Modify_Chromosom_T( chromosome,model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %计算与实际路径长度
    %获得路径点
    for i=1:model.dim
    x(i) = chromosome.pos(i,1);
    y(i) = chromosome.pos(i,2);
    z(i) = chromosome.pos(i,3);
    end
    sx = model.startp(1);
    sy = model.startp(2);
    sz = model.startp(3);
    ex = model.endp(1);
    ey =model.endp(2);
    ez=model.endp(3);
    XS=[sx x ex];
    YS=[sy y ey];
    ZS=[sz z ez];
    k =numel(XS);
    xx=[];yy=[];zz=[];
    
     for i=1:k-1
    %每一段向量分成10个点
    x_r = linspace(XS(i),XS(i+1),10);
    y_r= linspace(YS(i),YS(i+1),10);
    z_r =linspace(ZS(i),ZS(i+1),10);
    xx = [xx,x_r];
    yy = [yy,y_r];
    zz =[zz ,z_r];
    end
    dx =diff(xx);
    dy =diff(yy);
    dz = diff(zz);
    Length = sum(sqrt(dx.^2+dy.^2+dz.^2));
    deltaT = Length/model.vel/(model.dim+1);
    for i=1:model.dim
       T(i)=  deltaT;
    end

end

