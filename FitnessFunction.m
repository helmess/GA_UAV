function [ cost,sol ] = FitnessFunction( chromosome,model )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    x= zeros(1,model.dim);
    y= zeros(1,model.dim);
    z = zeros(1,model.dim);
    %取第uav个航路的坐标
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
        
    
    xobs = model.xobs;
    yobs = model.yobs;
    zobs = model.zobs;
    robs = model.robs;
    
    XS=[sx x ex];
    YS=[sy y ey];
    ZS=[sz z ez];
    k =numel(XS);
    TP =linspace(0,1,k);
    tt =linspace(0,1,50);
    xx =[];
    yy =[];
    zz=[];
    for i=1:k-1
    %每一段向量分成10个点
    x_r = linspace(XS(i),XS(i+1),10);
    y_r= linspace(YS(i),YS(i+1),10);
    z_r =linspace(ZS(i),ZS(i+1),10);
    xx = [xx,x_r];
    yy = [yy,y_r];
    zz =[zz ,z_r];
    end
    
    %calc L
    dx =diff(xx);
    dy =diff(yy);
    dz = diff(zz);
    Length = sum(sqrt(dx.^2+dy.^2+dz.^2));
    nobs = numel(xobs);
     violation=0;
    for i=1:nobs
       d = sqrt( (xx-xobs(i)).^2+(yy-yobs(i)).^2 );
       v = max(1-d/robs(i),0);
       violation = violation + mean(v);
    end
    sol.TP=TP;
    sol.XS =XS;
    sol.YS=YS;
    sol.ZS=ZS;
    sol.tt=tt;
    sol.xx=xx;
    sol.yy=yy;
    sol.zz=zz;
    sol.dx=dx;
    sol.dy=dy;
    sol.dz=dz;
    sol.Length=Length;
    sol.violation=violation;
    sol.IsFeasible=(violation==0);
    
    %计算协调适应值
    % 3、飞行高度限制
     high=0;
     for k=1:numel(XS)
        x=XS(k);
        y=YS(k);
        h=terrain(x,y);        
        if ZS(k)<=(h+10)  %限制飞行最低高度
            high=high+10000;          
        elseif ZS(k)>375   %限制飞行最高高度              
            high=high+10000;           
        else  
            high=high+abs(ZS(k)-287); %计算与理想高度差距和      
        end        
    end
    
    %z
   
    %归一化处理,设最大距离为10e3
%     MaxDistance = norm([sx(1)-ex,sy(1)-ey,ez(1)-ez(1)]);
%     %设最大时间
%     MaxTime = MaxDistance/model.vrange(1);
%     %初始化每架无人机的代价值
%     uav_cost =zeros(1,model.UAV);
    %w4 =20;
    %计算距离代价
     w1 =0.03;
     w2=0.3;
     w3=0.1;
     w4=0.1;
     %markov evaluatea
     %获取所有维度的坐标
     r_xx=[];r_yy=[];r_zz=[];
    for i=2:numel(XS)-1
    %每一段向量分成10个点
    r_x = linspace(XS(i),XS(i+1),3);
    r_y= linspace(YS(i),YS(i+1),3);
    r_z =linspace(ZS(i),ZS(i+1),3);
    r_xx = [r_xx,r_x];
    r_yy = [r_yy,r_y];
    r_zz =[r_zz ,r_z];
    end
     
    Allpos = [r_xx',r_yy',r_zz'];
   [stateProbabilityProcess, expectedCostProcess]=MarkovEvaluate(Allpos,model);
   sol.MarkovState = stateProbabilityProcess;
   sol.MarkovCost = expectedCostProcess;
    sol.costs=[w1*sol.Length,w3*high,w4*150*mean(expectedCostProcess)];
    cost= w1*sol.Length+w4*150*mean(expectedCostProcess);
    
%     for uav=1:model.UAV
% %     uav_cost(uav) = w1*sol(uav).Length +w2*sol(uav).Length*sol(uav).violation...
% %     +w3*abs( sol(uav).Length/model.vel -chromosome.ETA  );
%     uav_cost(uav) =uav_cost(uav)+ w1*sol(uav).Length/MaxDistance ;
%     end
%     %计算时间协同代价
%    
%     for uav=1:model.UAV
%        uav_cost(uav)= uav_cost(uav) +w2*abs( sol(uav).Length/model.vel -chromosome.ETA )/MaxTime;
%     end
%     
%     %计算所有无人机在协调时间内的位置坐标
%     [chromosome.AllPos]=SecurityDist( chromosome,sol,model );
%     
%     AllPos = chromosome.AllPos;
%     %根据位置坐标计算各个无人机之间的距离
%     %建立一个4dim的距离向量,参数依次是是时间间隔，2维,无人机i,无人机j,表示某一时刻无人机间的距离
%     %dist_vector = zeros(model.intervel,2,model.UAV-1,model.UAV);
%     dist_vector = zeros(model.intervel+1,3,model.UAV-1,model.UAV);
%     
%     for uav1=1:model.UAV
%         for uav2=1:model.UAV
%             if uav2~=uav1
%             dist_vector(:,:,uav2,uav1) = chromosome.AllPos(:,:,uav1) - chromosome.AllPos(:,:,uav2);
%             end
%         end
%     end
%     %建立一个2维的向量,表示在i个时刻是否和其它无人机的距离大于安全距离
%     security_vector =zeros(model.intervel,model.UAV);
%     for i=1:model.intervel
%        for uav1=1:model.UAV
%           for uav2 =1:model.UAV
%              if uav2~=uav1
%                 dist =norm(dist_vector(i,:,uav1,uav2));
%                 %检查距离是否安全
%                 if dist>model.security_dist
%                     security_vector(i,uav1) =1;
%                 else
%                     security_vector(i,uav1) =0;
%                 end
%              end
%           end
%        end
%         
%     end
%     for uav =1:model.UAV
%        sol(uav).SecurityMatrix = security_vector(:,uav);
%     end
%     %根据是否在安全距离以内计算适应度值
%     %设定安全距离代价
%     MaxSecurity = ones(model.intervel,model.UAV);
%     w4=0.1;
%     for uav=1:model.UAV
%     uav_cost(uav) = uav_cost(uav) + w4* sum(security_vector(:,uav))/sum(MaxSecurity(:,uav)) ;      
%     end
% 
%     %加入高度代价,并设定最大高度
%     MaxHeight = ones(model.intervel,model.UAV);
%     w5=0.2;
%     height_cost_array = zeros(model.intervel,model.UAV);
%    for uav=1:model.UAV
%        height_cost_array(uav) = 0;
%        for i=1:length(AllPos)
%           %获取i时间点的高度
%           height = AllPos(i,3,uav);
%           %高度大于一定值，代价为1
%           if height > max(model.robs)
%           height_cost_array(i,uav) = 1; 
%           else
%           height_cost_array(i,uav) = 0;
%           end
%           
%        end
%    end
%    for uav=1:model.UAV
%    uav_cost(uav) =uav_cost(uav) + w5* sum(height_cost_array(:,uav))/sum(MaxHeight(:,uav));
%    end
%    %设定最大markov代价值为10
%    MaxMarkovCost =10*ones(model.intervel,model.UAV);
%    w6=0.5;
%    %马尔科夫评估
%    for uav=1:model.UAV
%    [stateProbabilityProcess, expectedCostProcess]=MarkovEvaluate(AllPos(:,:,uav),model);
%    uav_cost(uav) = uav_cost(uav) +w6* sum(expectedCostProcess) / sum(MaxMarkovCost(:,uav));
%    sol(uav).MarkovState = stateProbabilityProcess;
%    sol(uav).MarkovCost = expectedCostProcess;
%    end
%    %计算总的代价值
%    fitness=0;
%    w3=0.2;
%    for uav=1:model.UAV
%      fitness =fitness+ w1*sol(uav).Length +w2*sol(uav).Length*sol(uav).violation...
%      +w3*abs( sol(uav).Length/model.vel -chromosome.ETA  ); 
%    end
%    
%    cost =fitness;
   
end

