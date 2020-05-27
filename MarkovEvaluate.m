function [ stateProbabilityProcess, expectedCostProcess ] = MarkovEvaluate(routepos, model )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%马尔科夫评估每架无人机的每个时刻的生存状态
    %获取评估路径的参数
    %路径点
    posRouteInterp = routepos;
    %探测雷达坐标
    posSensor=[model.xobs;model.yobs;model.zobs];
    %攻击雷达坐标
    posWeapon =[model.weapon_x;model.weapon_y;model.weapon_z];
    %探测雷达范围
    rangeSensor=model.robs;
    %攻击雷达范围
    rangeWeapon=model.weapon_r;
    timeStep=1;
    
    outsideTransitionIntensity=[
        0.0, 0.0, 0.0, 0.0, 0.0;
		0.2, -0.2, 0.0, 0.0, 0.0;
		0.0, 0.2, -0.2, 0.0, 0.0;
		0.0, 0.0, 1.0, -1.0, 0.0;
		0.0, 0.0, 0.0, 0.0, 0.0
    ];
    sensorTransitionIntensity = zeros(5,5,model.UAV);
    weaponTransitionIntensity = zeros(5,5,model.UAV);
    for uav = 1:numel(rangeSensor)
    sensorTransitionIntensity(:,:,uav)=[
        -0.4, 0.4, 0.0, 0.0, 0.0;
		0.1, -0.4, 0.3, 0.0, 0.0;
		0.0, 0.1, -0.1, 0.0, 0.0;
		0.0, 0.0, 1.0, -1.0, 0.0;
		0.0, 0.0, 0.0, 0.0, 0.0
    ];
    weaponTransitionIntensity(:,:,uav)=[
      -0.4, 0.4, 0.0, 0.0, 0.0;
     0.2, -0.2,  0.0,  0.0,  0.0;
     0.0,  0.2, -0.4,  0.2,  0.0;
     0.0,  0.0,  0.1, -0.4,  0.3;
     0.0,  0.0,  0.0,  0.0,  0.0
    ];
    end
    stateCost =[0,1,10,100,0]';
    transitionCost=[
        0.0, 0.0, 0.0, 0.0, 0.0;
		0.0, 0.0, 0.0, 0.0, 0.0;
		0.0, 0.0, 0.0, 0.0, 0.0;
		0.0, 0.0, 0.0, 0.0, 1000.0;
		0.0, 0.0, 0.0, 0.0, 0.0;
    ];

[stateProbabilityProcess, expectedCostProcess]=reRouteEvaluation(posRouteInterp, posSensor, posWeapon, rangeSensor, rangeWeapon,...
		outsideTransitionIntensity, sensorTransitionIntensity, weaponTransitionIntensity, stateCost, transitionCost, timeStep);
end

